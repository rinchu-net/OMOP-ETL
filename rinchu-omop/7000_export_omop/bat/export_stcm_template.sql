-- source_vocabulary_id別にデータ実績に基づくsource_to_concept_mapひな形を作成をエクスポート
-- vocabulary_id: :source_vocabulary_id

\echo ==== Exporting source_to_concept_map_template for :source_vocabulary_id ====

\copy (SELECT source_code, source_concept_id, source_vocabulary_id, source_code_description, target_concept_id, target_concept_vocabulary_id AS target_vocabulary_id, target_valid_start_date AS valid_start_date, target_valid_end_date AS valid_end_date, target_invalid_reason AS invalid_reason FROM :working_schema.v_source_to_concept_map_base WHERE source_vocabulary_id = ':source_vocabulary_id' ORDER BY source_vocabulary_id, source_code, target_vocabulary_id, target_concept_id ) TO '../stcm/:output_file' WITH (FORMAT CSV, HEADER TRUE, ENCODING 'UTF8', QUOTE '"', FORCE_QUOTE (source_code, source_vocabulary_id, source_code_description, target_vocabulary_id));

\echo ==== Export completed for :source_vocabulary_id ====

;
