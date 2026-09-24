\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_visit_occurrence_e AS
WITH
cte_visit_occurrence_e AS (
    SELECT
    	0 AS visit_occurrence_id,
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
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN visit_concept_id IS NULL or visit_concept_id = 0 THEN 'visit_concept_id'
        WHEN visit_concept_id IS NULL THEN 'visit_concept_id'
        WHEN visit_start_date IS NULL THEN 'visit_start_date'
        WHEN visit_end_date IS NULL THEN 'visit_end_date'
        WHEN visit_type_concept_id IS NULL THEN 'visit_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.visit_occurrence_m
    WHERE person_id IS NULL OR person_id = 0
--  OR visit_concept_id IS NULL OR visit_concept_id = 0
    OR visit_concept_id IS NULL
    OR visit_start_date IS NULL
    OR visit_end_date IS NULL
    OR visit_type_concept_id IS NULL
)

SELECT * FROM cte_visit_occurrence_e;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_visit_occurrence_e;
--SELECT * FROM :working_schema.v_visit_occurrence_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.visit_occurrence_e;
--INSERT INTO :working_schema.visit_occurrence_e SELECT * FROM :working_schema.v_visit_occurrence_e;
