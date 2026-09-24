\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_observation_e AS
WITH
cte_observation_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN observation_concept_id IS NULL or observation_concept_id = 0 THEN 'observation_concept_id'
        WHEN observation_concept_id IS NULL THEN 'observation_concept_id'
        WHEN observation_date IS NULL THEN 'observation_date'
        WHEN observation_type_concept_id IS NULL THEN 'observation_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.observation_m
    WHERE person_id IS NULL OR person_id = 0
--  OR observation_concept_id IS NULL OR observation_concept_id = 0
    OR observation_concept_id IS NULL
    OR observation_date IS NULL
    OR observation_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_observation_e;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_observation_e;
SELECT * FROM :working_schema.v_observation_e LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.observation_e;
INSERT INTO :working_schema.observation_e SELECT * FROM :working_schema.v_observation_e;
*/