\set ON_ERROR_STOP on
/*
============================================================
  Script Name : observation_period.sql
  Description : observation_periodテーブル生成用VIEW

  ============================================================
  VIEW全体の概要と処理フロー：
  ============================================================
  
  このVIEWは、各臨床イベントテーブルから患者の観察期間を
  統合してOBSERVATION_PERIODテーブル形式のデータを生成します。
  
  【主要な処理概念】
  ・イベント統合: 各臨床イベントから観察期間を抽出
  ・タイプ別集約: 各テーブルのtype_concept_idでグループ化して期間を統合
  ・期間統合: 患者・タイプごとに最小開始日〜最大終了日で統合
  ・ID生成: observation_period_idを連番で生成
  
  【処理ステップ】
  1. 各臨床イベントテーブルから観察期間を抽出（CTE別、type_concept_id別）
  2. 全イベントをUNIONで統合
  3. 患者・タイプごとに最小開始日〜最大終了日で集約
  4. observation_period_idを生成して最終データを出力
  
  【出力カラム】
  ・observation_period_id: 観察期間の一意識別子
  ・person_id: 患者ID
  ・observation_period_start_date: 観察期間開始日
  ・observation_period_end_date: 観察期間終了日
  ・period_type_concept_id: 各テーブルの実際のtype_concept_id

  構成概要：
  出力：OMOP CDMのobservation_period形式に準拠したデータセット
  対応DB：PostgreSQL, Redshift対応
============================================================*/
CREATE OR REPLACE VIEW :working_schema.v_observation_period_f AS
WITH
-- ================================================================
-- CTE1: cteDrugExposure
-- 機能: DRUG_EXPOSUREテーブルから観察期間を抽出
-- 処理: 
--   - 薬剤曝露開始日を観察期間開始日とする
--   - 薬剤曝露終了日（またはデフォルトで開始日）を観察期間終了日とする
--   - drug_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteDrugExposure AS (
    SELECT
        person_id                                                       AS person_id,
        drug_type_concept_id                                            AS type_concept_id,
        MIN(drug_exposure_start_date)                                   AS observation_period_start_date,
        MAX(COALESCE(drug_exposure_end_date, drug_exposure_start_date)) AS observation_period_end_date
    FROM
        :working_schema.drug_exposure_f d
    GROUP BY
        person_id, drug_type_concept_id
),

-- ================================================================
-- CTE2: cteProcedureOccurrence
-- 機能: PROCEDURE_OCCURRENCEテーブルから観察期間を抽出
-- 処理: 
--   - 処置実施日を観察期間の開始日・終了日とする
--   - procedure_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteProcedureOccurrence AS (
    SELECT
        person_id                                                       AS person_id,
        procedure_type_concept_id                                       AS type_concept_id,
        MIN(procedure_date)                                             AS observation_period_start_date,
        MAX(procedure_date)                                             AS observation_period_end_date
    FROM
        :working_schema.procedure_occurrence_f p
    GROUP BY
        person_id, procedure_type_concept_id
),

-- ================================================================
-- CTE3: cteConditionOccurrence
-- 機能: CONDITION_OCCURRENCEテーブルから観察期間を抽出
-- 処理: 
--   - 診断開始日を観察期間開始日とする
--   - 診断終了日（またはデフォルトで開始日）を観察期間終了日とする
--   - condition_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteConditionOccurrence AS (
    SELECT
        person_id                                                       AS person_id,
        condition_type_concept_id                                       AS type_concept_id,
        MIN(condition_start_date)                                       AS observation_period_start_date,
        MAX(COALESCE(condition_end_date, condition_start_date))         AS observation_period_end_date
    FROM
        :working_schema.condition_occurrence_f c
    GROUP BY
        person_id, condition_type_concept_id
),

-- ================================================================
-- CTE4: cteObservation
-- 機能: OBSERVATIONテーブルから観察期間を抽出
-- 処理: 
--   - 観察実施日を観察期間の開始日・終了日とする
--   - observation_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteObservation AS (
    SELECT
        person_id                                                       AS person_id,
        observation_type_concept_id                                     AS type_concept_id,
        MIN(observation_date)                                           AS observation_period_start_date,
        MAX(observation_date)                                           AS observation_period_end_date
    FROM
        :working_schema.observation_f o
    GROUP BY
        person_id, observation_type_concept_id
),

-- ================================================================
-- CTE5: cteMeasurement
-- 機能: MEASUREMENTテーブルから観察期間を抽出
-- 処理: 
--   - 測定実施日を観察期間の開始日・終了日とする
--   - measurement_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteMeasurement AS (
    SELECT
        person_id                                                       AS person_id,
        measurement_type_concept_id                                     AS type_concept_id,
        MIN(measurement_date)                                           AS observation_period_start_date,
        MAX(measurement_date)                                           AS observation_period_end_date
    FROM
        :working_schema.measurement_f m
    GROUP BY
        person_id, measurement_type_concept_id
),

-- ================================================================
-- CTE6: cteDeviceExposure
-- 機能: DEVICE_EXPOSUREテーブルから観察期間を抽出
-- 処理: 
--   - デバイス曝露開始日を観察期間開始日とする
--   - デバイス曝露終了日（またはデフォルトで開始日）を観察期間終了日とする
--   - device_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteDeviceExposure AS (
    SELECT
        person_id                                                       AS person_id,
        device_type_concept_id                                          AS type_concept_id,
        MIN(device_exposure_start_date)                                 AS observation_period_start_date,
        MAX(COALESCE(device_exposure_end_date, device_exposure_start_date)) AS observation_period_end_date
    FROM
        :working_schema.device_exposure_f di
    GROUP BY
        person_id, device_type_concept_id
),

