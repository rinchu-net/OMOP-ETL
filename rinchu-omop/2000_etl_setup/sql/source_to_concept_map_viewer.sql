CREATE OR REPLACE VIEW :working_schema.v_source_to_concept_map_viewer AS
SELECT
    stcm.source_code,
    stcm.source_code_description,
    stcm.source_vocabulary_id,
    stcm.source_concept_id,

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

    cs.concept_name AS source_concept_name,
    cs.vocabulary_id AS source_concept_vocabulary_id,
    cs.domain_id AS source_concept_domain_id,
    cs.concept_class_id AS source_concept_class_id,
    cs.concept_code AS source_concept_code,
    cs.standard_concept AS source_standard_concept,

    stcm.target_concept_id,
    ct.concept_name AS target_concept_name,
    ct.vocabulary_id AS target_concept_vocabulary_id,
    ct.domain_id AS target_concept_domain_id,
    ct.concept_class_id AS target_concept_class_id,
    ct.concept_code AS target_concept_code,
    ct.standard_concept AS target_standard_concept,
    cs.valid_start_date AS target_valid_start_date,
    cs.valid_end_date AS target_valid_end_date,
    cs.invalid_reason AS target_invalid_reason

FROM :working_schema.source_to_concept_map_f stcm
LEFT OUTER JOIN :working_schema.concept_f cs ON stcm.source_concept_id = cs.concept_id
LEFT OUTER JOIN :working_schema.concept_f ct ON stcm.target_concept_id = ct.concept_id
ORDER BY stcm.source_vocabulary_id,stcm.source_code, stcm.target_vocabulary_id, stcm.target_concept_id;