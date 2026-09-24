\set ON_ERROR_STOP on
/*
============================================================
  Script Name : etl_drug_era.sql
  Description : drug_exposureからdrug_eraを生成する

    GitHub OHDSI/CommonDataModel に含まれているスクリプトを引用・改変
    https://github.com/OHDSI/CommonDataModel/blob/main/rmd/sqlScripts.Rmd

  ============================================================
  VIEW全体の概要と処理フロー：
  ============================================================
  
  このVIEWは、OMOP CDMのDRUG_EXPOSUREテーブルから
  DRUG_ERAテーブル形式のデータを生成します。
  
  【主要な処理概念】
  ・30日ルール: 同一薬剤の投薬記録間隔が30日以内の場合、
    連続した一つのdrug_eraとして統合
  ・成分レベル統合: drug_concept_idを成分（Ingredient）レベルに統合
  ・重複除去: 重複する投薬期間を統合して正確な投薬日数を算出
  ・空白日数算出: drug_era期間内の実際の非投薬日数を計算
  
  【処理ステップ】
  1. 薬剤曝露データの前処理（終了日の正規化、成分レベル統合）
  2. 重複する投薬期間の統合（サブ曝露期間の作成）
  3. サブ曝露期間のグループ化
  4. 30日持続期間を適用したdrug_era期間の算出
  5. drug_era終了日の特定
  6. 最終的なdrug_eraレコードの生成（空白日数含む）
  
  【出力カラム】
  ・drug_era_id: drug_eraの一意識別子
  ・person_id: 患者ID
  ・drug_concept_id: 薬剤概念ID（成分レベル）
  ・drug_era_start_date: drug_era開始日
  ・drug_era_end_date: drug_era終了日
  ・drug_exposure_count: drug_era内の投薬記録数
  ・gap_days: drug_era期間内の非投薬日数

  構成概要：
  出力：OMOP CDMのdrug_era形式に準拠したデータセット
  対応DB：PostgreSQL、Redshift対応（SQL Server構文から変換）
============================================================*/

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] etl_drug_era_f.sql 実行 | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo etl_drug_era_f.sql 実行
DROP TABLE IF EXISTS :working_schema.drug_era_sub1 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub2 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub3 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub4 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub5 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub6 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub7 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub8 CASCADE;

-- ================================================================
-- CTE1: ctePreDrugTarget
-- 機能: 薬剤曝露データの前処理と正規化
-- 処理: 
--   - 薬剤概念を成分レベル（Ingredient）に統合
--   - 薬剤曝露終了日の正規化（欠損値の補完）
--   - RxNorm語彙の成分概念のみを対象
-- 出力: drug_exposure_id, person_id, ingredient_concept_id, 
--       drug_exposure_start_date, days_supply, drug_exposure_end_date
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub1 AS
	SELECT
		d.drug_exposure_id
		, d.person_id
		, c.concept_id AS ingredient_concept_id
		, d.drug_exposure_start_date AS drug_exposure_start_date
		, d.days_supply AS days_supply
		, COALESCE(
			---NULLIF returns NULL if both values are the same, otherwise it returns the first parameter
			NULLIF(drug_exposure_end_date, NULL),
			---If drug_exposure_end_date != NULL, return drug_exposure_end_date, otherwise go to next case
			NULLIF(drug_exposure_start_date + INTERVAL '1 day' * days_supply, drug_exposure_start_date),
			---If days_supply != NULL or 0, return drug_exposure_start_date + days_supply, otherwise go to next case
			drug_exposure_start_date + INTERVAL '1 day'
			---Add 1 day to the drug_exposure_start_date since there is no end_date or INTERVAL for the days_supply
		) AS drug_exposure_end_date
	FROM :working_schema.drug_exposure_f d
		JOIN :working_schema.concept_ancestor_f ca ON ca.descendant_concept_id = d.drug_concept_id
		JOIN :working_schema.concept_f c ON ca.ancestor_concept_id = c.concept_id
		WHERE c.vocabulary_id IN ('RxNorm', 'RxNorm Extension')
		AND c.concept_class_id = 'Ingredient'
		AND d.drug_concept_id != 0 ---Our unmapped drug_concept_id's are set to 0, so we don't want different drugs wrapped up in the same era
		AND coalesce(d.days_supply,0) >= 0 ---We have cases where days_supply is negative, and this can set the end_date before the start_date, which we don't want. So we're just looking over those rows. This is a data-quality issue.
;

