\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_vdeath_m
-- Purpose: Create mapped data from death_s
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_death_m AS 
SELECT 
    p.person_id,
    d.person_source_value,
    d.death_date,
    d.death_datetime,
    d.death_type_concept_id,
    NULL::integer AS cause_concept_id,
    d.cause_source_value,
    NULL::integer AS cause_source_concept_id,
    d.table_name,
    d.field_name,
    d.load_row_id
FROM :working_schema.death_s d
LEFT JOIN :working_schema.person_f p ON d.person_source_value = p.person_source_value
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_death_m;
--SELECT * FROM :working_schema.v_death_m LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.death_m;
--INSERT INTO :working_schema.death_m SELECT * FROM :working_schema.v_death_m;
