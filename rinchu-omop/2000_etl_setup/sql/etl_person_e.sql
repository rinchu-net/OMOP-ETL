\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_person_e
-- Purpose: Create error data from person_m
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_person_e AS 
SELECT 
	0 AS person_id,
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
	load_row_id,
    CASE 
        WHEN person_source_value IS NULL THEN 'person_source_value'
        WHEN gender_concept_id IS NULL OR gender_concept_id = 0 THEN 'gender_concept_id'
        WHEN year_of_birth IS NULL OR year_of_birth = 0 THEN 'year_of_birth'
        WHEN race_concept_id IS NULL THEN 'race_concept_id'
        WHEN ethnicity_concept_id IS NULL THEN 'ethnicity_concept_id'
        ELSE NULL
    END AS error_field
FROM :working_schema.person_m
WHERE rownum = 1
AND
 ( person_source_value IS NULL
    OR gender_concept_id IS NULL OR gender_concept_id = 0
    OR year_of_birth IS NULL OR year_of_birth = 0
    OR race_concept_id IS NULL
    OR ethnicity_concept_id IS NULL
);

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_person_e;
--SELECT * FROM :working_schema.v_person_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.person_e;
--INSERT INTO :working_schema.person_e SELECT * FROM :working_schema.v_person_e
