\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_procedure_occurrence_p AS
WITH

-- ==================================================
-- cte_procedure_occurrence: Procedureドメイン変換
-- OMOP中間テーブルからprocedure_occurrence形式への変換処理
-- ==================================================
cte_procedure_occurrence AS (
    SELECT
        -- Primary Key: procedure_occurrence_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, procedure_date, procedure_type_concept_id, procedure_source_value) AS procedure_occurrence_id,
        
        -- Patient Information: 患者情報
        person_id,
        
        -- Procedure Concept Information: 診療行為概念情報
        procedure_concept_id,
        
        -- Date Information: 実施日付情報
        procedure_date,
        procedure_datetime,
        procedure_end_date,
        procedure_end_datetime,
        
        -- Type Information: 実施種別情報
        procedure_type_concept_id,
        
        -- Procedure Specific Information: 診療行為固有情報
        modifier_concept_id,
        quantity,
        
        -- Provider Information: 医療従事者・医療機関情報
        provider_id,
        
        -- Visit Information: 受診情報
        visit_occurrence_id,
        visit_detail_id,
        
        -- Source Information: ソース情報
        procedure_source_value,
        procedure_source_concept_id,
        modifier_source_value
        
    FROM :working_schema.procedure_occurrence_f
)

-- 最終SELECT
SELECT * FROM cte_procedure_occurrence;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_procedure_occurrence_p;
SELECT * FROM :working_schema.v_procedure_occurrence_p LIMIT 100;

--- データ生成
TRUNCATE TABLE :production_schema.procedure_occurrence;
INSERT INTO :production_schema.procedure_occurrence SELECT * FROM :working_schema.v_procedure_occurrence_p;
*/