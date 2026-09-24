\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからSPECIMENテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからSpecimenドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のspecimenテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（specimen, observation, condition_occurrence等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のSpecimenドメインイベント：
- 検査値データ
- その他Specimenドメインに分類される測定値関連イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Specimen'による抽出
2. カラムマッピング：OMOP中間テーブル → Specimen形式への変換
3. ID付与：Specimen_idの連番付与
4. 測定値特有フィールド：数値・単位・基準値等の適切な設定

【出力仕様】
- 形式: OMOP CDM v5.4 specimenテーブル準拠
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: :working_schema.v_stem（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_specimen_m AS
WITH

-- ==================================================
-- cte_specimen: Specimenドメイン変換
-- OMOP中間テーブルからspecimen形式への変換処理
-- ==================================================
cte_specimen AS (
    SELECT
        -- Primary Key: specimen_id（連番付与）
        --ROW_NUMBER() OVER (ORDER BY person_id, start_date, type_category, source_value) AS specimen_id,
        0 AS specimen_id,  -- 確定テーブルには連番を付与すること

        -- Patient Information: 患者情報
        person_id,
        person_source_value,
        
        -- Specimen Concept Information: 検体概念情報
        concept_id AS specimen_concept_id,
        concept_name AS specimen_concept_name,
        concept_vocabulary_id AS specimen_concept_vocabulary_id,
        concept_domain_id AS specimen_concept_domain_id,

        -- Type Information: 測定種別情報
        COALESCE(type_concept_id, 0) AS specimen_type_concept_id,
        
        -- Date Information: 採取日付情報
        start_date AS specimen_date,
        start_datetime AS specimen_datetime,
        
        -- Quantity Information: 採取量情報
        quantity,

        -- Unit Information: 単位情報
        unit_concept_id,
        unit_concept_name,
        unit_concept_vocabulary_id,
        unit_concept_domain_id,

        -- Anatomic Site Information: 解剖学的部位情報
        anatomic_site_concept_id,
        anatomic_site_concept_name,
        anatomic_site_concept_vocabulary_id,
        anatomic_site_concept_domain_id,
        
        -- Disease Status Information: 疾患状態情報
        status_concept_id AS disease_status_concept_id,
        status_concept_name AS disease_status_concept_name,
        status_concept_vocabulary_id AS disease_status_concept_vocabulary_id,
        status_concept_domain_id AS disease_status_concept_domain_id,

        -- Source Information: ソース情報
        specimen_source_id,
        source_regvalue AS specimen_source_value,
        unit_source_regvalue AS unit_source_value,
        anatomic_site_source_regvalue AS anatomic_site_source_value,
        status_source_regvalue AS disease_status_source_value,

        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
        
    FROM :working_schema.stem_m
    WHERE domain_id = 'Specimen'  -- Specimenドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_specimen;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_specimen_m;
SELECT * FROM :working_schema.v_specimen_m LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.specimen_m;
INSERT INTO :working_schema.specimen_m SELECT * FROM :working_schema.v_specimen_m;
*/