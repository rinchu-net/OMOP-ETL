\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_specimen_f AS
WITH
cte_specimen_f AS (
    SELECT *
    FROM :working_schema.specimen_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND specimen_concept_id IS NOT NULL AND specimen_concept_id > 0
    AND specimen_concept_id IS NOT NULL
    AND specimen_date IS NOT NULL
    AND specimen_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_specimen_f;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_specimen_f;
SELECT * FROM :working_schema.v_specimen_f LIMIT 100;

--- データ生成
TRUNCATE TABLE :working_schema.specimen_f;
INSERT INTO :working_schema.specimen_f SELECT * FROM :working_schema.v_specimen_f;
*/