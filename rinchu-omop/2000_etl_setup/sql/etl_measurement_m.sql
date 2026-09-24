\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからMEASUREMENTテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからMeasurementドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のmeasurementテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（measurement, observation, condition_occurrence等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のMeasurementドメインイベント：
- 検査値データ
- その他Measurementドメインに分類される測定値関連イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Measurement'による抽出
2. カラムマッピング：OMOP中間テーブル → measurement形式への変換
3. ID付与：measurement_idの連番付与
4. 測定値特有フィールド：数値・単位・基準値等の適切な設定

【出力仕様】
- 形式: OMOP CDM v5.4 measurementテーブル準拠
- 文字数制限: 30,000文字以内（Redshift実行制限対応）
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: :working_schema.v_omopcommon_mapped（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_measurement_m AS
WITH

-- ==================================================
-- cte_measurement: Measurementドメイン変換
-- OMOP中間テーブルからmeasurement形式への変換処理
-- ==================================================
cte_measurement AS (
    SELECT
        -- Primary Key: measurement_id（連番付与）
        --ROW_NUMBER() OVER (ORDER BY person_id, start_date, type_category, source_value) AS measurement_id,
        0 AS measurement_id,  -- 確定テーブルには連番を付与すること

        -- Patient Information: 患者情報
        person_id,
        person_source_value,
        
        -- Measurement Concept Information: 測定項目概念情報
        concept_id AS measurement_concept_id,
        concept_name AS measurement_concept_name,
        concept_vocabulary_id AS measurement_concept_vocabulary_id,
        concept_domain_id AS measurement_concept_domain_id,

        -- Date Information: 測定日付情報
        start_date AS measurement_date,
        start_datetime AS measurement_datetime,
        start_time AS measurement_time,
        
        -- Type Information: 測定種別情報
        COALESCE(type_concept_id, 0) AS measurement_type_concept_id,
        
        -- Operator Information: 演算子情報（未使用）
        operator_concept_id,
        operator_concept_name,
        operator_concept_vocabulary_id,
        operator_concept_domain_id,
        
        -- Value Information: 測定値情報
        value_as_number,
        value_as_concept_id,
        value_as_concept_name,
        value_as_concept_vocabulary_id,
        value_as_concept_domain_id,
        
        -- Unit Information: 単位情報
        unit_concept_id,
        unit_concept_name,
        unit_concept_vocabulary_id,
        unit_concept_domain_id,

        -- Reference Range Information: 基準値情報
        range_low,
        range_high,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        source_regvalue AS measurement_source_value,
        source_concept_id AS measurement_source_concept_id,
        unit_source_regvalue AS unit_source_value,
        unit_source_concept_id,
        value_source_regvalue AS value_source_value,
        operator_source_regvalue AS operator_source_value,
        
        -- Event Linkage Information: イベント連携情報（未使用）
        NULL::integer AS measurement_event_id,
        NULL::integer AS meas_event_field_concept_id,

        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
        
    FROM :working_schema.stem_m
    WHERE domain_id = 'Measurement'  -- Measurementドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_measurement;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_measurement_m;
SELECT * FROM :working_schema.v_measurement_m LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.measurement_m;
INSERT INTO :working_schema.measurement_m SELECT * FROM :working_schema.v_measurement_m;
*/