\set ON_ERROR_STOP on
/*
============================================================
Script Name : etl_dose_era.sql
Description : drug_exposureからdose_eraを生成する

GitHub OHDSI/CommonDataModel に含まれているスクリプトを引用・改変
https://github.com/OHDSI/CommonDataModel/blob/main/rmd/sqlScripts.Rmd

============================================================
VIEW全体の概要と処理フロー：
============================================================

このVIEWは、OMOP CDMのDRUG_EXPOSUREテーブルから
DOSE_ERAテーブル形式のデータを生成します。

【主要な処理概念】
・30日ルール: 同一薬剤・同一用量の投薬記録間隔が30日以内の場合、
  連続した一つのdose_eraとして統合
・成分レベル統合: drug_concept_idを成分（Ingredient）レベルに統合
・用量別統合: 同一成分でも用量が異なる場合は別々のdose_eraとして扱う
・用量情報: drug_strengthベースの高精度計算

【処理ステップ】
1. 薬剤曝露データの前処理（成分レベル統合、用量情報抽出）
2. 用量グループの作成（同一患者・成分・用量でのグループ化）
3. 曝露期間の境界識別（30日間隔での連続性判定）
4. Era開始点のマーキング（30日超の間隔でera区切り）
5. Era番号の割り当て（連続するera内での番号付与）
6. 最終的なdose_eraレコードの生成

【出力カラム】
・dose_era_id: dose_eraの一意識別子
・person_id: 患者ID
・drug_concept_id: 薬剤概念ID（成分レベル）
・unit_concept_id: 用量単位概念ID
・dose_value: 高精度1日用量（drug_strengthベース計算）
・dose_era_start_date: dose_era開始日（date型）
・dose_era_end_date: dose_era終了日（date型）

構成概要：
出力：OMOP CDM v5.4のdose_era仕様に準拠したデータセット
対応DB：PostgreSQL、Redshift対応
============================================================*/

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] etl_dose_era_f.sql 実行 | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo etl_dose_era_f.sql 実行
DROP TABLE IF EXISTS :working_schema.dose_era_sub1 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub2 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub3 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub4 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub5 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub6 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub7 CASCADE;

