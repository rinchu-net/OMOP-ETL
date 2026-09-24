\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_death_p AS 
SELECT 
    person_id,
    death_date,
    death_datetime,
    death_type_concept_id,
    cause_concept_id,
    cause_source_value,
    cause_source_concept_id
FROM :working_schema.death_f
ORDER BY person_id;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_death_p;
--SELECT * FROM :working_schema.v_death_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.death;
--INSERT INTO :production_schema.death SELECT * FROM :working_schema.v_death_p;
