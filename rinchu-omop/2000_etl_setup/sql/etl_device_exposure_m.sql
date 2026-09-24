\set ON_ERROR_STOP on
/*
============================================================
OMOP中間テーブルからDEVICE_EXPOSUREテーブル生成ETLスクリプト
============================================================

【概要】
このスクリプトは、OMOP中間テーブルからDeviceドメインに属するイベントを抽出し、
OMOP CDM v5.4準拠のdevice_exposureテーブル形式に変換するETL処理を実行します。

【OMOP中間テーブルの役割】
OMOP中間テーブルは、単一のデータソースから複数のOMOP CDMテーブル
（device_exposure, measurement, observation等）のデータを効率的に生成するための
統一的な中間テーブルです。以下の利点を提供します：
- 概念マッピングの統一化（standard/non-standard concept対応）
- ドメイン判定による適切なテーブル振り分け
- データ品質管理の一元化
- ETLプロセスの標準化

【処理対象データ】
OMOP中間テーブル内のDeviceドメインイベント：
- 医療機器データ（使用）
- その他Deviceドメインに分類される機器関連イベント

【主要な変換処理】
1. ドメインフィルタリング：domain_id = 'Device'による抽出
2. カラムマッピング：LK → device_exposure形式への変換
3. ID付与：device_exposure_idの連番付与

【出力仕様】
- 形式: OMOP CDM v5.4 device_exposureテーブル準拠
- エンコーディング: UTF-8

【技術仕様】
- DB対応: PostgreSQL 12+, Amazon Redshift
- OMOP CDM: v5.4準拠
- 処理方式: VIEW（リアルタイム変換）
- 依存関係: stage.v_stem（OMOP中間テーブル基盤ビュー）
*/

CREATE OR REPLACE VIEW :working_schema.v_device_exposure_m AS
WITH

-- ==================================================
-- cte_device_exposure: Drugドメイン変換
-- OMOP中間テーブルからdevice_exposure形式への変換処理
-- ==================================================
cte_device_exposure_m AS (
    SELECT
        0 AS device_exposure_id,

        -- Patient Information: 患者情報
        person_id,
        person_source_value,

        -- Drug Concept Information: 医療機器concept情報
        concept_id AS device_concept_id,
        concept_name AS device_concept_name,
        concept_vocabulary_id AS device_concept_vocabulary_id,
        concept_domain_id AS device_concept_domain_id,

        -- Date Information: 使用日付情報
        start_date AS device_exposure_start_date,
        start_datetime AS device_exposure_start_datetime,
        end_date AS device_exposure_end_date,
        end_datetime AS device_exposure_end_datetime,
        
        -- Type Information: 種別情報
        COALESCE(type_concept_id, 0) AS device_type_concept_id,
        
        -- Device Information: 機器情報
        NULL::varchar AS unique_device_id,
        NULL::varchar AS production_id,
        quantity,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        source_regvalue AS device_source_value,
        source_concept_id AS device_source_concept_id,
        unit_concept_id AS unit_concept_id,
        unit_source_regvalue AS unit_source_value,
        unit_source_concept_id AS unit_source_concept_id,

        mapped_source_vocabulary_id,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
        
    FROM :working_schema.stem_m
    WHERE domain_id = 'Device'  -- Drugドメインのみ抽出
)

-- 最終SELECT
SELECT * FROM cte_device_exposure_m;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_device_exposure_m;
--SELECT * FROM :working_schema.v_device_exposure_m LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.device_exposure_m;
--INSERT INTO :working_schema.device_exposure_m SELECT * FROM :working_schema.v_device_exposure_m;