-- ================================================================
-- CTE1: cte_drug_dose - 薬剤曝露データの前処理と高精度1日用量計算
-- 成分レベル統合、終了日正規化、drug_strengthベース用量計算
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub1 AS
    SELECT 
        de.person_id,
        de.drug_concept_id AS original_drug_concept_id,  -- 元のdrug_concept_id
        cd.concept_name AS original_drug_concept_name,    -- 元のdrug概念名
        cd.concept_class_id AS original_concept_class_id, -- 元の薬剤concept_class_id
        de.dose_unit_source_value AS unit_source_value,  -- 元の単位ソース値
        ca.ancestor_concept_id AS ingredient_concept_id,
        ci.concept_name AS ingredient_concept_name,      -- 成分概念名
        de.drug_exposure_start_date,
        COALESCE(de.drug_exposure_end_date, 
                 de.drug_exposure_start_date + INTERVAL '1 day' * COALESCE(de.days_supply, 1)) AS drug_exposure_end_date,
        de.quantity,
        de.days_supply,
        de.refills,
        ds.box_size,
        ds.amount_value,
        ds.amount_unit_concept_id,
        ds.numerator_value,
        ds.numerator_unit_concept_id,
        ds.denominator_value,
        ds.denominator_unit_concept_id,
        c.concept_class_id,
        -- ================================================================
        -- 高精度用量計算アルゴリズム（6つの主要ケース）
        -- drug_strengthテーブルの成分強度情報に基づく薬剤学的正確計算
        -- ================================================================
        CASE
            -- ============================================================
            -- CASE 1: amount_value ベース計算（固形製剤：錠剤・カプセル等）
            -- ============================================================
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value > 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
            THEN
                CASE
                    -- ボックス製剤: daily_dose = amount_value × quantity × box_size ÷ days_supply
                    WHEN de.quantity > 0
                        AND ds.box_size IS NOT NULL
                        AND c.concept_class_id IN ('Branded Drug Box', 'Clinical Drug Box', 'Marketed Product',
                                                  'Quant Branded Box', 'Quant Clinical Box')
                    THEN ds.amount_value * de.quantity * ds.box_size / COALESCE(de.days_supply, 1)
                    
                    -- 通常の固形製剤: daily_dose = amount_value × quantity ÷ days_supply
                    WHEN de.quantity > 0
                        AND c.concept_class_id NOT IN ('Branded Drug Box', 'Clinical Drug Box', 'Marketed Product',
                                                      'Quant Branded Box', 'Quant Clinical Box')
                    THEN ds.amount_value * de.quantity / COALESCE(de.days_supply, 1)
                    
                    -- quantity=0でbox_size指定: daily_dose = amount_value × box_size ÷ days_supply
                    WHEN de.quantity = 0 AND ds.box_size IS NOT NULL
                    THEN ds.amount_value * ds.box_size / COALESCE(de.days_supply, 1)
                    
                    -- 計算不可能なケース
                    WHEN de.quantity = 0 AND ds.box_size IS NULL
                    THEN NULL
                END
            
            -- ============================================================
            -- CASE 1B: amount_value=0の代替計算（固形製剤の特殊処理）
            -- ============================================================
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value = 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
                AND ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
            THEN
                CASE
                    -- numerator/denominatorの比率: (numerator_value/denominator_value) × quantity ÷ days_supply
                    WHEN de.quantity > 0
                        AND ds.denominator_value IS NOT NULL
                        AND ds.denominator_value > 0
                        AND c.concept_class_id NOT IN ('Branded Drug Box', 'Clinical Drug Box', 'Marketed Product',
                                                      'Quant Branded Box', 'Quant Clinical Box')
                    THEN (ds.numerator_value / ds.denominator_value) * de.quantity / COALESCE(de.days_supply, 1)
                    
                    -- numerator_value直接使用: numerator_value × quantity ÷ days_supply
                    WHEN de.quantity > 0
                        AND (ds.denominator_value IS NULL OR ds.denominator_value = 0)
                        AND c.concept_class_id NOT IN ('Branded Drug Box', 'Clinical Drug Box', 'Marketed Product',
                                                      'Quant Branded Box', 'Quant Clinical Box')
                    THEN ds.numerator_value * de.quantity / COALESCE(de.days_supply, 1)
                    
                    -- 計算不可能なケース
                    ELSE NULL
                END
            
            -- ============================================================
            -- CASE 2,3: numerator_value ベース計算（液体製剤・注射剤等）
            -- ============================================================
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id != 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505     --hour
            THEN
                CASE
                    -- 濃度形式での標準計算: numerator_value ÷ days_supply
                    WHEN ds.denominator_value IS NOT NULL
                    THEN ds.numerator_value / COALESCE(de.days_supply, 1)
                    
                    -- quantity指定ありの濃度計算: numerator_value × quantity ÷ days_supply
                    WHEN ds.denominator_value IS NULL AND de.quantity != 0
                    THEN ds.numerator_value * de.quantity / COALESCE(de.days_supply, 1)
                    
                    -- 計算不可能なケース
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN NULL
                END
            
            -- ============================================================
            -- CASE 4: Ingredient クラス特別処理
            -- ============================================================
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id = 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505
            THEN
                CASE
                    -- 成分レベル計算: quantity ÷ days_supply
                    WHEN de.quantity > 0
                    THEN de.quantity / COALESCE(de.days_supply, 1)
                    
                    -- 計算不可能なケース
                    WHEN de.quantity = 0
                    THEN NULL
                END
            
            -- ============================================================
            -- CASE 6: 時間単位処理（持続注入薬剤・時間指定薬剤）
            -- ============================================================
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND ds.denominator_unit_concept_id = 8505
            THEN
                CASE
                    -- 時間単位計算: numerator_value × 24 ÷ denominator_value
                    WHEN ds.denominator_value IS NOT NULL
                    THEN ds.numerator_value * 24 / ds.denominator_value
                    
                    -- quantity指定での時間単位計算: numerator_value × 24 ÷ quantity
                    WHEN ds.denominator_value IS NULL AND de.quantity != 0
                    THEN ds.numerator_value * 24 / de.quantity
                    
                    -- 計算不可能なケース
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN NULL
                END
            
            -- ============================================================
            -- フォールバック: 従来の簡易計算
            -- ============================================================
            ELSE CAST(de.quantity AS FLOAT) / COALESCE(de.days_supply, 1)
        END AS dose_value,
        
        -- ================================================================
        -- 用量計算ケース識別カラム（デバッグ用）
        -- ================================================================
        CASE
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value > 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
            THEN 
                CASE
                    WHEN de.quantity > 0
                        AND ds.box_size IS NOT NULL
                        AND c.concept_class_id IN ('Branded Drug Box', 'Clinical Drug Box', 'Marketed Product',
                                                  'Quant Branded Box', 'Quant Clinical Box')
                    THEN 'CASE1-BOX'
                    WHEN de.quantity > 0
                        AND c.concept_class_id NOT IN ('Branded Drug Box', 'Clinical Drug Box', 'Marketed Product',
                                                      'Quant Branded Box', 'Quant Clinical Box')
                    THEN 'CASE1-STANDARD'
                    WHEN de.quantity = 0 AND ds.box_size IS NOT NULL
                    THEN 'CASE1-BOX-NO-QTY'
                    WHEN de.quantity = 0 AND ds.box_size IS NULL
                    THEN 'CASE1-NO-CALC'
                END
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value = 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
                AND ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
            THEN
                CASE
                    WHEN de.quantity > 0
                        AND ds.denominator_value IS NOT NULL
                        AND ds.denominator_value > 0
                    THEN 'CASE1B-NUMERATOR-RATIO'
                    WHEN de.quantity > 0
                        AND (ds.denominator_value IS NULL OR ds.denominator_value = 0)
                    THEN 'CASE1B-NUMERATOR-DIRECT'
                    ELSE 'CASE1B-NO-CALC'
                END
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id != 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505
            THEN
                CASE
                    WHEN ds.denominator_value IS NOT NULL
                    THEN 'CASE2-CONCENTRATION'
                    WHEN ds.denominator_value IS NULL AND de.quantity != 0
                    THEN 'CASE3-QTY-BASED'
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN 'CASE3-NO-CALC'
                END
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id = 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505
            THEN
                CASE
                    WHEN de.quantity > 0
                    THEN 'CASE4-INGREDIENT'
                    WHEN de.quantity = 0
                    THEN 'CASE4-NO-CALC'
                END
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND ds.denominator_unit_concept_id = 8505
            THEN
                CASE
                    WHEN ds.denominator_value IS NOT NULL
                    THEN 'CASE6-HOURLY'
                    WHEN ds.denominator_value IS NULL AND de.quantity != 0
                    THEN 'CASE6-QTY-HOURLY'
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN 'CASE6-NO-CALC'
                END
            ELSE 'FALLBACK'
        END AS dose_calculation_case,
        -- ================================================================
        -- 用量単位計算アルゴリズム
        -- 各薬剤形態に応じて適切な単位概念IDを設定
        -- 8576:mg, 8587:mL, 8554:g, 0:単位なし
        -- ================================================================
        CASE
            -- ============================================================
            -- CASE 1: amount_value ベース - 固形製剤の単位
            -- ============================================================
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value > 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
            THEN
                CASE
                    -- 計算不可能ケースでもデフォルト単位を設定（OMOP CDM準拠）
                    WHEN de.quantity = 0 AND ds.box_size IS NULL
                    THEN COALESCE(ds.amount_unit_concept_id, 0)
                    -- 正常ケースでは amount_unit_concept_id を使用
                    ELSE ds.amount_unit_concept_id
                END
            
            -- ============================================================
            -- CASE 1B: amount_value=0代替計算 - 固形製剤の単位
            -- ============================================================
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value = 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
                AND ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
            THEN
                CASE
                    -- 計算不可能ケースでもデフォルト単位を設定（OMOP CDM準拠）
                    WHEN de.quantity = 0
                    THEN COALESCE(ds.numerator_unit_concept_id, 0)
                    -- 代替計算ケースでは numerator_unit_concept_id を使用
                    ELSE ds.numerator_unit_concept_id
                END
            
            -- ============================================================
            -- CASE 2,3: numerator_value ベース - 液体製剤の単位
            -- ============================================================
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id != 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505     --hour
            THEN
                CASE
                    -- 計算不可能ケースでもデフォルト単位を設定（OMOP CDM準拠）
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN COALESCE(ds.numerator_unit_concept_id, 0)
                    -- 正常ケースでは numerator_unit_concept_id を使用
                    ELSE ds.numerator_unit_concept_id
                END
            
            -- ============================================================
            -- CASE 4: Ingredient クラス - 適切な単位選択
            -- ============================================================
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id = 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505
            THEN
                CASE
                    -- 計算不可能ケースでもデフォルト単位を設定（OMOP CDM準拠）
                    WHEN de.quantity = 0
                    THEN COALESCE(ds.numerator_unit_concept_id, 0)
                    -- 正常ケースでは numerator_unit_concept_id を使用
                    ELSE ds.numerator_unit_concept_id
                END
            
            -- ============================================================
            -- CASE 6: 時間単位処理 - 時間換算薬剤の単位
            -- ============================================================
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND ds.denominator_unit_concept_id = 8505
            THEN
                CASE
                    -- 計算不可能ケースでもデフォルト単位を設定（OMOP CDM準拠）
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN COALESCE(ds.numerator_unit_concept_id, 0)
                    -- 正常ケースでは numerator_unit_concept_id を使用
                    ELSE ds.numerator_unit_concept_id
                END
            
            -- ============================================================
            -- フォールバック: 利用可能な単位情報を使用
            -- ============================================================
            ELSE COALESCE(ds.amount_unit_concept_id, ds.numerator_unit_concept_id, 0)
        END AS unit_concept_id,
        -- ================================================================
        -- 用量単位概念名の取得（unit_concept_idに対応した概念名）
        -- ================================================================
        CASE
            -- unit_concept_idと同じロジックで概念名を取得
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value > 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
            THEN
                CASE
                    WHEN de.quantity = 0 AND ds.box_size IS NULL
                    THEN NULL
                    ELSE cua.concept_name  -- amount_unit_concept_idの概念名
                END
            WHEN ds.amount_value IS NOT NULL
                AND ds.amount_value = 0
                AND (ds.denominator_unit_concept_id IS NULL OR ds.denominator_unit_concept_id = 0)
                AND ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
            THEN
                CASE
                    WHEN de.quantity = 0
                    THEN NULL
                    ELSE cun.concept_name  -- numerator_unit_concept_idの概念名
                END
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id != 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505
            THEN
                CASE
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN NULL
                    ELSE cun.concept_name  -- numerator_unit_concept_idの概念名
                END
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND cd.concept_class_id = 'Ingredient'
                AND ds.denominator_unit_concept_id != 8505
            THEN
                CASE
                    WHEN de.quantity = 0
                    THEN NULL
                    ELSE cun.concept_name  -- numerator_unit_concept_idの概念名
                END
            WHEN ds.numerator_value IS NOT NULL
                AND ds.numerator_value > 0
                AND ds.denominator_unit_concept_id = 8505
            THEN
                CASE
                    WHEN ds.denominator_value IS NULL AND de.quantity = 0
                    THEN NULL
                    ELSE cun.concept_name  -- numerator_unit_concept_idの概念名
                END
            ELSE COALESCE(cua.concept_name, cun.concept_name)  -- フォールバック
        END AS ingredient_unit_concept_name  -- 成分用量単位概念名
    FROM :working_schema.drug_exposure_f de
    JOIN :working_schema.concept_ancestor_f ca ON ca.descendant_concept_id = de.drug_concept_id
    JOIN :working_schema.concept_f c ON ca.ancestor_concept_id = c.concept_id
    LEFT JOIN :working_schema.concept_f cd ON de.drug_concept_id = cd.concept_id  -- 元のdrug概念名取得
    LEFT JOIN :working_schema.concept_f ci ON ca.ancestor_concept_id = ci.concept_id  -- 成分概念名取得
    LEFT JOIN :working_schema.drug_strength_f ds ON de.drug_concept_id = ds.drug_concept_id
                                    AND ca.ancestor_concept_id = ds.ingredient_concept_id
    LEFT JOIN :working_schema.concept_f cua ON ds.amount_unit_concept_id = cua.concept_id  -- amount_unit概念名取得
    LEFT JOIN :working_schema.concept_f cun ON ds.numerator_unit_concept_id = cun.concept_id  -- numerator_unit概念名取得
    WHERE c.vocabulary_id IN ('RxNorm', 'RxNorm Extension')
      AND c.concept_class_id = 'Ingredient'  -- 成分レベルに統合するため、成分のみを対象とする
      AND de.drug_concept_id != 0
      AND de.quantity IS NOT NULL
      AND de.quantity > 0
      AND de.days_supply IS NOT NULL
      AND de.days_supply > 0
