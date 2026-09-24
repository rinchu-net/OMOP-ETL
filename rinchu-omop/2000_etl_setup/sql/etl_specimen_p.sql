\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_specimen_p AS
WITH

cte_specimen AS (
    SELECT
        -- Primary Key: specimen_id（連番付与）
        ROW_NUMBER() OVER (ORDER BY person_id, specimen_date, specimen_type_concept_id, specimen_source_value) AS specimen_id,

        -- Patient Information: 患者情報
        person_id,
        
        -- Specimen Concept Information: 検体概念情報
        specimen_concept_id,

        -- Type Information: 測定種別情報
        specimen_type_concept_id,
        
        -- Date Information: 採取日付情報
        specimen_date,
        specimen_datetime,
        
        -- Quantity Information: 採取量情報
        quantity,

        -- Unit Information: 単位情報
        unit_concept_id,

        -- Anatomic Site Information: 解剖学的部位情報
        anatomic_site_concept_id,
        
        -- Disease Status Information: 疾患状態情報
        disease_status_concept_id,

        -- Source Information: ソース情報
        specimen_source_id,
        specimen_source_value,
        unit_source_value,
        anatomic_site_source_value,
        disease_status_source_value

    FROM :working_schema.specimen_f
)

-- 最終SELECT
SELECT * FROM cte_specimen;

/*
--- テストクエリ
SELECT COUNT(1) FROM :working_schema.v_specimen_p;
SELECT * FROM :working_schema.v_specimen_p LIMIT 100;

--- データ生成
TRUNCATE TABLE :production_schema.specimen_p;
INSERT INTO :production_schema.specimen_p SELECT * FROM :working_schema.v_specimen_p;
*/