\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_stem_source_prescription AS
WITH etl_stem_source_prescription AS (
    SELECT
        patient_id AS person_source_value,
        sch_pres_start_date AS start_date,
        NULL::timestamp AS start_datetime,
        NULL::time AS start_time,
        CASE 
            WHEN pres_period IS NOT NULL AND pres_period > 0 THEN sch_pres_start_date + (pres_period - 1) * INTERVAL '1 day'
            ELSE sch_pres_start_date + 29 * INTERVAL '1 day'
        END AS end_date,
        NULL::timestamp AS end_datetime,
        dept_cd_s AS provider_source_value,
        NULL AS visit_source_value,
        NULL AS visit_detail_source_value,
        pres_medicine_cd_yj AS source_value,
        'Drug' AS source_domain_id,
        'RINCHU_DRUG' AS source_vocabulary_id,
        NULL AS secondary_vocabulary_id,
        COALESCE(pres_medicine_cd_yj, '') || '|' || COALESCE(pres_medicine_cd_hot, '') || '|' || COALESCE(pres_medicine_name_l, '') AS source_regvalue,
        'EHR' AS type_category,
        NULL AS value_source_value,
        NULL AS value_domain_id,
        NULL AS value_vocabulary_id,
        NULL AS value_secondary_vocabulary_id,
        NULL AS value_source_regvalue,
        pres_dispense_unit_cd_s AS unit_source_value,
        'Unit' AS unit_domain_id,
        'RINCHU_DRUG_UNIT' AS unit_vocabulary_id,
        NULL AS unit_secondary_vocabulary_id,
        COALESCE(pres_dispense_unit_cd_s, '') || '|' || COALESCE(pres_dispense_unit_name_l, '') AS unit_source_regvalue,
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
        pres_dispense_amount::NUMERIC AS quantity,
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
        pres_period AS days_supply,
        COALESCE(pres_administration_cd_s,'') || '|' || 
            COALESCE(pres_administration_name_s, '') || '|' ||
            COALESCE(pres_administration_name_l, '') ||
            COALESCE(pres_supplement_cd_s, '') || '|' ||
            COALESCE(pres_supplement_name_s, '') || '|' ||
            COALESCE(pres_supplement_name_l, '') || '|' ||
            COALESCE(pres_rp_comment, '') || '|' ||
--          COALESCE(pres_instructions_cd, '') || '|' ||
            COALESCE(pres_instructions_name, '') AS sig,
        NULL AS lot_number,
        NULL::date AS verbatim_end_date,
        pres_route AS route_source_value,
        'Route' AS route_domain_id,
        'RINCHU_DRUG_ROUTE' AS route_vocabulary_id,
        NULL AS route_secondary_vocabulary_id,
/*
        CASE
            -- JHSP表 0003 用法種別
            WHEN pres_administration_type = '21' THEN pres_administration_type || '|内服'
            WHEN pres_administration_type = '22' THEN pres_administration_type || '|頓用'
            WHEN pres_administration_type = '23' THEN pres_administration_type || '|外用'
            WHEN pres_administration_type = '24' THEN pres_administration_type || '|自己注射'
            ELSE NULL
        END AS route_source_regvalue,
*/
        COALESCE(pres_route, '') || '|' || COALESCE(pres_administration_type, '') AS route_source_regvalue,
        'PrescriptionData' AS stem_source_table,
        'pres_medicine_cd_yj' AS stem_source_field,
        pres_unique_id AS stem_source_rowid
    FROM :source_schema.prescriptiondata
)

SELECT * FROM etl_stem_source_prescription;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_stem_source_prescription;
--SELECT * FROM :working_schema.v_stem_source_prescription LIMIT 100;

--- データ生成
--DELETE FROM :working_schema.stem_source WHERE table_name = 'PrescriptionData';
--INSERT INTO :working_schema.stem_source SELECT * FROM :working_schema.v_stem_source_prescription;
--SELECT * FROM :working_schema.stem_source WHERE table_name = 'PrescriptionData';
