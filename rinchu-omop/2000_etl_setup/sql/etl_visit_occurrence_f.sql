\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_visit_occurrence_f
-- Purpose: Create filtered data from visit_occurrence_m
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_visit_occurrence_f AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY person_id, load_row_id) AS visit_occurrence_id,
	person_id,
	visit_concept_id,
	visit_start_date,
	visit_start_datetime,
	visit_end_date,
	visit_end_datetime,
	visit_type_concept_id,
	provider_id,
	care_site_id,
	visit_source_value,
	visit_source_concept_id,
	visit_source_regvalue,
	admitted_from_concept_id,
	admitted_from_source_value,
	discharged_to_concept_id,
	discharged_to_source_value,
	preceding_visit_occurrence_id,
	rownum,
	table_name,
	field_name,
	load_row_id
FROM :working_schema.visit_occurrence_m
WHERE visit_concept_id IN (9201, 9202) -- 入院、外来イベントだけを対象にする
AND person_id IS NOT NULL
--AND visit_concept_id IS NOT NULL AND visit_concept_id <> 0
AND visit_concept_id IS NOT NULL
AND visit_start_date IS NOT NULL
AND visit_end_date IS NOT NULL
AND visit_type_concept_id IS NOT NULL
;

--- Test query
--SELECT COUNT(1) FROM :working_schema.v_visit_occurrence_f;
--SELECT * FROM :working_schema.v_visit_occurrence_f LIMIT 100;

--- Data generation
--TRUNCATE TABLE :working_schema.visit_occurrence_f;
--INSERT INTO :working_schema.visit_occurrence_f SELECT * FROM :working_schema.v_visit_occurrence_f