\set ON_ERROR_STOP on
---------------------------------------------------------------------
-- finalizeテーブルからproductionテーブルへのデータ移行
---------------------------------------------------------------------
-- location
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating location | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating location ..
ALTER TABLE :production_schema.location DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.location CASCADE;
INSERT INTO :production_schema.location SELECT * FROM :working_schema.v_location_p;
ALTER TABLE :production_schema.location ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.location;
DO $$ BEGIN RAISE NOTICE '[END] migrating location | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- care_site
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating care_site | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating care_site ..
ALTER TABLE :production_schema.care_site DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.care_site CASCADE;
INSERT INTO :production_schema.care_site SELECT * FROM :working_schema.v_care_site_p;
ALTER TABLE :production_schema.care_site ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.care_site;
DO $$ BEGIN RAISE NOTICE '[END] migrating care_site | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- provider
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating provider | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating provider ..
ALTER TABLE :production_schema.provider DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.provider CASCADE;
INSERT INTO :production_schema.provider SELECT * FROM :working_schema.v_provider_p;
ALTER TABLE :production_schema.provider ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.provider;
DO $$ BEGIN RAISE NOTICE '[END] migrating provider | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- person
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating person | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating person ..
ALTER TABLE :production_schema.person DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.person CASCADE;
INSERT INTO :production_schema.person SELECT * FROM :working_schema.v_person_p;
ALTER TABLE :production_schema.person ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.person;
DO $$ BEGIN RAISE NOTICE '[END] migrating person | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- death
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating death | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating death ..
ALTER TABLE :production_schema.death DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.death CASCADE;
INSERT INTO :production_schema.death SELECT * FROM :working_schema.v_death_p;
ALTER TABLE :production_schema.death ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.death;
DO $$ BEGIN RAISE NOTICE '[END] migrating death | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- visit_occurrence
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating visit_occurrence | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating visit_occurrence ..
ALTER TABLE :production_schema.visit_occurrence DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.visit_occurrence CASCADE;
INSERT INTO :production_schema.visit_occurrence SELECT * FROM :working_schema.v_visit_occurrence_p;
ALTER TABLE :production_schema.visit_occurrence ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.visit_occurrence;
DO $$ BEGIN RAISE NOTICE '[END] migrating visit_occurrence | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- visit_detail
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating visit_detail | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating visit_detail ..
ALTER TABLE :production_schema.visit_detail DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.visit_detail CASCADE;
INSERT INTO :production_schema.visit_detail SELECT * FROM :working_schema.v_visit_detail_p;
ALTER TABLE :production_schema.visit_detail ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.visit_detail;
DO $$ BEGIN RAISE NOTICE '[END] migrating visit_detail | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- condition_occurrence
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating condition_occurrence | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating condition_occurrence ..
ALTER TABLE :production_schema.condition_occurrence DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.condition_occurrence CASCADE;
INSERT INTO :production_schema.condition_occurrence SELECT * FROM :working_schema.v_condition_occurrence_p;
ALTER TABLE :production_schema.condition_occurrence ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.condition_occurrence;
DO $$ BEGIN RAISE NOTICE '[END] migrating condition_occurrence | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- drug_exposure
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating drug_exposure | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating drug_exposure ..
--alter table :production_schema.drug_exposure alter column drug_source_value type varchar(255);
ALTER TABLE :production_schema.drug_exposure DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.drug_exposure CASCADE;
INSERT INTO :production_schema.drug_exposure SELECT * FROM :working_schema.v_drug_exposure_p;
ALTER TABLE :production_schema.drug_exposure ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.drug_exposure;
DO $$ BEGIN RAISE NOTICE '[END] migrating drug_exposure | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- device_exposure
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating device_exposure | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating device_exposure ..
--alter table :production_schema.device_exposure alter column drug_source_value type varchar(255);
ALTER TABLE :production_schema.device_exposure DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.device_exposure CASCADE;
INSERT INTO :production_schema.device_exposure SELECT * FROM :working_schema.v_device_exposure_p;
ALTER TABLE :production_schema.device_exposure ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.device_exposure;
DO $$ BEGIN RAISE NOTICE '[END] migrating device_exposure | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- measurement
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating measurement | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating measurement ..
ALTER TABLE :production_schema.measurement DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.measurement CASCADE;
INSERT INTO :production_schema.measurement SELECT * FROM :working_schema.v_measurement_p;
ALTER TABLE :production_schema.measurement ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.measurement;
DO $$ BEGIN RAISE NOTICE '[END] migrating measurement | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- observation
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating observation | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating observation ..
ALTER TABLE :production_schema.observation DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.observation CASCADE;
INSERT INTO :production_schema.observation SELECT * FROM :working_schema.v_observation_p;
ALTER TABLE :production_schema.observation ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.observation;
DO $$ BEGIN RAISE NOTICE '[END] migrating observation | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- procedure_occurrence
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating procedure_occurrence | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating procedure_occurrence ..
ALTER TABLE :production_schema.procedure_occurrence DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.procedure_occurrence CASCADE;
INSERT INTO :production_schema.procedure_occurrence SELECT * FROM :working_schema.v_procedure_occurrence_p;
ALTER TABLE :production_schema.procedure_occurrence ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.procedure_occurrence;
DO $$ BEGIN RAISE NOTICE '[END] migrating procedure_occurrence | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- specimen
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating specimen | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating specimen ..
ALTER TABLE :production_schema.specimen DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.specimen CASCADE;
INSERT INTO :production_schema.specimen SELECT * FROM :working_schema.v_specimen_p;
ALTER TABLE :production_schema.specimen ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.specimen;
DO $$ BEGIN RAISE NOTICE '[END] migrating specimen | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- observation_period
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating observation_period | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating observation_period ..
ALTER TABLE :production_schema.observation_period DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.observation_period CASCADE;
INSERT INTO :production_schema.observation_period SELECT * FROM :working_schema.observation_period_f;
ALTER TABLE :production_schema.observation_period ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.observation_period;
DO $$ BEGIN RAISE NOTICE '[END] migrating observation_period | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- condition_era
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating condition_era | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating condition_era ..
ALTER TABLE :production_schema.condition_era DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.condition_era CASCADE;
INSERT INTO :production_schema.condition_era SELECT * FROM :working_schema.condition_era_f;
ALTER TABLE :production_schema.condition_era ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.condition_era;
DO $$ BEGIN RAISE NOTICE '[END] migrating condition_era | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- drug_era
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating drug_era | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating drug_era ..
ALTER TABLE :production_schema.drug_era DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.drug_era CASCADE;
INSERT INTO :production_schema.drug_era SELECT * FROM :working_schema.drug_era_f;
ALTER TABLE :production_schema.drug_era ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.drug_era;
DO $$ BEGIN RAISE NOTICE '[END] migrating drug_era | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================

-- dose_era
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] migrating dose_era | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo migrating dose_era ..
ALTER TABLE :production_schema.dose_era DISABLE TRIGGER ALL;
TRUNCATE TABLE :production_schema.dose_era CASCADE;
INSERT INTO :production_schema.dose_era SELECT * FROM :working_schema.dose_era_f;
ALTER TABLE :production_schema.dose_era ENABLE TRIGGER ALL;
ANALYZE VERBOSE :production_schema.dose_era;
DO $$ BEGIN RAISE NOTICE '[END] migrating dose_era | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
