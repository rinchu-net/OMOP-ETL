\set ON_ERROR_STOP on
\echo ====================================
\echo ==== truncate table before load ====
\echo ====================================
\echo ==== TRUNCATE location ====
TRUNCATE TABLE "@schema"."location_f";
\echo ==== TRUNCATE care_site ====
TRUNCATE TABLE "@schema"."care_site_f";
\echo ==== TRUNCATE provider ====
TRUNCATE TABLE "@schema"."provider_f";
\echo ==== TRUNCATE metadata ====
TRUNCATE TABLE "@schema"."metadata_f";
\echo ==== TRUNCATE cdm_source ====
TRUNCATE TABLE "@schema"."cdm_source_f";

\echo ====================================
\echo ==== execute data loading      =====
\echo ====================================
\echo ==== location ====
\copy "@schema"."location_f" from '../initdata/LOCATION.csv'WITH (FORMAT csv, DELIMITER ',', HEADER true, ENCODING 'UTF8')
\echo ==== care_site ====
\copy "@schema"."care_site_f" from '../initdata/CARE_SITE.csv'WITH (FORMAT csv, DELIMITER ',', HEADER true, ENCODING 'UTF8')
\echo ==== provider ====
\copy "@schema"."provider_f" from '../initdata/PROVIDER.csv'WITH (FORMAT csv, DELIMITER ',', HEADER true, ENCODING 'UTF8')
\echo ==== metadata ====
\copy "@schema"."metadata_f" from '../initdata/METADATA.csv'WITH (FORMAT csv, DELIMITER ',', HEADER true, ENCODING 'UTF8')
\echo ==== cdm_source ====
\copy "@schema"."cdm_source_f" from '../initdata/CDM_SOURCE.csv'WITH (FORMAT csv, DELIMITER ',', HEADER true, ENCODING 'UTF8')

\echo ===================================
\echo ==== table records count       ====
\echo ===================================
SELECT '@schema.location_f' AS table, COUNT(*) AS count FROM "@schema"."location_f";
SELECT '@schema.care_site_f' AS table, COUNT(*) AS count FROM "@schema"."care_site_f";
SELECT '@schema.provider_f' AS table, COUNT(*) AS count FROM "@schema"."provider_f";
SELECT '@schema.metadata_f' AS table, COUNT(*) AS count FROM "@schema"."metadata_f";
SELECT '@schema.cdm_source_f' AS table, COUNT(*) AS count FROM "@schema"."cdm_source_f";

