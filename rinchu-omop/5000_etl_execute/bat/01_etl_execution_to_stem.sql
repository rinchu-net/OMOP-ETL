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
-- person staging tables
----------------------------------

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] PatientIdentification -> person_s | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo PatientIdentification -> person_s
TRUNCATE TABLE :working_schema.person_s;
INSERT INTO :working_schema.person_s SELECT * FROM :working_schema.v_person_s;
DO $$ BEGIN RAISE NOTICE '[END] PatientIdentification -> person_s | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.person_s;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] person_s -> person_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo person_s -> person_m
TRUNCATE TABLE :working_schema.person_m;
INSERT INTO :working_schema.person_m SELECT * FROM :working_schema.v_person_m;
DO $$ BEGIN RAISE NOTICE '[END] person_s -> person_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.person_m;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] person_m -> person_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo person_m -> person_f
TRUNCATE TABLE :working_schema.person_f;
INSERT INTO :working_schema.person_f SELECT * FROM :working_schema.v_person_f;
DO $$ BEGIN RAISE NOTICE '[END] person_m -> person_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.person_f;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] person_m -> person_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo person_m -> person_e
TRUNCATE TABLE :working_schema.person_e;
INSERT INTO :working_schema.person_e SELECT * FROM :working_schema.v_person_e;
DO $$ BEGIN RAISE NOTICE '[END] person_m -> person_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.person_e;

----------------------------------
-- visit_occurrence staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] PatientVisit -> visit_occurrence_s | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo PatientVisit -> visit_occurrence_s
TRUNCATE TABLE :working_schema.visit_occurrence_s;
INSERT INTO :working_schema.visit_occurrence_s SELECT * FROM :working_schema.v_visit_occurrence_s;
DO $$ BEGIN RAISE NOTICE '[END] PatientVisit -> visit_occurrence_s | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.visit_occurrence_s;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] visit_occurrence_s -> visit_occurrence_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo visit_occurrence_s -> visit_occurrence_m
TRUNCATE TABLE :working_schema.visit_occurrence_m;
INSERT INTO :working_schema.visit_occurrence_m SELECT * FROM :working_schema.v_visit_occurrence_m;
DO $$ BEGIN RAISE NOTICE '[END] visit_occurrence_s -> visit_occurrence_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.visit_occurrence_m;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] visit_occurrence_m -> visit_occurrence_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo visit_occurrence_m -> visit_occurrence_f
TRUNCATE TABLE :working_schema.visit_occurrence_f;
INSERT INTO :working_schema.visit_occurrence_f SELECT * FROM :working_schema.v_visit_occurrence_f;
DO $$ BEGIN RAISE NOTICE '[END] visit_occurrence_m -> visit_occurrence_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.visit_occurrence_f;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] visit_occurrence_m -> visit_occurrence_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo visit_occurrence_m -> visit_occurrence_e
TRUNCATE TABLE :working_schema.visit_occurrence_e;
INSERT INTO :working_schema.visit_occurrence_e SELECT * FROM :working_schema.v_visit_occurrence_e;
DO $$ BEGIN RAISE NOTICE '[END] visit_occurrence_m -> visit_occurrence_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.visit_occurrence_e;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] visit_occurrence_m -> visit_detail_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo visit_occurrence_m -> visit_detail_f
TRUNCATE TABLE :working_schema.visit_detail_f;
INSERT INTO :working_schema.visit_detail_f SELECT * FROM :working_schema.v_visit_detail_f;
DO $$ BEGIN RAISE NOTICE '[END] visit_occurrence_m -> visit_detail_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.visit_detail_f;

----------------------------------
-- death staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] PatientVisit -> death_s | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo PatientVisit -> death_s
TRUNCATE TABLE :working_schema.death_s;
INSERT INTO :working_schema.death_s SELECT * FROM :working_schema.v_death_s;
DO $$ BEGIN RAISE NOTICE '[END] PatientVisit -> death_s | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.death_s;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] death_s -> death_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo death_s -> death_m
TRUNCATE TABLE :working_schema.death_m;
INSERT INTO :working_schema.death_m SELECT * FROM :working_schema.v_death_m;
DO $$ BEGIN RAISE NOTICE '[END] death_s -> death_m | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.death_m;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] death_m -> death_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo death_m -> death_f
TRUNCATE TABLE :working_schema.death_f;
INSERT INTO :working_schema.death_f SELECT * FROM :working_schema.v_death_f;
DO $$ BEGIN RAISE NOTICE '[END] death_m -> death_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.death_f;

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] death_m -> death_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo death_m -> death_e
TRUNCATE TABLE :working_schema.death_e;
INSERT INTO :working_schema.death_e SELECT * FROM :working_schema.v_death_e;
DO $$ BEGIN RAISE NOTICE '[END] death_m -> death_e | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.death_e;

----------------------------------
-- stem staging tables
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] stem cleanup | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo stem cleanup
TRUNCATE TABLE :working_schema.stem_source;
DO $$ BEGIN RAISE NOTICE '[END] stem cleanup | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] patientdisease -> stem_source(Condition) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo patientdisease -> stem_source(Condition)
-- ICD10 change: use icd10_cd as stem_source_field
--INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_disease;
--INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_disease_icd;
INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_disease_icd_suspdiv;
DO $$ BEGIN RAISE NOTICE '[END] patientdisease -> stem_source(Condition) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.stem_source WHERE stem_source_table = 'PatientDisease';

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] observationresult -> stem_source(Measurement) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo observationresult -> stem_source(Measurement)
INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_observation;
DO $$ BEGIN RAISE NOTICE '[END] observationresult -> stem_source(Measurement) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.stem_source WHERE stem_source_table = 'ObservationResult' AND source_domain_id = 'Measurement';

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] observationresult -> stem_source(Specimen) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo observationresult -> stem_source(Specimen)
INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_specimen;
DO $$ BEGIN RAISE NOTICE '[END] observationresult -> stem_source(Specimen) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.stem_source WHERE stem_source_table = 'ObservationResult'AND source_domain_id = 'Specimen';

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] prescriptiondata -> stem_source(Drug) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo prescriptiondata -> stem_source(Drug)
INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_prescription;
DO $$ BEGIN RAISE NOTICE '[END] prescriptiondata -> stem_source(Drug) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.stem_source WHERE stem_source_table = 'PrescriptionData';

\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] injectiondata -> stem_source(Drug) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo injectiondata -> stem_source(Drug)
INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_injection;
DO $$ BEGIN RAISE NOTICE '[END] injectiondata -> stem_source(Drug) | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
--SELECT * FROM :working_schema.stem_source WHERE stem_source_table = 'InjectionData';

----------------------------------
-- analyze
----------------------------------
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] ANALYZE stem_source / person_f / visit_*_f | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ANALYZE person_f
ANALYZE VERBOSE :working_schema.person_f;
\echo ANALYZE visit_occurrence_f
ANALYZE VERBOSE :working_schema.visit_occurrence_f;
\echo ANALYZE visit_detail_f
ANALYZE VERBOSE :working_schema.visit_detail_f;
\echo ANALYZE stem_source
ANALYZE VERBOSE :working_schema.stem_source;
DO $$ BEGIN RAISE NOTICE '[END] ANALYZE person_f / visit_*_f / stem_source | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

