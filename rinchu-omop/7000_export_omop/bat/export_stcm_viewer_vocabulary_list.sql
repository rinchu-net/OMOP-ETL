-- source_vocabulary_idの一覧を取得
SELECT DISTINCT source_vocabulary_id
FROM :working_schema.v_source_to_concept_map_viewer
WHERE source_vocabulary_id IS NOT NULL
ORDER BY source_vocabulary_id;
