\set ON_ERROR_STOP on
\echo ==== souce_to_concept_map checklist  ====
-- Note: work_mem は ALTER DATABASE で DB 単位永続化済 (256MB)
\copy (SELECT * FROM @schema.v_source_to_concept_map_base) TO '../checklist/source_to_concept_map_checklist.csv' CSV HEADER
