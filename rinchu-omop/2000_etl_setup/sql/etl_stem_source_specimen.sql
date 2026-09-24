\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_stem_source_specimen AS
WITH etl_stem_source_specimen AS (
    SELECT
        patient_id AS person_source_value,
        sch_spm_collect_date AS start_date,
		CASE
			WHEN spm_collect_time = '999999' OR spm_collect_time IS NULL OR spm_collect_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(spm_collect_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(spm_collect_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(spm_collect_time, 5, 2)::integer >= 60 
			THEN TO_TIMESTAMP(spm_collect_date || '000000','YYYYMMDDHH24MISS')
			ELSE TO_TIMESTAMP(spm_collect_date || spm_collect_time,'YYYYMMDDHH24MISS')
		END AS start_datetime,
		CASE
			WHEN spm_collect_time = '999999' OR spm_collect_time IS NULL OR spm_collect_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(spm_collect_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(spm_collect_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(spm_collect_time, 5, 2)::integer >= 60 
			THEN '00:00:00'::time
			ELSE TO_TIMESTAMP(spm_collect_time,'HH24MISS')::time
		END AS start_time,
        NULL::date AS end_date,
        NULL::timestamp AS end_datetime,
        dept_cd_s AS provider_source_value,
        NULL AS visit_source_value,
        NULL AS visit_detail_source_value,
        spm_cd_s AS source_value,
        'Specimen' AS source_domain_id,
        'RINCHU_SPM_CD' AS source_vocabulary_id,
        NULL AS secondary_vocabulary_id,
        COALESCE(spm_cd_s, '') || '|' || COALESCE(spm_name_s, '') AS source_regvalue,
        'EHR' AS type_category,
        NULL AS value_source_value,
        NULL AS value_domain_id,    
        NULL AS value_vocabulary_id,
        NULL AS value_secondary_vocabulary_id,
        NULL AS value_source_regvalue,
        NULL AS unit_source_value,
        NULL AS unit_domain_id,
        NULL AS unit_vocabulary_id,
        NULL AS unit_secondary_vocabulary_id,
        NULL AS unit_source_regvalue,
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
        NULL::integer AS quantity,
        NULL AS anatomic_site_source_value,
        NULL AS anatomic_site_domain_id,
        NULL AS anatomic_site_vocabulary_id,
        NULL AS anatomic_site_secondary_vocabulary_id,
        NULL AS anatomic_site_source_regvalue,
        NULL AS specimen_source_id,
        NULL AS status_source_value,
        NULL AS status_domain_id,
        NULL AS status_vocabulary_id,
        NULL AS status_secondary_vocabulary_id,
        NULL AS status_source_regvalue,
        NULL AS unique_device_id,
        NULL AS modifier_source_value,
        NULL AS modifier_domain_id,
        NULL AS modifier_vocabulary_id,
        NULL AS modifier_secondary_vocabulary_id,
        NULL AS modifier_source_regvalue,
        NULL AS stop_reason,
        NULL::integer AS refills,
        NULL::integer AS days_supply,
        NULL AS sig,
        NULL AS lot_number,
        NULL::date AS verbatim_end_date,
        NULL AS route_source_value,
        NULL AS route_domain_id,
        NULL AS route_vocabulary_id,
        NULL AS route_secondary_vocabulary_id,
        NULL AS route_source_regvalue,
        'ObservationResult' AS stem_source_table,
        'spm_cd_s' AS stem_source_field,
        obx_unique_id AS stem_source_rowid,
        ROW_NUMBER() OVER (PARTITION BY patient_id, spm_collect_date, spm_collect_time, spm_cd_s ORDER BY obx_unique_id) AS rn
    FROM :source_schema.ObservationResult
    WHERE spm_cd_s IS NOT NULL
),
stem_source_format AS (
    SELECT
        person_source_value,
        start_date,
        start_datetime,
        start_time,
        end_date,
        end_datetime,
        provider_source_value,
        visit_source_value,
        visit_detail_source_value,
        source_value,
        source_domain_id,
        source_vocabulary_id,
        secondary_vocabulary_id,
        source_regvalue,
        type_category,
        value_source_value,
        value_domain_id,
        value_vocabulary_id,
        value_secondary_vocabulary_id,
        value_source_regvalue,
        unit_source_value,
        unit_domain_id,
        unit_vocabulary_id,
        unit_secondary_vocabulary_id,
        unit_source_regvalue,
        value_as_number,
        qualifier_source_value,
        qualifier_domain_id,
        qualifier_vocabulary_id,
        qualifier_secondary_vocabulary_id,
        qualifier_source_regvalue,
        value_as_string,
        range_low,
        range_high,
        operator_source_value,
        operator_domain_id,
        operator_vocabulary_id,
        operator_secondary_vocabulary_id,
        operator_source_regvalue,
        quantity,
        anatomic_site_source_value,
        anatomic_site_domain_id,
        anatomic_site_vocabulary_id,
        anatomic_site_secondary_vocabulary_id,
        anatomic_site_source_regvalue,
        specimen_source_id,
        status_source_value,
        status_domain_id,
        status_vocabulary_id,
        status_secondary_vocabulary_id,
        status_source_regvalue,
        unique_device_id,
        modifier_source_value,
        modifier_domain_id,
        modifier_vocabulary_id,
        modifier_secondary_vocabulary_id,
        modifier_source_regvalue,
        stop_reason,
        refills,
        days_supply,
        sig,
        lot_number,
        verbatim_end_date,
        route_source_value,
        route_domain_id,
        route_vocabulary_id,
        route_secondary_vocabulary_id,
        route_source_regvalue,
        stem_source_table,
        stem_source_field,
        stem_source_rowid
    FROM etl_stem_source_specimen 
    WHERE rn = 1
)

SELECT * FROM stem_source_format;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_stem_source_specimen;
--SELECT * FROM :working_schema.v_stem_source_specimen LIMIT 100;

--- データ生成
--DELETE FROM :working_schema.stem_source WHERE table_name = 'ObservationResult' AND source_domain_id = 'Specimen';
--INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_specimen;
--SELECT * FROM :working_schema.stem_source WHERE table_name = 'ObservationResult'AND source_domain_id = 'Specimen';
