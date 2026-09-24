\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_drug_exposure_e AS
WITH
cte_drug_exposure_e AS (
    SELECT *,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
--      WHEN drug_concept_id IS NULL or drug_concept_id = 0 THEN 'drug_concept_id'
        WHEN drug_concept_id IS NULL THEN 'drug_concept_id'
        WHEN drug_exposure_start_date IS NULL THEN 'drug_exposure_start_date'
        WHEN drug_exposure_end_date IS NULL THEN 'drug_exposure_end_date'
        WHEN drug_type_concept_id IS NULL THEN 'drug_type_concept_id'
        ELSE NULL
    END AS error_column
    FROM :working_schema.drug_exposure_m
    WHERE person_id IS NULL OR person_id = 0
--  OR drug_concept_id IS NULL OR drug_concept_id = 0
    OR drug_concept_id IS NULL
    OR drug_exposure_start_date IS NULL
    OR drug_exposure_end_date IS NULL
    OR drug_type_concept_id IS NULL
)

-- 最終SELECT
SELECT * FROM cte_drug_exposure_e;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_drug_exposure_e;
--SELECT * FROM :working_schema.v_drug_exposure_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.drug_exposure_e;
--INSERT INTO :working_schema.drug_exposure_e SELECT * FROM :working_schema.v_drug_exposure_e;
