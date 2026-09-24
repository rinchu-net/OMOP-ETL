\set ON_ERROR_STOP on
/*
============================================================
  Script Name : omop_condition_era.sql
  Description : conditionからcondition_eraを生成する

    GitHub OHDSI/CommonDataModel に含まれている以下のスクリプトを引用
    https://github.com/OHDSI/CommonDataModel/blob/main/rmd/sqlScripts.Rmd

    This script will insert values into the CONDITION_ERA table given that
    the CONDITION_OCCURRENCE table is populated.
    It will string together condition records that have <= 30 days between them
    into eras during which the Person is assumed to have the given condition.
    **NOTE** This query only works with 5.3 and below.

  【全体の概要と処理フロー】
  このVIEWは、OMOP CDMのCONDITION_OCCURRENCEテーブルから
  CONDITION_ERAテーブル形式のデータを生成します。
  
  【主要な処理概念】
  ・30日ルール: 同一疾患の診断記録間隔が30日以内の場合、
    連続した一つのエラ（Era）として統合
  ・エラ期間: 疾患の開始から終了（30日間隔が空く）までの期間
  ・発生回数: 一つのエラ内に含まれる診断記録の件数
  
  【処理ステップ】
  1. 基本データ準備（欠損終了日の補完）
  2. 開始・終了イベントの統一フォーマット化
  3. イベント順序の番号付け
  4. 開始・終了イベントの対応関係特定
  5. エラ終了日の算出
  6. エラ期間の確定
  7. 最終的なエラレコードの生成
  
  【出力カラム】
  ・condition_era_id: エラの一意識別子
  ・person_id: 患者ID
  ・condition_concept_id: 疾患概念ID
  ・condition_era_start_date: エラ開始日
  ・condition_era_end_date: エラ終了日
  ・condition_occurrence_count: エラ内の診断記録数

  構成概要：
  出力：OMOP CDMのcondition_era形式に準拠したデータセット
  対応DB：PostgreSQL、Redshift対応
============================================================*/
CREATE OR REPLACE VIEW :working_schema.v_condition_era_f AS
WITH
-- ================================================================
-- CTE1: cte_condition_target
-- 機能: CONDITION_OCCURRENCEテーブルから基本的な条件データを取得
-- 処理: condition_end_dateがNULLの場合は開始日+1日を終了日として設定
-- 出力: person_id, condition_concept_id, condition_start_date, condition_end_date
-- ================================================================
cte_condition_target AS (
    SELECT
        co.person_id,
        co.condition_concept_id,
        co.condition_start_date,
        COALESCE(co.condition_end_date, co.condition_start_date + INTERVAL '1 day') AS condition_end_date
    FROM :working_schema.condition_occurrence_f co
),

-- ================================================================
-- CTE2: cte_rawdata
-- 機能: condition_concept_idごとの開始・終了イベントをユニオンして統一フォーマットに変換
-- 処理: 
--   - 開始イベント: event_type=-1, start_ordinalを付与
--   - 終了イベント: event_type=1, 終了日+30日をイベント日として設定
-- 出力: person_id, condition_concept_id, event_date, event_type, start_ordinal
-- ================================================================
cte_rawdata AS (
    SELECT
        person_id,
        condition_concept_id,
        condition_start_date AS event_date,
        -1 AS event_type,
        ROW_NUMBER() OVER (
            PARTITION BY person_id, condition_concept_id ORDER BY condition_start_date
        ) AS start_ordinal
    FROM cte_condition_target
    UNION ALL
    SELECT
        person_id,
        condition_concept_id,
        condition_end_date + INTERVAL '30 day',
        1 AS event_type,
        NULL
    FROM cte_condition_target
),

-- ================================================================
-- CTE3: cte_numbered_events
-- 機能: 全イベントに対して統一的な順序番号を付与
-- 処理: 
--   - person_id・condition_concept_idごとにイベント日付と種類で全体順序を決定
--   - 開始イベントのstart_ordinalを保持
-- 出力: person_id, condition_concept_id, event_date, event_type, start_ordinal, overall_ord
-- ================================================================
cte_numbered_events AS (
    SELECT
        person_id,
        condition_concept_id,
        event_date,
        event_type,
        start_ordinal,
        ROW_NUMBER() OVER (
            PARTITION BY person_id, condition_concept_id ORDER BY event_date, event_type
        ) AS overall_ord
    FROM cte_rawdata
),