-- ================================================================
-- CTE2: cteSubExposureEndDates
-- 機能: 重複する薬剤曝露期間の統合（サブ曝露期間の終了日特定）
-- 処理: 
--   - 開始・終了イベントを統一フォーマットで処理
--   - 重複する曝露期間を一つの期間に統合
--   - 30日の持続期間は適用せず、純粋な重複のみを統合
-- 出力: person_id, ingredient_concept_id, end_date
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub2 AS
	SELECT person_id, ingredient_concept_id, event_date AS end_date
	FROM
	(
		SELECT person_id, ingredient_concept_id, event_date, event_type,
		MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id
			ORDER BY event_date, event_type ROWS unbounded preceding) AS start_ordinal,
		-- this pulls the current START down from the prior rows so that the NULLs
		-- from the END DATES will contain a value we can compare with
			ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
				ORDER BY event_date, event_type) AS overall_ord
			-- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		FROM (
			-- select the start dates, assigning a row number to each
			SELECT person_id, ingredient_concept_id, drug_exposure_start_date AS event_date,
			-1 AS event_type,
			ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
				ORDER BY drug_exposure_start_date) AS start_ordinal
			FROM :working_schema.drug_era_sub1

			UNION ALL

			SELECT person_id, ingredient_concept_id, drug_exposure_end_date, 1 AS event_type, NULL
			FROM :working_schema.drug_era_sub1
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
;

-- ================================================================
-- CTE3: cteDrugExposureEnds
-- 機能: 各薬剤曝露に対する実際の終了日を特定
-- 処理: 
--   - 各曝露開始日に対して最も近い統合終了日を特定
--   - 重複統合後の実際の曝露期間を確定
-- 出力: person_id, drug_concept_id, drug_exposure_start_date, drug_sub_exposure_end_date
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub3 AS
    SELECT
        dt.person_id AS person_id,
        dt.ingredient_concept_id AS drug_concept_id,
        dt.drug_exposure_start_date AS drug_exposure_start_date,
        MIN(e.end_date) AS drug_sub_exposure_end_date
    FROM :working_schema.drug_era_sub1 dt
    JOIN :working_schema.drug_era_sub2 e ON dt.person_id = e.person_id AND dt.ingredient_concept_id = e.ingredient_concept_id AND e.end_date >= dt.drug_exposure_start_date
    GROUP BY
            dt.drug_exposure_id
            , dt.person_id
        , dt.ingredient_concept_id
        , dt.drug_exposure_start_date
;
-- ================================================================
-- CTE4: cteSubExposures
-- 機能: サブ曝露期間の集約とカウント
-- 処理: 
--   - 同一終了日を持つ曝露期間をグループ化
--   - 曝露回数をカウントし、期間の開始日を特定
-- 出力: row_number, person_id, drug_concept_id, drug_sub_exposure_start_date,
--       drug_sub_exposure_end_date, drug_exposure_count
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub4 AS
	SELECT ROW_NUMBER() OVER (PARTITION BY person_id, drug_concept_id, drug_sub_exposure_end_date ORDER BY person_id) AS row_number,
    person_id,
    drug_concept_id,
    MIN(drug_exposure_start_date) AS drug_sub_exposure_start_date,
    drug_sub_exposure_end_date,
    COUNT(*) AS drug_exposure_count
	FROM :working_schema.drug_era_sub3
	GROUP BY person_id, drug_concept_id, drug_sub_exposure_end_date
;

-- ================================================================
-- CTE5: cteFinalTarget
-- 機能: 最終的なサブ曝露期間データの準備
-- 処理: 
--   - サブ曝露期間の実際の日数を計算
--   - 30日持続期間適用のための最終データセット作成
-- 出力: row_number, person_id, ingredient_concept_id, drug_sub_exposure_start_date,
--       drug_sub_exposure_end_date, drug_exposure_count, days_exposed
-- ================================================================
/*Everything above grouped exposures into sub_exposures if there was overlap between exposures.
 *So there was no persistence window. Now we can add the persistence window to calculate eras.
 */
--------------------------------------------------------------------------------------------------------------
CREATE TABLE :working_schema.drug_era_sub5 AS
	SELECT
        row_number,
        person_id,
        drug_concept_id AS ingredient_concept_id,
        drug_sub_exposure_start_date,
        drug_sub_exposure_end_date,
        drug_exposure_count,
		EXTRACT(DAY FROM (drug_sub_exposure_end_date - drug_sub_exposure_start_date))::INTEGER AS days_exposed
	FROM :working_schema.drug_era_sub4
