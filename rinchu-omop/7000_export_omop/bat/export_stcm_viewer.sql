-- source_vocabulary_id別にsource_to_concept_mapをエクスポート
-- vocabulary_id: :source_vocabulary_id

\echo ==== Exporting source_to_concept_map for :source_vocabulary_id ====

\copy (SELECT * FROM :working_schema.v_source_to_concept_map_viewer WHERE source_vocabulary_id = ':source_vocabulary_id' ORDER BY source_code, target_concept_id) TO '../stcm/:output_file' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8', QUOTE '"', FORCE_QUOTE (source_code, source_vocabulary_id, source_code_description, target_concept_vocabulary_id));

\echo ==== Export completed for :source_vocabulary_id ====