;

-- ================================================================
-- CTE2: cte_dose_groups - 高精度1日用量グループの作成と順序付け
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub2 AS
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY person_id, ingredient_concept_id, dose_value, unit_concept_id
               ORDER BY drug_exposure_start_date
           ) AS dose_group_ordinal
    FROM :working_schema.dose_era_sub1
    WHERE dose_value IS NOT NULL  -- 用量計算に失敗したレコードを除外
;

-- ================================================================
-- CTE3: cte_dose_era_ends - 曝露期間の境界識別と前曝露終了日の取得
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub3 AS
    SELECT 
        person_id,
        ingredient_concept_id,
        dose_value,
        unit_concept_id,
        drug_exposure_start_date,
        drug_exposure_end_date,
        dose_group_ordinal,
        -- 可読性向上カラムを追加
        original_drug_concept_id,
        original_drug_concept_name,
        original_concept_class_id,
        quantity,
        unit_source_value,
        days_supply,
        ingredient_concept_name,
        ingredient_unit_concept_name,
        dose_calculation_case,
        LAG(drug_exposure_end_date) OVER (
            PARTITION BY person_id, ingredient_concept_id, dose_value, unit_concept_id
            ORDER BY drug_exposure_start_date
        ) AS prev_exposure_end_date
    FROM :working_schema.dose_era_sub2
