\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_person_p
-- Purpose: Create production data from person_f
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_person_p AS 
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
    ethnicity_source_concept_id
FROM :working_schema.person_f
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_person_p;
--SELECT * FROM :working_schema.v_person_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.person;
--INSERT INTO :production_schema.person SELECT * FROM :working_schema.v_person_p
