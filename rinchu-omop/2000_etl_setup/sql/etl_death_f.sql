\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_death_f AS 
SELECT 
    person_id,
    person_source_value,
    death_date,
    death_datetime,
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id,
    table_name,
    field_name,
    load_row_id
FROM :working_schema.death_m
WHERE person_id IS NOT NULL AND person_id <> 0
AND death_date IS NOT NULL;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_death_f;
--SELECT * FROM :working_schema.v_death_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.death_f;
--INSERT INTO :working_schema.death_f SELECT * FROM :working_schema.v_death_f;
