\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからPROCEDURE_OCCURRENCEテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからProcedureドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のprocedure_occurrenceテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（procedure_occurrence, measurement, observation等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のProcedureドメインイベント：
- 診療行為データ（医科・DPC・歯科レセプト由来）
- 手術記録（手術・処置・麻酔等）
- 検査・画像診断（検査・病理・画像診断等）
- その他Procedureドメインに分類される診療行為関連イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Procedure'による抽出
2. カラムマッピング：LK → procedure_occurrence形式への変換
3. ID付与：procedure_occurrence_idの連番付与
4. 診療行為特有フィールド：実施回数・修飾子等の適切な設定

【出力仕様】
- 形式: OMOP CDM v5.4 procedure_occurrenceテーブル準拠
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: :working_schema.v_stem（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_procedure_occurrence_m AS
WITH

-- ==================================================
-- cte_procedure_occurrence: Procedureドメイン変換
-- OMOP中間テーブルからprocedure_occurrence形式への変換処理
-- ==================================================
cte_procedure_occurrence AS (
    SELECT
        -- Primary Key: procedure_occurrence_id（連番付与）
        --ROW_NUMBER() OVER (ORDER BY person_id, start_date, type_category, source_value) AS procedure_occurrence_id,
        0 AS procedure_occurrence_id,  -- 確定テーブルには連番を付与すること
        
        -- Patient Information: 患者情報
        person_id,
        person_source_value,
        
        -- Procedure Concept Information: 診療行為概念情報
        concept_id AS procedure_concept_id,
        concept_name AS procedure_concept_name,
        concept_vocabulary_id AS procedure_concept_vocabulary_id,
        concept_domain_id AS procedure_concept_domain_id,
        
        -- Date Information: 実施日付情報
        start_date AS procedure_date,
        start_datetime AS procedure_datetime,
        end_date AS procedure_end_date,
        end_datetime AS procedure_end_datetime,
        
        -- Type Information: 実施種別情報
        COALESCE(type_concept_id, 0) AS procedure_type_concept_id,
        
        -- Procedure Specific Information: 診療行為固有情報
        modifier_concept_id,
        modifier_concept_name,
        modifier_concept_vocabulary_id,
        modifier_concept_domain_id,
        quantity,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        source_regvalue AS procedure_source_value,
        source_concept_id AS procedure_source_concept_id,
        modifier_source_regvalue AS modifier_source_value,

        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
        
    FROM :working_schema.stem_m
    WHERE domain_id = 'Procedure'  -- Procedureドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_procedure_occurrence;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_procedure_occurrence_m;
SELECT * FROM :working_schema.v_procedure_occurrence_m LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.procedure_occurrence_m;
INSERT INTO :working_schema.procedure_occurrence_m SELECT * FROM :working_schema.v_procedure_occurrence_m;
*/