-- ===============================================================
-- 90_clean_final.sql
--   04_etl_execution_to_final.sql の INSERT 対象テーブル を TRUNCATE する。
--   :working_schema は呼び出し側 (-v working_schema=...) で指定。
-- ===============================================================

\echo ==== TRUNCATE final stage tables in :working_schema ====

TRUNCATE TABLE :working_schema.condition_occurrence_m;
TRUNCATE TABLE :working_schema.condition_occurrence_f;
TRUNCATE TABLE :working_schema.condition_occurrence_e;

TRUNCATE TABLE :working_schema.drug_exposure_m;
TRUNCATE TABLE :working_schema.drug_exposure_f;
TRUNCATE TABLE :working_schema.drug_exposure_e;

TRUNCATE TABLE :working_schema.device_exposure_m;
TRUNCATE TABLE :working_schema.device_exposure_f;
TRUNCATE TABLE :working_schema.device_exposure_e;

TRUNCATE TABLE :working_schema.measurement_m;
TRUNCATE TABLE :working_schema.measurement_f;
TRUNCATE TABLE :working_schema.measurement_e;

TRUNCATE TABLE :working_schema.observation_m;
TRUNCATE TABLE :working_schema.observation_f;
TRUNCATE TABLE :working_schema.observation_e;

TRUNCATE TABLE :working_schema.procedure_occurrence_m;
TRUNCATE TABLE :working_schema.procedure_occurrence_f;
TRUNCATE TABLE :working_schema.procedure_occurrence_e;

TRUNCATE TABLE :working_schema.specimen_m;
TRUNCATE TABLE :working_schema.specimen_f;
TRUNCATE TABLE :working_schema.specimen_e;

TRUNCATE TABLE :working_schema.observation_period_f;

TRUNCATE TABLE :working_schema.condition_era_f;
-- 04_etl_execution_to_final.sql でコメントアウトされている INSERT 対象 (参考)
--TRUNCATE TABLE :working_schema.drug_era_f;
--TRUNCATE TABLE :working_schema.dose_era_f;

\echo ==== Done ====