;
-- ================================================================
-- CTE6: cteEndDates
-- 機能: 30日持続期間を適用したdrug_era終了日の特定
-- 処理: 
--   - サブ曝露終了日に30日を加算してギャップ期間を設定
--   - 30日以内の次の曝露がある場合はdrug_eraを継続
--   - 実際のdrug_era終了タイミングを特定
-- 出力: person_id, ingredient_concept_id, end_date
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub6 AS
	SELECT
        person_id,
        ingredient_concept_id,
        event_date - INTERVAL '30 day' AS end_date -- unpad the end date
	FROM
	(
		SELECT person_id, ingredient_concept_id, event_date, event_type,
		MAX(start_ordinal) OVER (PARTITION BY person_id, ingredient_concept_id
			ORDER BY event_date, event_type ROWS UNBOUNDED PRECEDING) AS start_ordinal,
		-- this pulls the current START down from the prior rows so that the NULLs
		-- from the END DATES will contain a value we can compare with
			ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
				ORDER BY event_date, event_type) AS overall_ord
			-- this re-numbers the inner UNION so all rows are numbered ordered by the event date
		FROM (
			-- select the start dates, assigning a row number to each
			SELECT person_id, ingredient_concept_id, drug_sub_exposure_start_date AS event_date,
			-1 AS event_type,
			ROW_NUMBER() OVER (PARTITION BY person_id, ingredient_concept_id
				ORDER BY drug_sub_exposure_start_date) AS start_ordinal
			FROM :working_schema.drug_era_sub5

			UNION ALL

			-- pad the end dates by 30 to allow a grace period for overlapping ranges.
			SELECT person_id, ingredient_concept_id, drug_sub_exposure_end_date + INTERVAL '30 day', 1 AS event_type, NULL
			FROM :working_schema.drug_era_sub5
		) RAWDATA
	) e
	WHERE (2 * e.start_ordinal) - e.overall_ord = 0
;

-- ================================================================
-- CTE7: cteDrugEraEnds
-- 機能: 各サブ曝露期間に対するdrug_era終了日の割り当て
-- 処理: 
--   - 各サブ曝露開始日に対して最適なdrug_era終了日を特定
--   - 曝露回数と曝露日数の情報を保持
-- 出力: person_id, drug_concept_id, drug_sub_exposure_start_date,
--       drug_era_end_date, drug_exposure_count, days_exposed
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub7 AS
SELECT
	ft.person_id,
	ft.ingredient_concept_id AS drug_concept_id,
	ft.drug_sub_exposure_start_date,
	MIN(e.end_date) AS drug_era_end_date,
	drug_exposure_count,
	days_exposed
FROM :working_schema.drug_era_sub5 ft
JOIN :working_schema.drug_era_sub6 e ON ft.person_id = e.person_id AND ft.ingredient_concept_id = e.ingredient_concept_id AND e.end_date >= ft.drug_sub_exposure_start_date
GROUP BY
    ft.person_id,
	ft.ingredient_concept_id,
	ft.drug_sub_exposure_start_date,
	drug_exposure_count,
	days_exposed
;

-- ================================================================
-- CTE8: cteDrugEra
-- 機能: 最終的なdrug_eraの生成
-- 処理: 
--   - 同一人物・同一薬剤・同一終了日のレコードをグループ化
--   - drug_era_idを生成し、曝露回数を集計
--   - drug_era期間内の空白日数（gap_days）を算出
-- 出力: drug_era_id, person_id, drug_concept_id, drug_era_start_date,
--       drug_era_end_date, drug_exposure_count, gap_days
-- ================================================================
CREATE TABLE :working_schema.drug_era_sub8 AS
    SELECT
        row_number()over(order by person_id) drug_era_id
        , person_id
        , drug_concept_id
        , MIN(drug_sub_exposure_start_date) AS drug_era_start_date
        , drug_era_end_date
        , SUM(drug_exposure_count) AS drug_exposure_count
        , EXTRACT(DAY FROM (drug_era_end_date - MIN(drug_sub_exposure_start_date)))::INTEGER - SUM(days_exposed) as gap_days
    FROM :working_schema.drug_era_sub7 dee
    GROUP BY person_id, drug_concept_id, drug_era_end_date
;

-- ================================================================
-- 機能: drug_eraへの投入
-- ================================================================
TRUNCATE TABLE :working_schema.drug_era_f;
INSERT INTO :working_schema.drug_era_f SELECT * FROM :working_schema.drug_era_sub8;

-- ================================================================
-- 機能: 一時テーブルの削除
-- ================================================================
DROP TABLE IF EXISTS :working_schema.drug_era_sub1 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub2 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub3 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub4 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub5 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub6 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub7 CASCADE;
DROP TABLE IF EXISTS :working_schema.drug_era_sub8 CASCADE;

\echo =====================================================================
\echo ==== ANALYZE drug_era_f ====
ANALYZE VERBOSE :working_schema.drug_era_f;
DO $$ BEGIN RAISE NOTICE '[END] etl_drug_era_f.sql 実行 | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
