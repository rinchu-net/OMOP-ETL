\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからOBSERVATIONテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからObservationドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のobservationテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（observation, measurement, condition_occurrence等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のObservationドメインイベント：
- 検査値データ
- 傷病名データ
- その他Observationドメインに分類される観察関連イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Observation'による抽出
2. カラムマッピング：LK → observation形式への変換
3. ID付与：observation_idの連番付与
4. 観察特有フィールド：文字列値・修飾子・数値等の適切な設定

【出力仕様】
- 形式: OMOP CDM v5.4 observationテーブル準拠
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: :working_schema.v_omopcommon_mapped（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_observation_m AS
WITH

-- ==================================================
-- cte_observation: Observationドメイン変換
-- LKからobservation形式への変換処理
-- ==================================================
cte_observation AS (
    SELECT
        -- Primary Key: observation_id（連番付与）
        --ROW_NUMBER() OVER (ORDER BY person_id, start_date, type_category, source_value) AS observation_id,
        0 AS observation_id,  -- 確定テーブルには連番を付与すること
        
        -- Patient Information: 患者情報
        person_id,
        person_source_value,
        
        -- Observation Concept Information: 観察項目概念情報
        concept_id AS observation_concept_id,
        concept_name AS observation_concept_name,
        concept_vocabulary_id AS observation_concept_vocabulary_id,
        concept_domain_id AS observation_concept_domain_id,
        
        -- Date Information: 観察日付情報
        start_date AS observation_date,
        start_datetime AS observation_datetime,
        
        -- Type Information: 観察種別情報
        COALESCE(type_concept_id, 0) AS observation_type_concept_id,
        
        -- Value Information: 観察値情報
        value_as_number,
        value_as_string,
        value_as_concept_id,
        value_as_concept_name,
        value_as_concept_vocabulary_id,
        value_as_concept_domain_id,
        
        -- Qualifier Information: 修飾子情報
        qualifier_concept_id,
        qualifier_concept_name,
        qualifier_concept_vocabulary_id,
        qualifier_concept_domain_id,
        
        -- Unit Information: 単位情報
        unit_concept_id,
        unit_concept_name,
        unit_concept_vocabulary_id,
        unit_concept_domain_id,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        source_regvalue AS observation_source_value,
        source_concept_id AS observation_source_concept_id,
        unit_source_regvalue,
        qualifier_source_regvalue,
        value_source_regvalue,
        
        -- Event Linkage Information: イベント連携情報（未使用）
        NULL::integer AS observation_event_id,
        NULL::integer AS obs_event_field_concept_id,

        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
        
    FROM :working_schema.stem_m
    WHERE domain_id = 'Observation'  -- Observationドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_observation;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_observation_m;
SELECT * FROM :working_schema.v_observation_m LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.observation_m;
INSERT INTO :working_schema.observation_m SELECT * FROM :working_schema.v_observation_m;
*/