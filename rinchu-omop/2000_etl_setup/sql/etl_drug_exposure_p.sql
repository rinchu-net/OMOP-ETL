\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_drug_exposure_p AS
WITH

-- ==================================================
-- cte_drug_exposure: Drugドメイン変換
-- OMOP中間テーブルからdrug_exposure形式への変換処理
-- ==================================================
cte_drug_exposure_p AS (
    SELECT
        -- Primary Key: drug_exposure_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, drug_exposure_start_date, drug_type_concept_id, drug_source_value) AS drug_exposure_id,

        -- Patient Information: 患者情報
        person_id,

        -- Drug Concept Information: 薬剤概念情報
        drug_concept_id,

        -- Date Information: 投与日付情報
        drug_exposure_start_date,
        drug_exposure_start_datetime,
        drug_exposure_end_date,
        drug_exposure_end_datetime,
        verbatim_end_date,
        
        -- Type Information: 投与種別情報
        drug_type_concept_id,
        
        -- Clinical Information: 臨床情報
        stop_reason,
        refills,
        quantity,
        days_supply,
        sig,
        route_concept_id,
        lot_number,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        drug_source_value,
        drug_source_concept_id,
        route_source_value,
        dose_unit_source_value
        
    FROM :working_schema.drug_exposure_f
)

-- 最終SELECT
SELECT * FROM cte_drug_exposure_p;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_drug_exposure_p;
--SELECT * FROM :working_schema.v_drug_exposure_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.drug_exposure;
--INSERT INTO :production_schema.drug_exposure SELECT * FROM :working_schema.v_drug_exposure_p;
