\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_procedure_occurrence_f AS
WITH
cte_procedure_occurrence_f AS (
    SELECT *
    FROM :working_schema.procedure_occurrence_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND procedure_concept_id IS NOT NULL AND procedure_concept_id > 0
    AND procedure_concept_id IS NOT NULL
    AND procedure_date IS NOT NULL
    AND procedure_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_procedure_occurrence_f;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_procedure_occurrence_f;
SELECT * FROM :working_schema.v_procedure_occurrence_f LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.procedure_occurrence_f;
INSERT INTO :working_schema.procedure_occurrence_f SELECT * FROM :working_schema.v_procedure_occurrence_f;
*/