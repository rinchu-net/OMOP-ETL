\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_visit_detail_p AS 
SELECT 
	visit_detail_id,
	person_id,
	visit_detail_concept_id,
	visit_detail_start_date,
	visit_detail_start_datetime,
	visit_detail_end_date,
	visit_detail_end_datetime,
	visit_detail_type_concept_id,
	provider_id,
	care_site_id,
	visit_detail_source_regvalue AS visit_detail_source_value,
	visit_detail_source_concept_id,
	admitted_from_concept_id,
	admitted_from_source_value,
	discharged_to_source_value,
	discharged_to_concept_id,
	preceding_visit_detail_id,
	visit_detail_id AS parent_visit_detail_id,
	visit_occurrence_id
FROM :working_schema.visit_detail_f
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_visit_detail_p;
--SELECT * FROM :working_schema.v_visit_detail_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.visit_detail;
--INSERT INTO :production_schema.visit_detail SELECT * FROM :working_schema.v_visit_detail_p
