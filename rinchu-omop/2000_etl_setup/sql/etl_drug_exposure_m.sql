\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからDRUG_EXPOSUREテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからDrugドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のdrug_exposureテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（drug_exposure, measurement, observation等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のDrugドメインイベント：
- 医薬品データ（処方）
- 注射薬データ（注射）
- その他Drugドメインに分類される薬剤関連イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Drug'による抽出
2. カラムマッピング：LK → drug_exposure形式への変換
3. ID付与：drug_exposure_idの連番付与
4. 薬剤特有フィールド：用量・用法・投与日数等の適切な設定

【出力仕様】
- 形式: OMOP CDM v5.4 drug_exposureテーブル準拠
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: stage.v_omop_common_mapped（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_drug_exposure_m AS
WITH

-- ==================================================
-- cte_drug_exposure: Drugドメイン変換
-- OMOP中間テーブルからdrug_exposure形式への変換処理
-- ==================================================
cte_drug_exposure_m AS (
    SELECT
        -- Primary Key: drug_exposure_id（連番付与）
--        ROW_NUMBER() OVER (ORDER BY person_id, start_date, type_category, source_value) AS drug_exposure_id,
        0 AS drug_exposure_id,  -- 確定テーブルには連番を付与すること 

        -- Patient Information: 患者情報
        person_id,
        person_source_value,

        -- Drug Concept Information: 薬剤概念情報
        concept_id AS drug_concept_id,
        concept_name AS drug_concept_name,
        concept_vocabulary_id AS drug_concept_vocabulary_id,
        concept_domain_id AS drug_concept_domain_id,

        -- Date Information: 投与日付情報
        start_date AS drug_exposure_start_date,
        start_datetime AS drug_exposure_start_datetime,
        end_date AS drug_exposure_end_date,
        end_datetime AS drug_exposure_end_datetime,
        verbatim_end_date,
        
        -- Type Information: 投与種別情報
        COALESCE(type_concept_id, 0) AS drug_type_concept_id,
        
        -- Clinical Information: 臨床情報
        stop_reason,
        refills,
        quantity,
        days_supply,
        sig,
        route_concept_id,
        route_concept_name,
        route_concept_vocabulary_id,
        route_concept_domain_id,
        lot_number,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        source_regvalue AS drug_source_value,
        source_concept_id AS drug_source_concept_id,
        route_source_regvalue,
        unit_source_regvalue AS dose_unit_source_value,

        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
        
    FROM :working_schema.stem_m
    WHERE domain_id = 'Drug'  -- Drugドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_drug_exposure_m;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_drug_exposure_m;
--SELECT * FROM :working_schema.v_drug_exposure_m LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.drug_exposure_m;
--INSERT INTO :working_schema.drug_exposure_m SELECT * FROM :working_schema.v_drug_exposure_m;