;

-- ================================================================
-- CTE4: cte_dose_era_starts - Era開始点のマーキング（30日ルール適用）
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub4 AS
    SELECT *,
           CASE 
               WHEN prev_exposure_end_date IS NULL 
                    OR drug_exposure_start_date > prev_exposure_end_date + INTERVAL '30 day'
               THEN 1 
               ELSE 0 
           END AS is_era_start
    FROM :working_schema.dose_era_sub3
;

-- ================================================================
-- CTE5: cte_dose_era_numbers - Era番号の割り当て（累積合計による連番付与）
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub5 AS
    SELECT *,
           SUM(is_era_start) OVER (
               PARTITION BY person_id, ingredient_concept_id, dose_value, unit_concept_id
               ORDER BY drug_exposure_start_date 
               ROWS UNBOUNDED PRECEDING
           ) AS dose_era_number
    FROM :working_schema.dose_era_sub4
;

-- ================================================================
-- CTE6: cte_dose_eras - 最終的なdose_eraレコードの生成（集約処理）
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub6 AS
    SELECT 
        ROW_NUMBER() OVER (ORDER BY person_id, ingredient_concept_id, dose_value) AS dose_era_id,
        person_id,
        ingredient_concept_id AS drug_concept_id,
        unit_concept_id,
        dose_value,
        MIN(drug_exposure_start_date) AS dose_era_start_date,
        MAX(drug_exposure_end_date) AS dose_era_end_date,
        -- 可読性向上のための追加カラム
        MIN(original_drug_concept_id) AS sample_original_drug_concept_id,
        MIN(original_drug_concept_name) AS sample_original_drug_concept_name,
        MIN(quantity) AS sample_quantity,
        MIN(unit_source_value) AS sample_unit_source_value,
        MIN(days_supply) AS sample_days_supply,
        MIN(ingredient_concept_name) AS ingredient_concept_name,
        MIN(ingredient_unit_concept_name) AS ingredient_unit_concept_name,
        MIN(dose_calculation_case) AS sample_dose_calculation_case
    FROM :working_schema.dose_era_sub5
    GROUP BY 
        person_id, 
        ingredient_concept_id, 
        dose_value, 
        unit_concept_id, 
        dose_era_number
