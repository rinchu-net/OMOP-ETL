\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_specimen_e AS
WITH
cte_specimen_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN specimen_concept_id IS NULL or specimen_concept_id = 0 THEN 'specimen_concept_id'
        WHEN specimen_concept_id IS NULL THEN 'specimen_concept_id'
        WHEN specimen_date IS NULL THEN 'specimen_date'
        WHEN specimen_type_concept_id IS NULL THEN 'specimen_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.specimen_m
    WHERE person_id IS NULL OR person_id = 0
--  OR specimen_concept_id IS NULL OR specimen_concept_id = 0
    OR specimen_concept_id IS NULL
    OR specimen_date IS NULL
    OR specimen_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_specimen_e;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_specimen_e;
SELECT * FROM :working_schema.v_specimen_e LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.specimen_e;
INSERT INTO :working_schema.specimen_e SELECT * FROM :working_schema.v_specimen_e;
*/