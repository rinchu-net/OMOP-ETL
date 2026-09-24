\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_measurement_e AS
WITH
cte_measurement_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN measurement_concept_id IS NULL or measurement_concept_id = 0 THEN 'measurement_concept_id'
        WHEN measurement_concept_id IS NULL THEN 'measurement_concept_id'
        WHEN measurement_date IS NULL THEN 'measurement_date'
        WHEN measurement_type_concept_id IS NULL THEN 'measurement_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.measurement_m
    WHERE person_id IS NULL OR person_id = 0
--  OR measurement_concept_id IS NULL OR measurement_concept_id = 0
    OR measurement_concept_id IS NULL
    OR measurement_date IS NULL
    OR measurement_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_measurement_e;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_measurement_e;
--SELECT * FROM :working_schema.v_measurement_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.measurement_e;
--INSERT INTO :working_schema.measurement_e SELECT * FROM :working_schema.v_measurement_e;
