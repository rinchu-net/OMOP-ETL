\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_person_f
-- Purpose: Create filtered data from person_m
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_person_f AS 
SELECT 
    person_id,
    gender_concept_id,
    year_of_birth,
    month_of_birth,
    day_of_birth,
    birth_datetime,
    race_concept_id,
    ethnicity_concept_id,
    location_id,
    provider_id,
    care_site_id,
    person_source_value,
    gender_source_value,
    gender_source_concept_id,
    race_source_value,
    race_source_concept_id,
    ethnicity_source_value,
    ethnicity_source_concept_id,
    table_name,
    field_name,
    load_row_id
FROM :working_schema.person_m
WHERE rownum = 1
AND person_source_value IS NOT NULL
AND gender_concept_id IS NOT NULL AND gender_concept_id <> 0
AND year_of_birth IS NOT NULL AND year_of_birth <> 0
AND race_concept_id IS NOT NULL
AND ethnicity_concept_id IS NOT NULL
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_person_f;
--SELECT * FROM :working_schema.v_person_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.person_f;
--INSERT INTO :working_schema.person_f SELECT * FROM :working_schema.v_person_f