-- ================================================================
-- CTE7: cteSpecimen
-- 機能: SPECIMENテーブルから観察期間を抽出
-- 処理: 
--   - 検体採取日を観察期間の開始日・終了日とする
--   - specimen_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteSpecimen AS (
    SELECT
        person_id                                                       AS person_id,
        specimen_type_concept_id                                        AS type_concept_id,
        MIN(specimen_date)                                              AS observation_period_start_date,
        MAX(specimen_date)                                              AS observation_period_end_date
    FROM
        :working_schema.specimen_f s
    GROUP BY
        person_id, specimen_type_concept_id
),

-- ================================================================
-- CTE8: cteVisitOccurrence
-- 機能: VISIT_OCCURRENCEテーブルから観察期間を抽出
-- 処理: 
--   - 受診開始日を観察期間開始日とする
--   - 受診終了日（またはデフォルトで開始日）を観察期間終了日とする
--   - visit_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteVisitOccurrence AS (
    SELECT
        person_id                                                       AS person_id,
        visit_type_concept_id                                           AS type_concept_id,
        MIN(visit_start_date)                                           AS observation_period_start_date,
        MAX(COALESCE(visit_end_date, visit_start_date))                 AS observation_period_end_date
    FROM
        :working_schema.visit_occurrence_f v
    GROUP BY
        person_id, visit_type_concept_id
),

-- ================================================================
-- CTE9: cteDeath
-- 機能: DEATHテーブルから観察期間を抽出
-- 処理: 
--   - 死亡日を観察期間の開始日・終了日とする
--   - death_type_concept_idでグループ化して期間を統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteDeath AS (
    SELECT
        person_id                                                       AS person_id,
        death_type_concept_id                                           AS type_concept_id,
        MIN(death_date)                                                 AS observation_period_start_date,
        MAX(death_date)                                                 AS observation_period_end_date
    FROM
        :working_schema.death_f de
    GROUP BY
        person_id, death_type_concept_id
),

-- ================================================================
-- CTE10: cteAllEvents
-- 機能: 全臨床イベントの統合
-- 処理: 
--   - 各CTEからの観察期間をUNIONで統合
--   - type_concept_idを含めて統合
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteAllEvents AS (
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteDrugExposure
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteProcedureOccurrence
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteConditionOccurrence
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteObservation
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteMeasurement
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteDeviceExposure
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteSpecimen
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteVisitOccurrence
    UNION ALL
    SELECT person_id, type_concept_id, observation_period_start_date, observation_period_end_date FROM cteDeath
),

-- ================================================================
-- CTE11: cteAggregatedPeriods
-- 機能: 患者・タイプごとの観察期間集約
-- 処理: 
--   - person_id, type_concept_idでグループ化
--   - MIN/MAXで各タイプごとの観察期間を算出
-- 出力: person_id, type_concept_id, observation_period_start_date, observation_period_end_date
-- ================================================================
cteAggregatedPeriods AS (
    SELECT
        person_id                                                       AS person_id,
        type_concept_id                                                 AS type_concept_id,
        MIN(observation_period_start_date)                              AS observation_period_start_date,
        MAX(observation_period_end_date)                                AS observation_period_end_date
    FROM cteAllEvents
    GROUP BY person_id, type_concept_id
),

-- ================================================================
-- CTE12: cteObservationPeriod
-- 機能: observation_period_idを含む患者ごとの観察期間統合
-- 処理: 
--   - person_id, type_concept_id, observation_period_start_dateでソート
--   - ROW_NUMBER()で一意のobservation_period_idを生成
--   - 各CTEから取得したtype_concept_idをperiod_type_concept_idとして出力
--   - death_fテーブルと外部結合し、死亡日がobservation_period_end_dateより前の場合は死亡日を採用
-- 出力: observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id
-- ================================================================
cteObservationPeriod AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY cap.person_id, cap.type_concept_id, cap.observation_period_start_date) AS observation_period_id,
        cap.person_id                                                           AS person_id,
        cap.observation_period_start_date                                       AS observation_period_start_date,
        CASE 
            WHEN de.death_date IS NOT NULL AND cap.observation_period_end_date > de.death_date 
            THEN de.death_date 
            ELSE cap.observation_period_end_date 
        END                                                                      AS observation_period_end_date,
        cap.type_concept_id                                                     AS period_type_concept_id
    FROM cteAggregatedPeriods cap
    LEFT JOIN :working_schema.death_f de ON cap.person_id = de.person_id
)

-- ================================================================
-- 最終出力: observation_periodテーブルデータの出力
-- 機能: observation_period_idでソートした完全なobservation_periodデータを出力
-- 処理: 
--   - observation_period_idでソート
--   - OMOP CDM準拠の完全なobservation_periodテーブルデータを提供
-- 出力: observation_period_id, person_id, observation_period_start_date, observation_period_end_date, period_type_concept_id
-- ================================================================
SELECT * FROM cteObservationPeriod ORDER BY observation_period_id;

/*
SELECT * FROM :working_schema.v_observation_period_f;
SELECT op.*, c.concept_name FROM :working_schema.v_observation_period_f op LEFT JOIN :working_schema.concept c ON op.period_type_concept_id = c.concept_id;
DELETE FROM :working_schema.observation_period_f;
INSERT INTO :working_schema.observation_period_f SELECT * FROM :working_schema.v_observation_period_f;
*/