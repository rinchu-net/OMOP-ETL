\set ON_ERROR_STOP on
\echo ==== ATHENA ICD10 to Standard Concept  ====
\copy (SELECT * FROM @schema.v_source_to_concept_map_athena_icd10) TO '../stcm/source_to_concept_map_ATHENA_ICD10.csv' CSV HEADER
\echo ==== MEDIS Specific ICD10 to Standard Concept  ====
\copy (SELECT * FROM @schema.v_source_to_concept_map_athena_icd10_medisextention) TO '../stcm/source_to_concept_map_ATHENA_ICD10_MEDISEXTENTION.csv' CSV HEADER
\echo ==== MEDIS BYOMEI KANRINO to Standard Concept (via ATHENA) ====
\copy (SELECT * FROM @schema.v_source_to_concept_map_medis_diagknr) TO '../stcm/source_to_concept_map_MEDIS_DIAGKNR.csv' CSV HEADER
\echo ==== MEDIS BYOMEI EXCHANGENO to Standard Concept (via ATHENA) ====
\copy (SELECT * FROM @schema.v_source_to_concept_map_medis_diagexc) TO '../stcm/source_to_concept_map_MEDIS_DIAGEXC.csv' CSV HEADER
--\echo ==== MEDIS DRUG YJ CODE to Standard Concept (via MENDELEY) ====
--\copy (SELECT * FROM @schema.v_source_to_concept_map_drug_mendeley_yj ORDER BY source_code) TO '../stcm/source_to_concept_map_MENDELEY_DRUGYJ.csv' CSV HEADER