\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_stem_source_injection AS
WITH etl_stem_source_injection AS (
    SELECT
        patient_id AS person_source_value,
        sch_inj_start_date AS start_date,
		CASE
			WHEN inj_start_time = '999999' OR inj_start_time IS NULL OR inj_start_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(inj_start_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(inj_start_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(inj_start_time, 5, 2)::integer >= 60 
			THEN TO_TIMESTAMP(inj_start_time || '000000','YYYYMMDDHH24MISS')::timestamp
			ELSE TO_TIMESTAMP(inj_start_date || inj_start_time,'YYYYMMDDHH24MISS')::timestamp
		END AS start_datetime,
		CASE
			WHEN inj_start_time = '999999' OR inj_start_time IS NULL OR inj_start_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(inj_start_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(inj_start_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(inj_start_time, 5, 2)::integer >= 60 
			THEN '00:00:00'::time
			ELSE TO_TIMESTAMP(inj_start_time,'HH24MISS')::time
		END AS start_time,
--      sch_inj_end_date AS end_date,
--		CASE
--			WHEN inj_end_time = '999999' OR inj_end_time IS NULL OR inj_end_time ~ '^[0-9]{6}$' = false 
--			     OR SUBSTRING(inj_end_time, 1, 2)::integer >= 24 
--			     OR SUBSTRING(inj_end_time, 3, 2)::integer >= 60 
--			     OR SUBSTRING(inj_end_time, 5, 2)::integer >= 60 
--			THEN TO_TIMESTAMP(inj_end_time || '000000','YYYYMMDDHH24MISS')
--			ELSE TO_TIMESTAMP(inj_end_date || inj_end_time,'YYYYMMDDHH24MISS')
--		END AS end_datetime,
        COALESCE(NULLIF(sch_inj_end_date, '9999-12-31'::date), sch_inj_start_date) AS end_date,
		NULL::timestamp AS end_datetime,
        dept_cd_s AS provider_source_value,
        NULL AS visit_source_value,
        NULL AS visit_detail_source_value,
        inj_medicine_cd_yj AS source_value,
        'Drug' AS source_domain_id,
        'RINCHU_DRUG' AS source_vocabulary_id,
        NULL AS secondary_vocabulary_id,
        COALESCE(inj_medicine_cd_yj, '') || '|' || COALESCE(inj_medicine_cd_hot, '') || '|' || COALESCE(inj_medicine_name_l, '') AS source_regvalue,
        'EHR' AS type_category,
        NULL AS value_source_value,
        NULL AS value_domain_id,
        NULL AS value_vocabulary_id,
        NULL AS value_secondary_vocabulary_id,
        NULL AS value_source_regvalue,
        inj_dosage_unit_cd_s AS unit_source_value,
        'Unit' AS unit_domain_id,
        'RINCHU_DRUG_UNIT' AS unit_vocabulary_id,
        NULL AS unit_secondary_vocabulary_id,
        COALESCE(inj_dosage_unit_cd_s, '') || '|' || COALESCE(inj_administered_unit_name_l, '') AS unit_source_regvalue,
        NULL::integer AS value_as_number,
        NULL AS qualifier_source_value,
        NULL AS qualifier_domain_id,
        NULL AS qualifier_vocabulary_id,
        NULL AS qualifier_secondary_vocabulary_id,
        NULL AS qualifier_source_regvalue,
        NULL AS value_as_string,
        NULL::integer AS range_low,
        NULL::integer AS range_high,
        NULL AS operator_source_value,
        NULL AS operator_domain_id,
        NULL AS operator_vocabulary_id,
        NULL AS operator_secondary_vocabulary_id,
        NULL AS operator_source_regvalue,
        inj_administered_amount::NUMERIC AS quantity,
        NULL AS anatomic_site_source_value,
        NULL AS anatomic_site_domain_id,
        NULL AS anatomic_site_vocabulary_id,
        NULL AS anatomic_site_secondary_vocabulary_id,
        NULL AS anatomic_site_source_regvalue,
        NULL AS specimen_source_id,
        inj_completion_status AS status_source_value,
        NULL AS status_domain_id,
        NULL AS status_vocabulary_id,
        NULL AS status_secondary_vocabulary_id,
        inj_completion_status AS status_source_regvalue,
        NULL AS unique_device_id,
        NULL AS modifier_source_value,
        NULL AS modifier_domain_id,
        NULL AS modifier_vocabulary_id,
        NULL AS modifier_secondary_vocabulary_id,
        NULL AS modifier_source_regvalue,
        NULL AS stop_reason,
        NULL::integer AS refills,
        NULL::integer AS days_supply,
        CASE
            WHEN inj_administration_notes IS NULL AND inj_administered_per IS NULL AND inj_indication IS NULL THEN NULL
            ELSE COALESCE(inj_administration_notes, '') || '|' || COALESCE(inj_administered_per, '') || '|' || COALESCE(inj_indication, '')
        END AS sig,
        NULL AS lot_number,
        NULL::date AS verbatim_end_date,
        inj_route AS route_source_value,
        'Route' AS route_domain_id,
        'RINCHU_DRUG_ROUTE' AS route_vocabulary_id,
        NULL AS route_secondary_vocabulary_id,
        inj_route AS route_source_regvalue,
        'InjectionData' AS stem_source_table,
        'inj_medicine_cd_yj' AS stem_source_field,
        inj_unique_id AS stem_source_rowid
    FROM :source_schema.injectiondata
)

SELECT * FROM etl_stem_source_injection;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_stem_source_injection;
--SELECT * FROM :working_schema.v_stem_source_injection LIMIT 100;

--- データ生成
--DELETE FROM :working_schema.stem WHERE table_name = 'InjectionData';
--INSERT INTO :working_schema.stem SELECT * FROM :working_schema.v_stem_source_injection;
--SELECT * FROM :working_schema.stem WHERE table_name = 'InjectionData';
