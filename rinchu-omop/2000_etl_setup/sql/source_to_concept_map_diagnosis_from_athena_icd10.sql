/*
============================================================
  Script Name : source_to_concept_map_athena_icd10.sql
  Description : ATHENA conceptのICD10コードを元に、
                Standard Conceptのconcept_idに変換するsource_to_concept_mapを作成する

  構成概要：
  1. cte_00_icd10_to_standard
     - ATHENA concept/concept_relationshipからICD10とStandard Conceptとの対応表
     (マッピング先はStandard conceptに限定)

  2. cte_final
     - source_to_concept_map形式に整形

  出力：OMOP CDMのsource_to_concept_map形式に準拠したデータセット
============================================================
*/
CREATE OR REPLACE VIEW :working_schema.v_source_to_concept_map_athena_icd10 AS
WITH

-- conceptとconcept_relationshipを使用してICD10(non-standard)とstandard conceptとの対応表を作成する
cte_00_icd10_to_standard AS(
SELECT
    cr.concept_id_1,
    c1.concept_name AS concept_name_1,
    c1.vocabulary_id AS vocabulary_id_1,
    c1.domain_id AS domain_id_1,
    c1.concept_class_id AS concept_class_id_1,
    c1.concept_code AS concept_code_1,
    cr.relationship_id, 
    cr.concept_id_2,
    c2.concept_name AS concept_name_2,
    c2.vocabulary_id AS vocabulary_id_2,
    c2.domain_id AS domain_id_2,
    c2.concept_class_id AS concept_class_id_2,
    c2.concept_code AS concept_code_2,
    c2.valid_start_date AS valid_start_date_2,
    c2.valid_end_date AS valid_end_date_2,
    c2.invalid_reason AS invalid_reason_2
FROM :working_schema.concept_relationship_f cr
JOIN :working_schema.concept_f c1 ON cr.concept_id_1 = c1.concept_id
JOIN :working_schema.concept_f c2 ON cr.concept_id_2 = c2.concept_id
WHERE
    c1.vocabulary_id = 'ICD10'
--  AND c2.vocabulary_id = 'SNOMED'
    AND c2.standard_concept = 'S'
),

cte_final AS(
	SELECT
        concept_code_1 AS source_code,
        concept_id_1 AS source_concept_id,
        CASE
            WHEN relationship_id ='Maps to value' THEN 'ATHENA_ICD10_VALUE'
            ELSE 'ATHENA_ICD10'
        END AS source_vocabulary_id,
        concept_name_1 AS source_code_description,
        COALESCE(concept_id_2,0) AS target_concept_id,
		COALESCE(vocabulary_id_2,'')  AS target_vocabulary_id,
        COALESCE(valid_start_date_2, TO_DATE('19700101','YYYYMMDD')) AS valid_start_date,
        COALESCE(valid_end_date_2, TO_DATE('20991231','YYYYMMDD')) AS valid_end_date,
		invalid_reason_2 AS invalid_reason
	FROM cte_00_icd10_to_standard
	ORDER BY source_code, target_vocabulary_id, target_concept_id
)

SELECT * FROM cte_final ORDER BY source_code, source_vocabulary_id, target_concept_id;



/* source_to_concept_mapへの登録
DELETE FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id = 'ICD10';
INSERT INTO :working_schema.source_to_concept_map_f SELECT * FROM :working_schema.v_source_to_concept_map_athena_icd10;
SELECT * FROM :working_schema.source_to_concept_map_f WHERE source_vocabulary_id = 'ICD10';
*/

/*　domain_idを付加してSELECT
SELECT source_code, source_concept_id, source_vocabulary_id, source_code_description, target_concept_id, target_vocabulary_id, c.domain_id, c.concept_class_id, c.concept_name
FROM  :working_schema.v_source_to_concept_map_athena_icd10
LEFT JOIN :working_schema.concept_f c ON target_concept_id = c.concept_id
ORDER BY source_code;
*/

