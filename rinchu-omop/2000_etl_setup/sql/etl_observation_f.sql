\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_observation_f AS
WITH
cte_observation_f AS (
    SELECT *
    FROM :working_schema.observation_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND observation_concept_id IS NOT NULL AND observation_concept_id > 0
    AND observation_concept_id IS NOT NULL
    AND observation_date IS NOT NULL
    AND observation_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_observation_f;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_observation_f;
SELECT * FROM :working_schema.v_observation_f LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.observation_f;
INSERT INTO :working_schema.observation_f SELECT * FROM :working_schema.v_observation_f;
*/