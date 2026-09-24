\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_device_exposure_e AS
WITH
cte_device_exposure_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN device_concept_id IS NULL or device_concept_id = 0 THEN 'device_concept_id'
        WHEN device_concept_id IS NULL THEN 'device_concept_id'
        WHEN device_exposure_start_date IS NULL THEN 'device_exposure_start_date'
        WHEN device_type_concept_id IS NULL THEN 'device_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.device_exposure_m
    WHERE person_id IS NULL OR person_id = 0
--  OR device_concept_id IS NULL OR device_concept_id = 0
    OR device_concept_id IS NULL
    OR device_exposure_start_date IS NULL
    OR device_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_device_exposure_e;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_device_exposure_e;
--SELECT * FROM :working_schema.v_device_exposure_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.device_exposure_e;
--INSERT INTO :working_schema.device_exposure_e SELECT * FROM :working_schema.v_device_exposure_e;
