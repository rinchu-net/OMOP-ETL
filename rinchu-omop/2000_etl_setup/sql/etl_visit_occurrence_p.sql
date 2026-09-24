\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_visit_occurrence_p AS 
SELECT 
	visit_occurrence_id,
	person_id,
	visit_concept_id,
	visit_start_date,
	visit_start_datetime,
	visit_end_date,
	visit_end_datetime,
	visit_type_concept_id,
	provider_id,
	care_site_id,
	visit_source_regvalue AS visit_source_value,
	visit_source_concept_id,
	admitted_from_concept_id,
	admitted_from_source_value,
	discharged_to_concept_id,
	discharged_to_source_value,
	preceding_visit_occurrence_id
FROM :working_schema.visit_occurrence_f
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_visit_occurrence_p;
--SELECT * FROM :working_schema.v_visit_occurrence_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.visit_occurrence_p;
--INSERT INTO :production_schema.visit_occurrence_p SELECT * FROM :working_schema.v_visit_occurrence_p
