\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_source_to_concept_map_base AS
WITH
cte_visit_occurrence_visit_source_value AS (
    SELECT
        'visit_source_value' AS field_name,
        visit_source_value AS source_code,
        visit_source_regvalue AS source_code_description,
        visit_source_vocabulary_id AS source_vocabulary_id,
        visit_source_domain_id AS source_domain_id,
        table_name AS source_table_name,
        field_name AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.visit_occurrence_s
    WHERE visit_source_value IS NOT NULL
    GROUP BY visit_source_value, visit_source_regvalue, visit_source_vocabulary_id, visit_source_domain_id, source_table_name, source_field_name
),

cte_visit_occurrence_discharged_to_source_value AS (
    SELECT
        'discharged_to_source_value' AS field_name,
        discharged_to_source_value AS source_code,
        discharged_to_source_value AS source_code_description,
        discharged_to_vocabulary_id AS source_vocabulary_id,
        discharged_to_domain_id AS source_domain_id,
        table_name AS source_table_name,
        'pv_discharge_cd_l' AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.visit_occurrence_s
    WHERE discharged_to_source_value IS NOT NULL
    GROUP BY discharged_to_source_value, discharged_to_vocabulary_id, discharged_to_domain_id, source_table_name, source_field_name
),

cte_stem_source_value AS (
    SELECT
        CASE
            WHEN source_domain_id = 'Condition' THEN 'condition_source_value'
            WHEN source_domain_id = 'Drug' THEN 'drug_source_value'
            WHEN source_domain_id = 'Procedure' THEN 'procedure_source_value'
            WHEN source_domain_id = 'Device' THEN 'device_source_value'
            WHEN source_domain_id = 'Measurement' THEN 'measurement_source_value'
            WHEN source_domain_id = 'Observation' THEN 'observation_source_value'
            WHEN source_domain_id = 'Specimen' THEN 'specimen_source_value'
            WHEN source_domain_id = 'Visit' THEN 'visit_source_value'
            ELSE 'unknown_source_value'
        END AS field_name,
        source_value AS source_code,
        MIN(source_regvalue) AS source_code_description,
--      source_vocabulary_id AS source_vocabulary_id,
        mapped_source_vocabulary_id AS source_vocabulary_id,
        source_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        stem_source_field AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE source_value IS NOT NULL
    GROUP BY source_value, mapped_source_vocabulary_id, source_domain_id, source_table_name, source_field_name
),

cte_stem_value_source_value AS (
    SELECT
        'value_source_value' AS field_name,
        value_source_value AS source_code,
        MIN(value_source_regvalue) AS source_code_description,
--      value_vocabulary_id AS source_vocabulary_id,
        mapped_value_vocabulary_id AS source_vocabulary_id,
        value_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE value_source_value IS NOT NULL
    GROUP BY value_source_value, mapped_value_vocabulary_id, value_domain_id, source_table_name, source_field_name
),

cte_stem_unit_source_value AS (
    SELECT
        'unit_source_value' AS field_name,
        unit_source_value AS source_code,
        MIN(unit_source_regvalue) AS source_code_description,
--      unit_vocabulary_id AS source_vocabulary_id,
        mapped_unit_vocabulary_id AS source_vocabulary_id,
        unit_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE unit_source_value IS NOT NULL
    GROUP BY unit_source_value, mapped_unit_vocabulary_id, unit_domain_id, source_table_name, source_field_name
),

cte_stem_qualifier_source_value AS (
    SELECT
        'qualifier_source_value' AS field_name,
        qualifier_source_value AS source_code,
        MIN(qualifier_source_regvalue) AS source_code_description,
--      qualifier_vocabulary_id AS source_vocabulary_id,
        mapped_qualifier_vocabulary_id AS source_vocabulary_id,
        qualifier_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE qualifier_source_value IS NOT NULL
    GROUP BY qualifier_source_value, mapped_qualifier_vocabulary_id, qualifier_domain_id, source_table_name, source_field_name
),

cte_stem_operator_source_value AS (
    SELECT
        'operator_source_value' AS field_name,
        operator_source_value AS source_code,
        MIN(operator_source_regvalue) AS source_code_description,
--      operator_vocabulary_id AS source_vocabulary_id,
        mapped_operator_vocabulary_id AS source_vocabulary_id,
        operator_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE operator_source_value IS NOT NULL
    GROUP BY operator_source_value, mapped_operator_vocabulary_id, operator_domain_id, source_table_name, source_field_name
),

cte_stem_anatomic_site_source_value AS (
    SELECT
        'anatomic_site_source_value' AS field_name,
        anatomic_site_source_value AS source_code,
        MIN(anatomic_site_source_regvalue) AS source_code_description,
--      anatomic_site_vocabulary_id AS source_vocabulary_id,
        mapped_anatomic_site_vocabulary_id AS source_vocabulary_id,
        anatomic_site_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE anatomic_site_source_value IS NOT NULL
    GROUP BY anatomic_site_source_value, mapped_anatomic_site_vocabulary_id, anatomic_site_domain_id, source_table_name, source_field_name
),

cte_stem_status_source_value AS (
    SELECT
        'status_source_value' AS field_name,
        status_source_value AS source_code,
        MIN(status_source_regvalue) AS source_code_description,
--      status_vocabulary_id AS source_vocabulary_id,
        mapped_status_vocabulary_id AS source_vocabulary_id,
        status_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE status_source_value IS NOT NULL
    GROUP BY status_source_value, mapped_status_vocabulary_id, status_domain_id, source_table_name, source_field_name
),

