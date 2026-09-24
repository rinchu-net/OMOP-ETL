\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_drug_exposure_f AS
WITH
cte_drug_exposure_f AS (
    SELECT *
    FROM :working_schema.drug_exposure_m
    WHERE person_id IS NOT NULL AND person_id <> 0
--  AND drug_concept_id IS NOT NULL AND drug_concept_id > 0
    AND drug_concept_id IS NOT NULL
    AND drug_exposure_start_date IS NOT NULL
    AND drug_exposure_end_date IS NOT NULL
    AND drug_type_concept_id IS NOT NULL
)

-- 最終SELECT
SELECT * FROM cte_drug_exposure_f;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_drug_exposure_f;
--SELECT * FROM :working_schema.v_drug_exposure_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.drug_exposure_f;
--INSERT INTO :working_schema.drug_exposure_f SELECT * FROM :working_schema.v_drug_exposure_f;
