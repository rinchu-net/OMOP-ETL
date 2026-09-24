\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_visit_occurrence_m
-- Purpose: Create mapped data from visit_occurrence_s
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_visit_occurrence_m AS 
WITH
cte_visit_occurrence_m AS (
SELECT 
	ps.person_id AS person_id,
	stcm1.target_concept_id AS visit_concept_id,
	s.visit_start_date,
	s.visit_start_datetime,
	s.visit_end_date,
	s.visit_end_datetime,
	32817 AS visit_type_concept_id,
	pv.provider_id,
	cs.care_site_id,
	s.visit_source_value,
	stcm1.source_concept_id AS visit_source_concept_id,
	s.visit_source_regvalue,
	stcm2.target_concept_id AS admitted_from_concept_id,
	s.admitted_from_source_value,
	CASE
		WHEN s.discharged_to_source_value IS NULL THEN NULL
		ELSE COALESCE(stcm3.target_concept_id, 0)
	END AS discharged_to_concept_id,
	s.discharged_to_source_value,
	s.preceding_visit_occurrence_id,
	s.rownum,
	s.table_name,
	s.field_name,
	s.load_row_id,
	s.parent_load_row_id
FROM :working_schema.visit_occurrence_s s
LEFT JOIN :working_schema.person_f ps ON s.person_source_value = ps.person_source_value
LEFT JOIN :working_schema.provider_f pv ON s.provider_source_value = pv.provider_source_value
LEFT JOIN :working_schema.care_site_f cs ON s.care_site_source_value = cs.care_site_source_value
LEFT JOIN :working_schema.source_to_concept_map_f stcm1 
	ON s.visit_source_vocabulary_id = stcm1.source_vocabulary_id
	AND s.visit_source_value = stcm1.source_code
LEFT JOIN :working_schema.source_to_concept_map_f stcm2 
	ON s.admitted_from_vocabulary_id = stcm2.source_vocabulary_id
	AND s.admitted_from_source_value = stcm2.source_code
LEFT JOIN :working_schema.source_to_concept_map_f stcm3 
	ON s.discharged_to_vocabulary_id = stcm3.source_vocabulary_id
	AND s.discharged_to_source_value = stcm3.source_code
),

cte_final AS (
SELECT 
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
	load_row_id,
	parent_load_row_id
FROM cte_visit_occurrence_m
)

SELECT * FROM cte_final ORDER BY person_id, load_row_id;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_visit_occurrence_m;
--SELECT * FROM :working_schema.v_visit_occurrence_m LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.visit_occurrence_m;
--INSERT INTO :working_schema.visit_occurrence_m SELECT * FROM :working_schema.v_visit_occurrence_m
