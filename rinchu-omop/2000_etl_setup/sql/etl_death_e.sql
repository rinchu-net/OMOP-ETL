\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_death_e AS 
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
    load_row_id,
    CASE
        WHEN person_id IS NULL OR person_id = 0 THEN 'person_id'
        WHEN death_date IS NULL THEN 'death_date'
        ELSE NULL
    END AS etl_error_column
FROM :working_schema.death_m
WHERE person_id IS NULL OR person_id = 0
OR death_date IS NULL;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_death_e;
--SELECT * FROM :working_schema.v_death_e LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.death_e;
--INSERT INTO :working_schema.death_e SELECT * FROM :working_schema.v_death_e;
