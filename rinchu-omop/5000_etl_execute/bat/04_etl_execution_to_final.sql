\set ON_ERROR_STOP on
---------------------------------------------------------------------
-- ETL Execution SQL for RINCHU Project
-- Created on: 2025/11/10
---------------------------------------------------------------------
-- Proccedure:
-- 1. execute person staging process and finalize person_f table
-- 2. execute visit_occurrence staging process and finalize visit_occurrence_f and visit_detail_f tables
-- 3. execute death staging process and finalize death_f table
-- 4. execute common staging process for PatientDisease, ObservationResult, PrescriptionData, InjectionData tables
-- (check _e tables for error records after each staging process)
-- (add source_to_concept_map map as needed before executing domain staging processes)
-- 5. execute condition_occurrence staging process and finalize condition_occurrence_f and condition_occurrence_e tables
-- 6. execute drug_exposure staging process and finalize drug_exposure_f and drug_exposure_e tables
-- 7. execute procedure_occurrence staging process and finalize procedure_occurrence_f and procedure_occurrence_e tables
-- 8. execute measurement staging process and finalize measurement_f and measurement_e tables
-- 9. execute observation staging process and finalize observation_f and observation_e tables
-- 10. execute specimen staging process and finalize specimen_f and specimen_e tables
---------------------------------------------------------------------

