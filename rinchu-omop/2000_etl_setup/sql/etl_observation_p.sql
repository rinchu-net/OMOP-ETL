\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_observation_p AS
WITH

cte_observation AS (
    SELECT
        -- Primary Key: observation_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, observation_date, observation_type_concept_id, observation_source_value) AS observation_id,
        
        -- Patient Information: 患者情報
        person_id,
        
        -- Observation Concept Information: 観察項目概念情報
        observation_concept_id,
        
        -- Date Information: 観察日付情報
        observation_date,
        observation_datetime,
        
        -- Type Information: 観察種別情報
        observation_type_concept_id,
        
        -- Value Information: 観察値情報
        value_as_number,
        value_as_string,
        value_as_concept_id,
        
        -- Qualifier Information: 修飾子情報
        qualifier_concept_id,
        
        -- Unit Information: 単位情報
        unit_concept_id,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        observation_source_value,
        observation_source_concept_id,
        unit_source_value,
        qualifier_source_value,
        value_source_value,
        
        -- Event Linkage Information: イベント連携情報（未使用）
        NULL::integer AS observation_event_id,
        NULL::integer AS obs_event_field_concept_id
        
    FROM :working_schema.observation_f
)

-- 最終SELECT
SELECT * FROM cte_observation;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_observation_p;
SELECT * FROM :working_schema.v_observation_p LIMIT 100;

--- データ生成
TRUNCATE TABLE :production_schema.observation;
INSERT INTO :production_schema.observation SELECT * FROM :working_schema.v_observation_p;
*/