-- ================================================================
-- CTE4: cte_joined_events
-- 機能: イベントと開始順序番号を結合し、終了イベントに対応する開始順序を特定
-- 処理: 
--   - 各イベントに対して、それ以前の最大start_ordinalを取得
--   - 開始イベントは自身のstart_ordinalを保持
--   - 終了イベントは対応する開始イベントのstart_ordinalを取得
-- 出力: person_id, condition_concept_id, event_date, start_ordinal, overall_ord
-- ================================================================
cte_joined_events AS (
    SELECT
        e1.person_id,
        e1.condition_concept_id,
        e1.event_date,
        COALESCE(e1.start_ordinal, MAX(e2.start_ordinal)) AS start_ordinal,
        e1.overall_ord
    FROM cte_numbered_events e1
    INNER JOIN (
        SELECT
            person_id,
            condition_concept_id,
            condition_start_date AS event_date,
            ROW_NUMBER() OVER (
                PARTITION BY person_id, condition_concept_id ORDER BY condition_start_date
            ) AS start_ordinal
        FROM cte_condition_target
    ) e2 ON e1.person_id = e2.person_id
        AND e1.condition_concept_id = e2.condition_concept_id
        AND e2.event_date <= e1.event_date
    GROUP BY e1.person_id, e1.condition_concept_id, e1.event_date, e1.start_ordinal, e1.overall_ord
),

-- ================================================================
-- CTE5: cte_cond_end_dates
-- 機能: condition_eraの終了日候補を特定
-- 処理: 
--   - 2*start_ordinal - overall_ord = 0 の条件で終了イベントを特定
--   - 該当イベント日から30日前を終了日として算出
-- 出力: person_id, condition_concept_id, end_date
-- ================================================================
cte_cond_end_dates AS (
    SELECT
        person_id,
        condition_concept_id,
        event_date - INTERVAL '30 day' AS end_date
    FROM cte_joined_events
    WHERE (2 * start_ordinal) - overall_ord = 0
),

-- ================================================================
-- CTE6: cte_condition_ends
-- 機能: 各condition_concept_id開始日に対して最小の終了日を特定
-- 処理: 
--   - condition_concept_idごとに開始日以降の最小終了日をera_end_dateとして設定
--   - condition_eraの実際の終了タイミングを決定
-- 出力: person_id, condition_concept_id, condition_start_date, era_end_date
-- ================================================================
cte_condition_ends AS (
    SELECT
        c.person_id,
        c.condition_concept_id,
        c.condition_start_date,
        MIN(e.end_date) AS era_end_date
    FROM cte_condition_target c
    INNER JOIN cte_cond_end_dates e ON c.person_id = e.person_id
        AND c.condition_concept_id = e.condition_concept_id
        AND e.end_date >= c.condition_start_date
    GROUP BY c.person_id, c.condition_concept_id, c.condition_start_date
),

-- ================================================================
-- CTE7: cte_condition_era
-- 機能: 最終的なcondition_eraを生成
-- 処理: 
--   - 同一person_id・同一condition_concept_id・同一終了日のレコードをグループ化
--   - condition_era_idを生成し、発生回数をカウント
--   - 期間内の最小開始日をエラ開始日として設定
-- 出力: condition_era_id, person_id, condition_concept_id, 
--       condition_era_start_date, condition_era_end_date, condition_occurrence_count
-- ================================================================
cte_condition_era AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY person_id, condition_concept_id) AS condition_era_id,
        person_id,
        condition_concept_id,
        MIN(condition_start_date) AS condition_era_start_date,
        era_end_date AS condition_era_end_date,
        COUNT(*) AS condition_occurrence_count
    FROM cte_condition_ends
    GROUP BY person_id, condition_concept_id, era_end_date
)

SELECT * FROM cte_condition_era;

/*
SELECT * FROM :working_schema.v_condition_era;
DELETE FROM :working_schema.condition_era;
INSERT INTO :working_schema.condition_era SELECT * FROM :working_schema.v_condition_era;
SELECT * FROM :working_schema.condition_era;
*/