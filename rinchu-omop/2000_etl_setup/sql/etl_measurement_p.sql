\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_measurement_p AS
WITH

cte_measurement AS (
    SELECT
        -- Primary Key: measurement_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, measurement_date, measurement_type_concept_id, measurement_source_value) AS measurement_id,

        -- Patient Information: 患者情報
        person_id,
        
        -- Measurement Concept Information: 測定項目概念情報
        measurement_concept_id,

        -- Date Information: 測定日付情報
        measurement_date,
        measurement_datetime,
        measurement_time,
        
        -- Type Information: 測定種別情報
        measurement_type_concept_id,
        
        -- Operator Information: 演算子情報
        operator_concept_id,
        
        -- Value Information: 測定値情報
        value_as_number,
        value_as_concept_id,
        
        -- Unit Information: 単位情報
        unit_concept_id,

        -- Reference Range Information: 基準値情報
        range_low,
        range_high,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        measurement_source_value,
        measurement_source_concept_id,
        unit_source_value,
        unit_source_concept_id,
        value_source_value,
        
        -- Event Linkage Information: イベント連携情報（未使用）
        NULL::integer AS measurement_event_id,
        NULL::integer AS meas_event_field_concept_id
        
    FROM :working_schema.measurement_f
)

-- 最終SELECT
SELECT * FROM cte_measurement;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_measurement_p;
SELECT * FROM :working_schema.v_measurement_p LIMIT 100;

--- データ生成
TRUNCATE TABLE :production_schema.measurement;
INSERT INTO :production_schema.measurement SELECT * FROM :working_schema.v_measurement_p;
*/