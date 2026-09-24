-- source_vocabulary_idの一覧を取得


SELECT DISTINCT source_vocabulary_id
FROM stage.v_source_to_concept_map_base
WHERE source_vocabulary_id IS NOT NULL
ORDER BY source_vocabulary_id;
