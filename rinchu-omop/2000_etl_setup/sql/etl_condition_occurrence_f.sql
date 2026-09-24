\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_condition_occurrence_f AS
WITH
cte_condition_occurrence_f AS (
    SELECT *
    FROM :working_schema.condition_occurrence_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND condition_concept_id IS NOT NULL AND condition_concept_id > 0
    AND condition_concept_id IS NOT NULL
    AND condition_start_date IS NOT NULL
    AND condition_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_condition_occurrence_f;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_condition_occurrence_f;
SELECT * FROM :working_schema.v_condition_occurrence_f LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.condition_occurrence_f;
INSERT INTO :working_schema.condition_occurrence_f SELECT * FROM :working_schema.v_condition_occurrence_f;
*/