\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_procedure_occurrence_e AS
WITH
cte_procedure_occurrence_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN procedure_concept_id IS NULL or procedure_concept_id = 0 THEN 'procedure_concept_id'
        WHEN procedure_concept_id IS NULL THEN 'procedure_concept_id'
        WHEN procedure_date IS NULL THEN 'procedure_date'
        WHEN procedure_type_concept_id IS NULL THEN 'procedure_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.procedure_occurrence_m
    WHERE person_id IS NULL OR person_id = 0
--  OR procedure_concept_id IS NULL OR procedure_concept_id = 0
    OR procedure_concept_id IS NULL
    OR procedure_date IS NULL
    OR procedure_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_procedure_occurrence_e;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_procedure_occurrence_e;
SELECT * FROM :working_schema.v_procedure_occurrence_e LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.procedure_occurrence_e;
INSERT INTO :working_schema.procedure_occurrence_e SELECT * FROM :working_schema.v_procedure_occurrence_e;
*/