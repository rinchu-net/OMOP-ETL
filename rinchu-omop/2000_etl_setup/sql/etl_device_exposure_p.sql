\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_device_exposure_p AS
WITH

-- ==================================================
-- cte_device_exposure: deviceドメイン変換
-- OMOP中間テーブルからdevice_exposure形式への変換処理
-- ==================================================
cte_device_exposure_p AS (
    SELECT
        -- Primary Key: device_exposure_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, device_exposure_start_date, device_type_concept_id, device_source_value) AS device_exposure_id,

        -- Patient Information: 患者情報
        person_id,

        -- device Concept Information: 医療機器concept情報
        device_concept_id,

        -- Date Information: 使用日付情報
        device_exposure_start_date,
        device_exposure_start_datetime,
        device_exposure_end_date,
        device_exposure_end_datetime,
        
        -- Type Information: 投与種別情報
        device_type_concept_id,
        
        -- device Information: 機器情報
        unique_device_id,
        production_id,
        quantity,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        device_source_value,
        device_source_concept_id,
        unit_concept_id,
        unit_source_value,
        unit_source_concept_id

    FROM :working_schema.device_exposure_f
)

-- 最終SELECT
SELECT * FROM cte_device_exposure_p;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_device_exposure_p;
--SELECT * FROM :working_schema.v_device_exposure_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.device_exposure;
--INSERT INTO :production_schema.device_exposure SELECT * FROM :working_schema.v_device_exposure_p;
