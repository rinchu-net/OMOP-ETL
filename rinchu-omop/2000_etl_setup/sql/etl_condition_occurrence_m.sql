\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからCONDITION_OCCURRENCEテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからConditionドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のcondition_occurrenceテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（condition_occurrence, measurement, observation等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のConditionドメインイベント：
- 傷病名データ（病名由来）
- 診断データ（検査結果由来）
- その他Conditionドメインに分類される臨床イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Condition'による抽出
2. カラムマッピング：OMOP中間テーブル → condition_occurrence形式への変換
3. ID付与：condition_occurrence_idの連番付与
4. データ型変換：各フィールドの適切なデータ型確保

【出力仕様】
- 形式: OMOP CDM v5.4 condition_occurrenceテーブル準拠
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: OMOP中間テーブル（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_condition_occurrence_m AS
WITH

-- ==================================================
-- cte_condition_occurrence: Conditionドメイン変換
-- OMOP中間テーブルからcondition_occurrence形式への変換処理
-- ==================================================
cte_condition_occurrence_m AS (
    SELECT
        -- Primary Key: condition_occurrence_id（連番付与）
        --ROW_NUMBER() OVER (ORDER BY person_id, start_date, type_category, source_value) AS condition_occurrence_id,
        0 AS condition_occurrence_id,  -- 確定テーブルには連番を付与すること

        -- Patient Information: 患者情報
        person_id,
        person_source_value,
        
        -- Concept Information: 概念情報
        concept_id AS condition_concept_id,
        concept_name AS condition_concept_name,
        concept_vocabulary_id AS condition_concept_vocabulary_id,
        concept_domain_id AS condition_concept_domain_id,
        
        -- Date Information: 日付情報
        start_date AS condition_start_date,
        start_datetime AS condition_start_datetime,
        end_date AS condition_end_date,
        end_datetime AS condition_end_datetime,
        
        -- Type Information: イベント種別情報
        COALESCE(type_concept_id, 0) AS condition_type_concept_id,
        
        -- Status Information: 状態情報
        status_concept_id AS condition_status_concept_id,
        
        -- Clinical Information: 臨床情報
        stop_reason,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        source_regvalue AS condition_source_value,
        source_concept_id AS condition_source_concept_id,
        status_source_regvalue AS condition_status_source_value,
        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid      
    FROM :working_schema.stem_m
    WHERE domain_id = 'Condition'  -- Conditionドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_condition_occurrence_m;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_condition_occurrence_m;
SELECT * FROM :working_schema.v_condition_occurrence_m LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.condition_occurrence_m;
INSERT INTO :working_schema.condition_occurrence_m SELECT * FROM :working_schema.v_condition_occurrence_m;
*/