;

-- ================================================================
-- CTE7: cte_dose_era - 最終出力フォーマットへの整形
-- ================================================================
CREATE TABLE :working_schema.dose_era_sub7 AS
    SELECT 
        dose_era_id,
        person_id,
        drug_concept_id,
        unit_concept_id,
        dose_value::numeric(18,5) AS dose_value,
        dose_era_start_date::timestamp,
        dose_era_end_date::timestamp
    FROM :working_schema.dose_era_sub6
    ORDER BY dose_era_id
;

-- ================================================================
-- 機能: dose_eraへの投入
-- ================================================================
TRUNCATE TABLE :working_schema.dose_era_f;
INSERT INTO :working_schema.dose_era_f SELECT * FROM :working_schema.dose_era_sub7;

-- ================================================================
-- 機能: 一時テーブルの削除
-- ================================================================
DROP TABLE IF EXISTS :working_schema.dose_era_sub1 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub2 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub3 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub4 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub5 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub6 CASCADE;
DROP TABLE IF EXISTS :working_schema.dose_era_sub7 CASCADE;

\echo =====================================================================
\echo ==== ANALYZE dose_era_f ====
ANALYZE VERBOSE :working_schema.dose_era_f;
DO $$ BEGIN RAISE NOTICE '[END] etl_dose_era_f.sql 実行 | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