----------------------------------
-- condition_occurrence staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(Condition) -> condition_occurrence_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(Condition) -> condition_occurrence_m
TRUNCATE TABLE :working_schema.condition_occurrence_m;
INSERT INTO :working_schema.condition_occurrence_m SELECT * FROM :working_schema.v_condition_occurrence_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(Condition) -> condition_occurrence_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] condition_occurrence_m -> condition_occurrence_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo condition_occurrence_m -> condition_occurrence_f
TRUNCATE TABLE :working_schema.condition_occurrence_f;
INSERT INTO :working_schema.condition_occurrence_f SELECT * FROM :working_schema.v_condition_occurrence_f;
DO $$ BEGIN RAISE NOTICE '[END] condition_occurrence_m -> condition_occurrence_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] condition_occurrence_m -> condition_occurrence_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo condition_occurrence_m -> condition_occurrence_e
TRUNCATE TABLE :working_schema.condition_occurrence_e;
INSERT INTO :working_schema.condition_occurrence_e SELECT * FROM :working_schema.v_condition_occurrence_e;
DO $$ BEGIN RAISE NOTICE '[END] condition_occurrence_m -> condition_occurrence_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- drug_exposure staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(Drug) -> drug_exposure_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(Drug) -> drug_exposure_m
TRUNCATE TABLE :working_schema.drug_exposure_m;
INSERT INTO :working_schema.drug_exposure_m SELECT * FROM :working_schema.v_drug_exposure_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(Drug) -> drug_exposure_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] drug_exposure_m -> drug_exposure_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo drug_exposure_m -> drug_exposure_f
TRUNCATE TABLE :working_schema.drug_exposure_f;
INSERT INTO :working_schema.drug_exposure_f SELECT * FROM :working_schema.v_drug_exposure_f;
DO $$ BEGIN RAISE NOTICE '[END] drug_exposure_m -> drug_exposure_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] drug_exposure_m -> drug_exposure_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo drug_exposure_m -> drug_exposure_e
TRUNCATE TABLE :working_schema.drug_exposure_e;
INSERT INTO :working_schema.drug_exposure_e SELECT * FROM :working_schema.v_drug_exposure_e;
DO $$ BEGIN RAISE NOTICE '[END] drug_exposure_m -> drug_exposure_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- device_exposure staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(Device) -> device_exposure_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(Device) -> device_exposure_m
TRUNCATE TABLE :working_schema.device_exposure_m;
INSERT INTO :working_schema.device_exposure_m SELECT * FROM :working_schema.v_device_exposure_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(Device) -> device_exposure_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] device_exposure_m -> device_exposure_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo device_exposure_m -> device_exposure_f
TRUNCATE TABLE :working_schema.device_exposure_f;
INSERT INTO :working_schema.device_exposure_f SELECT * FROM :working_schema.v_device_exposure_f;
DO $$ BEGIN RAISE NOTICE '[END] device_exposure_m -> device_exposure_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] device_exposure_m -> device_exposure_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo device_exposure_m -> device_exposure_e
TRUNCATE TABLE :working_schema.device_exposure_e;
INSERT INTO :working_schema.device_exposure_e SELECT * FROM :working_schema.v_device_exposure_e;
DO $$ BEGIN RAISE NOTICE '[END] device_exposure_m -> device_exposure_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- measurement staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(Measurement) -> measurement_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(Measurement) -> measurement_m
TRUNCATE TABLE :working_schema.measurement_m;
INSERT INTO :working_schema.measurement_m SELECT * FROM :working_schema.v_measurement_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(Measurement) -> measurement_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] measurement_m -> measurement_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo measurement_m -> measurement_f
TRUNCATE TABLE :working_schema.measurement_f;
INSERT INTO :working_schema.measurement_f SELECT * FROM :working_schema.v_measurement_f;
DO $$ BEGIN RAISE NOTICE '[END] measurement_m -> measurement_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] measurement_m -> measurement_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo measurement_m -> measurement_e
TRUNCATE TABLE :working_schema.measurement_e;
INSERT INTO :working_schema.measurement_e SELECT * FROM :working_schema.v_measurement_e;
DO $$ BEGIN RAISE NOTICE '[END] measurement_m -> measurement_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- observation staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(Observation) -> observation_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(Observation) -> observation_m
TRUNCATE TABLE :working_schema.observation_m;
INSERT INTO :working_schema.observation_m SELECT * FROM :working_schema.v_observation_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(Observation) -> observation_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] observation_m -> observation_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo observation_m -> observation_f
TRUNCATE TABLE :working_schema.observation_f;
INSERT INTO :working_schema.observation_f SELECT * FROM :working_schema.v_observation_f;
DO $$ BEGIN RAISE NOTICE '[END] observation_m -> observation_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] observation_m -> observation_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo observation_m -> observation_e
TRUNCATE TABLE :working_schema.observation_e;
INSERT INTO :working_schema.observation_e SELECT * FROM :working_schema.v_observation_e;
DO $$ BEGIN RAISE NOTICE '[END] observation_m -> observation_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- procedure_occurrence staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(Procedure) -> procedure_occurrence_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(Procedure) -> procedure_occurrence_m
TRUNCATE TABLE :working_schema.procedure_occurrence_m;
INSERT INTO :working_schema.procedure_occurrence_m SELECT * FROM :working_schema.v_procedure_occurrence_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(Procedure) -> procedure_occurrence_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] procedure_occurrence_m -> procedure_occurrence_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo procedure_occurrence_m -> procedure_occurrence_f
TRUNCATE TABLE :working_schema.procedure_occurrence_f;
INSERT INTO :working_schema.procedure_occurrence_f SELECT * FROM :working_schema.v_procedure_occurrence_f;
DO $$ BEGIN RAISE NOTICE '[END] procedure_occurrence_m -> procedure_occurrence_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] procedure_occurrence_m -> procedure_occurrence_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo procedure_occurrence_m -> procedure_occurrence_e
TRUNCATE TABLE :working_schema.procedure_occurrence_e;
INSERT INTO :working_schema.procedure_occurrence_e SELECT * FROM :working_schema.v_procedure_occurrence_e;
DO $$ BEGIN RAISE NOTICE '[END] procedure_occurrence_m -> procedure_occurrence_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- specimen staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem_source(specimen) -> specimen_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem_source(specimen) -> specimen_m
TRUNCATE TABLE :working_schema.specimen_m;
INSERT INTO :working_schema.specimen_m SELECT * FROM :working_schema.v_specimen_m;
DO $$ BEGIN RAISE NOTICE '[END] stem_source(specimen) -> specimen_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] specimen_m -> specimen_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo specimen_m -> specimen_f
TRUNCATE TABLE :working_schema.specimen_f;
INSERT INTO :working_schema.specimen_f SELECT * FROM :working_schema.v_specimen_f;
DO $$ BEGIN RAISE NOTICE '[END] specimen_m -> specimen_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] specimen_m -> specimen_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo specimen_m -> specimen_e
TRUNCATE TABLE :working_schema.specimen_e;
INSERT INTO :working_schema.specimen_e SELECT * FROM :working_schema.v_specimen_e;
DO $$ BEGIN RAISE NOTICE '[END] specimen_m -> specimen_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- observation_period staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] v_observation_period_f -> observation_period_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo v_observation_period_f -> observation_period_f
TRUNCATE TABLE :working_schema.observation_period_f;
INSERT INTO :working_schema.observation_period_f SELECT * FROM :working_schema.v_observation_period_f;
DO $$ BEGIN RAISE NOTICE '[END] v_observation_period_f -> observation_period_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

