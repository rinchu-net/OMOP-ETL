\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_visit_detail_f
-- Purpose: Create filtered data from visit_occurrence_m
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_visit_detail_f AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY vd.person_id, vd.load_row_id) AS visit_detail_id,
	vd.person_id,
	vd.visit_concept_id AS visit_detail_concept_id,
	vd.visit_start_date AS visit_detail_start_date,
	vd.visit_start_datetime AS visit_detail_start_datetime,
	vd.visit_end_date AS visit_detail_end_date,
	vd.visit_end_datetime AS visit_detail_end_datetime,
	vd.visit_type_concept_id AS visit_detail_type_concept_id,
	vd.provider_id,
	vd.care_site_id,
	vd.visit_source_value AS visit_detail_source_value,
	vd.visit_source_concept_id AS visit_detail_source_concept_id,
	vd.visit_source_regvalue AS visit_detail_source_regvalue,
	vd.admitted_from_concept_id,
	vd.admitted_from_source_value,
	CASE
		WHEN vd.discharged_to_source_value IS NULL THEN NULL
		ELSE COALESCE(vd.discharged_to_concept_id, 0)
	END AS discharged_to_concept_id,
	vd.discharged_to_source_value,
	vd.preceding_visit_occurrence_id AS preceding_visit_detail_id,
	0 AS parent_visit_detail_id,
	COALESCE(vo.visit_occurrence_id, 0) AS visit_occurrence_id,
	vd.rownum,
	vd.table_name,
	vd.field_name,
	vd.load_row_id
FROM :working_schema.visit_occurrence_m vd
LEFT JOIN :working_schema.visit_occurrence_f vo
	ON vd.parent_load_row_id = vo.load_row_id
WHERE vd.visit_concept_id NOT IN (9201, 9202) -- 入院、外来イベント以外を対象にする
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_visit_detail_f;
--SELECT * FROM :working_schema.v_visit_detail_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.visit_detail_f;
--INSERT INTO :working_schema.visit_detail_f SELECT * FROM :working_schema.v_visit_detail_f
