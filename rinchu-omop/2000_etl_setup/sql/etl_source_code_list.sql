\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_source_code_list AS
SELECT DISTINCT
    stm.source_value AS source_code,
    stm.source_vocabulary_id AS source_vocabulary_id,
    stm.source_domain_id AS source_domain_id,
    COALESCE(c1.concept_name, stm.source_regvalue) AS source_code_description,
    COALESCE(c1.concept_id, 0) AS source_concept_id,
    COALESCE(c1.concept_id, 0) AS target_concept_id,
    c1.vocabulary_id AS target_vocabulary_id,
    c1.domain_id AS target_domain_id,
    c1.concept_class_id AS target_class_id
FROM :working_schema.stem_source stm
LEFT JOIN :working_schema.concept_f c1 ON  stm.source_value = c1.concept_code
    AND stm.source_vocabulary_id = c1.vocabulary_id
    AND stm.source_domain_id = c1.domain_id
    AND c1.invalid_reason IS NULL
;
