\set ON_ERROR_STOP on
\echo ====================================
\echo ==== truncate table before load ====
\echo ====================================
\echo ==== TRUNCATE patientidentification ====
TRUNCATE TABLE "@schema"."patientidentification";
\echo ==== TRUNCATE patientaddress ====
TRUNCATE TABLE "@schema"."patientaddress";
\echo ==== TRUNCATE patientvisit ====
TRUNCATE TABLE "@schema"."patientvisit";
\echo ==== TRUNCATE patientdisease ====
TRUNCATE TABLE "@schema"."patientdisease";
\echo ==== TRUNCATE observationresult ====
TRUNCATE TABLE "@schema"."observationresult";
\echo ==== TRUNCATE prescriptiondata ====
TRUNCATE TABLE "@schema"."prescriptiondata";
\echo ==== TRUNCATE injectiondata ====
TRUNCATE TABLE "@schema"."injectiondata";
\echo ====================================
\echo ==== execute data loading      =====
\echo ====================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading PatientIdentification | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== PatientIdentification ====
\copy "@schema"."patientidentification" from '../dat/PatientIdentification.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading PatientIdentification | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading PatientAddress | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== PatientAddress ====
\copy "@schema"."patientaddress" from '../dat/PatientAddress.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading PatientAddress | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading PatientVisit | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== PatientVisit ====
\copy "@schema"."patientvisit" from '../dat/PatientVisit.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading PatientVisit | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading PatientDisease | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== PatientDisease ====
\copy "@schema"."patientdisease" from '../dat/PatientDisease.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading PatientDisease | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading ObservationResult | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== ObservationResult ====
\copy "@schema"."observationresult" from '../dat/ObservationResult.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading ObservationResult | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading PrescriptionData | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== PrescriptionData ====
\copy "@schema"."prescriptiondata" from '../dat/PrescriptionData.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading PrescriptionData | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] loading InjectionData | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo ==== InjectionData ====
\copy "@schema"."injectiondata" from '../dat/InjectionData.csv' csv header
DO $$ BEGIN RAISE NOTICE '[END] loading InjectionData | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
\echo ===================================
\echo ==== table records count       ====
\echo ===================================
SELECT '@schema.patientidentification' AS table, COUNT(*) AS count FROM "@schema"."patientidentification";
SELECT '@schema.patientaddress' AS table, COUNT(*) AS count FROM "@schema"."patientaddress";
SELECT '@schema.patientvisit' AS table, COUNT(*) AS count FROM "@schema"."patientvisit";
SELECT '@schema.patientdisease' AS table, COUNT(*) AS count FROM "@schema"."patientdisease";
SELECT '@schema.observationresult' AS table, COUNT(*) AS count FROM "@schema"."observationresult";
SELECT '@schema.prescriptiondata' AS table, COUNT(*) AS count FROM "@schema"."prescriptiondata";
SELECT '@schema.injectiondata' AS table, COUNT(*) AS count FROM "@schema"."injectiondata";

\echo =====================================================================
\echo ==== ANALYZE source tables (post-load) ====
\echo =====================================================================
DO $$ BEGIN RAISE NOTICE '[START] ANALYZE source tables | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
ANALYZE "@schema"."patientidentification";
ANALYZE "@schema"."patientaddress";
ANALYZE "@schema"."patientvisit";
ANALYZE "@schema"."patientdisease";
ANALYZE "@schema"."observationresult";
ANALYZE "@schema"."prescriptiondata";
ANALYZE "@schema"."injectiondata";
DO $$ BEGIN RAISE NOTICE '[END] ANALYZE source tables | %', clock_timestamp() AT TIME ZONE 'Asia/Tokyo'; END $$;
\echo =====================================================================
