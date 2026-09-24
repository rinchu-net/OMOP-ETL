\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_person_m
-- Purpose: Create mapped data from person_s
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_person_m AS 
WITH
cte_person_m AS (
SELECT 
	s.person_id,
	CASE
		WHEN s.gender_source_value = 'M' THEN 8507
		WHEN s.gender_source_value = 'F' THEN 8532
		ELSE 0
	END AS gender_concept_id,
	s.year_of_birth,
	s.month_of_birth,
	s.day_of_birth,
	s.birth_datetime,
	COALESCE(racc.concept_id,0) AS race_concept_id,
	COALESCE(ethc.concept_id,0) AS ethnicity_concept_id,
	l.location_id,
	CAST(NULL AS integer) AS provider_id,
	c.care_site_id,
	s.person_source_value,
	s.gender_source_regvalue AS gender_source_value,
	CASE
		WHEN s.gender_source_value = 'M' THEN 8507
		WHEN s.gender_source_value = 'F' THEN 8532
		ELSE 0
	END AS gender_source_concept_id,
	race_source_regvalue AS race_source_value,
	CAST(NULL AS integer) AS race_source_concept_id,
	ethnicity_source_regvalue AS ethnicity_source_value,
	CAST(NULL AS integer) AS ethnicity_source_concept_id,
	s.rownum,
	s.table_name,
	s.field_name,
	s.load_row_id
FROM :working_schema.person_s s
-- location_source_value -> location_id
LEFT JOIN :working_schema.location_f l ON s.location_source_value = l.location_source_value 
-- care_site_source_value -> care_site_id
LEFT JOIN :working_schema.care_site_f c on s.care_site_source_value = c.care_site_source_value
-- race_source_value -> standard concept
LEFT JOIN :working_schema.source_to_concept_map_f rac ON s.race_source_value = rac.source_code
    AND s.race_vocabulary_id = rac.source_vocabulary_id
    -- standard concept of race
    LEFT JOIN :working_schema.concept_f racc ON rac.target_concept_id = racc.concept_id
-- ethnicity_source_value -> standard concept
LEFT JOIN :working_schema.source_to_concept_map_f eth ON s.ethnicity_source_value = eth.source_code
    AND s.ethnicity_vocabulary_id = eth.source_vocabulary_id
    -- standard concept
    LEFT JOIN :working_schema.concept_f ethc ON eth.target_concept_id = ethc.concept_id
),

cte_final AS (
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
	rownum,
	table_name,
	field_name,
	load_row_id
FROM cte_person_m
)

SELECT * FROM cte_final;


--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_person_m;
--SELECT * FROM :working_schema.v_person_m LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.person_m;
--INSERT INTO :working_schema.person_m SELECT * FROM :working_schema.v_person_m