cte_stem_modifier_source_value AS (
    SELECT
        'modifier_source_value' AS field_name,
        modifier_source_value AS source_code,
        MIN(modifier_source_regvalue) AS source_code_description,
--      modifier_vocabulary_id AS source_vocabulary_id,
        mapped_modifier_vocabulary_id AS source_vocabulary_id,
        modifier_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE modifier_source_value IS NOT NULL
    GROUP BY modifier_source_value, mapped_modifier_vocabulary_id, modifier_domain_id, source_table_name, source_field_name
),

cte_stem_route_source_value AS (
    SELECT
        'route_source_value' AS field_name,
        route_source_value AS source_code,
        MIN(route_source_regvalue) AS source_code_description,
--      route_vocabulary_id AS source_vocabulary_id,
        mapped_route_vocabulary_id AS source_vocabulary_id,
        route_domain_id AS source_domain_id,
        stem_source_table AS source_table_name,
        NULL AS source_field_name,
        COUNT(1) AS reccount
    FROM :working_schema.stem_m
    WHERE route_source_value IS NOT NULL
    GROUP BY route_source_value, mapped_route_vocabulary_id, route_domain_id, source_table_name, source_field_name
),


cte_all_source_codes AS (
    SELECT * FROM cte_visit_occurrence_visit_source_value
    UNION ALL
    SELECT * FROM cte_visit_occurrence_discharged_to_source_value
    UNION ALL
    SELECT * FROM cte_stem_source_value
    UNION ALL
    SELECT * FROM cte_stem_value_source_value
    UNION ALL
    SELECT * FROM cte_stem_unit_source_value
    UNION ALL
    SELECT * FROM cte_stem_qualifier_source_value
    UNION ALL
    SELECT * FROM cte_stem_operator_source_value
    UNION ALL
    SELECT * FROM cte_stem_anatomic_site_source_value
    UNION ALL
    SELECT * FROM cte_stem_status_source_value
    UNION ALL
    SELECT * FROM cte_stem_modifier_source_value
    UNION ALL
    SELECT * FROM cte_stem_route_source_value
),

cte_source_to_concept_map AS (
    SELECT
        s.field_name,
        s.source_table_name,
        s.source_field_name,
        s.source_code,
        s.source_code_description,
        s.source_vocabulary_id,
        s.source_domain_id,
        s.reccount,
        CASE
            WHEN stcm.source_concept_id is NULL THEN 'N' 
            ELSE 'Y'
        END AS stcm,
        CASE
            WHEN stcm.target_concept_id is NULL THEN 'N'
            WHEN stcm.target_concept_id is NOT NULL AND ct.concept_id = 0 THEN 'U'
            WHEN stcm.target_concept_id is NOT NULL AND ct.concept_name IS NULL THEN 'E'
            WHEN stcm.target_concept_id is NOT NULL AND ct.standard_concept IS NULL THEN 'E'
            WHEN stcm.target_concept_id is NOT NULL AND ct.valid_start_date >= CURRENT_DATE THEN 'E'
            WHEN stcm.target_concept_id is NOT NULL AND ct.valid_end_date < CURRENT_DATE THEN 'E'
            WHEN stcm.target_concept_id is NOT NULL AND ct.concept_name IS NOT NULL THEN 'Y'
            ELSE NULL
        END AS std_mapped,
        ROW_NUMBER() OVER (PARTITION BY s.source_table_name, s.source_field_name, s.source_code ORDER BY s.source_code) AS rn,
        stcm.source_concept_id,
        cs.concept_name AS source_concept_name,
        cs.vocabulary_id AS source_concept_vocabulary_id,
        cs.domain_id AS source_concept_domain_id,
        cs.concept_class_id AS source_concept_class_id,
        stcm.target_concept_id,
        ct.concept_name AS target_concept_name,
        ct.vocabulary_id AS target_concept_vocabulary_id,
        ct.domain_id AS target_concept_domain_id,
        ct.concept_class_id AS target_concept_class_id,
        ct.standard_concept AS target_standard_concept,
        ct.valid_start_date AS target_valid_start_date,
        ct.valid_end_date AS target_valid_end_date,
        ct.invalid_reason AS target_invalid_reason
    FROM cte_all_source_codes s
    LEFT JOIN :working_schema.source_to_concept_map_f stcm
    ON s.source_code = stcm.source_code AND s.source_vocabulary_id = stcm.source_vocabulary_id
    LEFT JOIN :working_schema.concept_f cs
    ON stcm.source_concept_id = cs.concept_id AND cs.invalid_reason IS NULL
    LEFT JOIN :working_schema.concept_f ct
    ON stcm.target_concept_id = ct.concept_id AND ct.invalid_reason IS NULL
)

SELECT * FROM cte_source_to_concept_map
ORDER BY field_name ASC,
source_table_name ASC,
source_field_name ASC,
reccount desc,
source_code asc,
rn asc;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_source_to_concept_map_base;
SELECT * FROM :working_schema.v_source_to_concept_map_base LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.source_to_concept_map_base;
INSERT INTO :working_schema.source_to_concept_map_base SELECT * FROM :working_schema.v_source_to_concept_map_base;
SELECT * FROM :working_schema.source_to_concept_map_base;
*/