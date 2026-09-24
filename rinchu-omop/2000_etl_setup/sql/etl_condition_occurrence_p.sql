\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_condition_occurrence_p AS
WITH
cte_condition_occurrence_p AS (
    SELECT
        -- Primary Key: condition_occurrence_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, condition_start_date, condition_type_concept_id, condition_source_value) AS condition_occurrence_id,

        -- Patient Information: 患者情報
        person_id,
        
        -- Concept Information: 概念情報
        condition_concept_id,
        
        -- Date Information: 日付情報
        condition_start_date,
        condition_start_datetime,
        condition_end_date,
        condition_end_datetime,
        
        -- Type Information: イベント種別情報
        condition_type_concept_id,
        
        -- Status Information: 状態情報
        condition_status_concept_id,
        
        -- Clinical Information: 臨床情報
        stop_reason,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        condition_source_value,
        condition_source_concept_id,
        condition_status_source_value
    FROM :working_schema.condition_occurrence_f
)

-- 最終SELECT
SELECT * FROM cte_condition_occurrence_p;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_condition_occurrence_p;
SELECT * FROM :working_schema.v_condition_occurrence_p LIMIT 100;

--- データ生成
TRUNCATE TABLE :production_schema.condition_occurrence;
INSERT INTO :production_schema.condition_occurrence SELECT * FROM :working_schema.v_condition_occurrence_p;
*/