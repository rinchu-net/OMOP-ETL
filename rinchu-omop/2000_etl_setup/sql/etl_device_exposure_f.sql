\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_device_exposure_f AS
WITH
cte_device_exposure_f AS (
    SELECT *
    FROM :working_schema.device_exposure_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND device_concept_id IS NOT NULL AND device_concept_id > 0
    AND device_concept_id IS NOT NULL
    AND device_exposure_start_date IS NOT NULL
    AND device_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_device_exposure_f;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_device_exposure_f;
--SELECT * FROM :working_schema.v_device_exposure_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.device_exposure_f;
--INSERT INTO :working_schema.device_exposure_f SELECT * FROM :working_schema.v_device_exposure_f;