----------------------------------
-- condition_era staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] v_condition_era_f -> condition_era_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo v_condition_era_f -> condition_era_f
TRUNCATE TABLE :working_schema.condition_era_f;
INSERT INTO :working_schema.condition_era_f SELECT * FROM :working_schema.v_condition_era_f;
DO $$ BEGIN RAISE NOTICE '[END] v_condition_era_f -> condition_era_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

--------------------------------------------------------------------
-- drug_era と dose_eraはviewではパフォーマンス問題で実行できないため
-- 中間テーブルの生成を含む個別処理を記述したSQLファイルを別途実行して生成する
--------------------------------------------------------------------

----------------------------------
-- drug_era staging tables
----------------------------------
--\echo =====================================================================
--DO $$ BEGIN RAISE NOTICE '[START] v_drug_era_f -> drug_era_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
--\echo v_drug_era_f -> drug_era_f
--TRUNCATE TABLE :working_schema.drug_era_f;
--INSERT INTO :working_schema.drug_era_f SELECT * FROM :working_schema.v_drug_era_f;
--DO $$ BEGIN RAISE NOTICE '[END] v_drug_era_f -> drug_era_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
--\echo =====================================================================

----------------------------------
-- dose_era staging tables
----------------------------------
--\echo =====================================================================
--DO $$ BEGIN RAISE NOTICE '[START] v_dose_era_f -> dose_era_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
--\echo v_dose_era_f -> dose_era_f
--TRUNCATE TABLE :working_schema.dose_era_f;
--INSERT INTO :working_schema.dose_era_f SELECT * FROM :working_schema.v_dose_era_f;
--DO $$ BEGIN RAISE NOTICE '[END] v_dose_era_f -> dose_era_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
--\echo =====================================================================

----------------------------------
-- ANALYZE final tables (post-INSERT)
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] ANALYZE final tables | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
ANALYZE VERBOSE :working_schema.condition_occurrence_m;
ANALYZE VERBOSE :working_schema.condition_occurrence_f;
ANALYZE VERBOSE :working_schema.drug_exposure_m;
ANALYZE VERBOSE :working_schema.drug_exposure_f;
ANALYZE VERBOSE :working_schema.device_exposure_m;
ANALYZE VERBOSE :working_schema.device_exposure_f;
ANALYZE VERBOSE :working_schema.measurement_m;
ANALYZE VERBOSE :working_schema.measurement_f;
ANALYZE VERBOSE :working_schema.measurement_e;
ANALYZE VERBOSE :working_schema.observation_m;
ANALYZE VERBOSE :working_schema.observation_f;
ANALYZE VERBOSE :working_schema.procedure_occurrence_m;
ANALYZE VERBOSE :working_schema.procedure_occurrence_f;
ANALYZE VERBOSE :working_schema.specimen_m;
ANALYZE VERBOSE :working_schema.specimen_f;
ANALYZE VERBOSE :working_schema.observation_period_f;
ANALYZE VERBOSE :working_schema.condition_era_f;
DO $$ BEGIN RAISE NOTICE '[END] ANALYZE final tables | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
