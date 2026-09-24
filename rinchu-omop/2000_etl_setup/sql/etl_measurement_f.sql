\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_measurement_f AS
WITH
cte_measurement_f AS (
    SELECT *
    FROM :working_schema.measurement_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND measurement_concept_id IS NOT NULL AND measurement_concept_id > 0
    AND measurement_concept_id IS NOT NULL
    AND measurement_date IS NOT NULL
    AND measurement_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_measurement_f;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_measurement_f;
--SELECT * FROM :working_schema.v_measurement_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.measurement_f;
--INSERT INTO :working_schema.measurement_f SELECT * FROM :working_schema.v_measurement_f;
