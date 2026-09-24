\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_condition_occurrence_e AS
WITH
cte_condition_occurrence_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN condition_concept_id IS NULL or condition_concept_id = 0 THEN 'condition_concept_id'
        WHEN condition_concept_id IS NULL THEN 'condition_concept_id'
        WHEN condition_start_date IS NULL THEN 'condition_start_date'
        WHEN condition_type_concept_id IS NULL THEN 'condition_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.condition_occurrence_m
    WHERE person_id IS NULL OR person_id = 0
--  OR condition_concept_id IS NULL OR condition_concept_id = 0
    OR condition_concept_id IS NULL
    OR condition_start_date IS NULL
    OR condition_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_condition_occurrence_e;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_condition_occurrence_e;
--SELECT * FROM :working_schema.v_condition_occurrence_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.condition_occurrence_e;
--INSERT INTO :working_schema.condition_occurrence_e SELECT * FROM :working_schema.v_condition_occurrence_e;
