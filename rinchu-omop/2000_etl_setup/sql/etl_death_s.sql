\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_vdeath_s
-- Purpose: Create source data from PatientVisit
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_death_s AS 
WITH
cte_death AS (
    SELECT 
        patient_id AS person_source_value,
        TO_DATE(pv_discharge_date, 'YYYYMMDD') AS death_date,
		CASE
			WHEN pv_discharge_time = '999999' OR pv_discharge_time IS NULL OR pv_discharge_time ~ '^[0-9]{6}$' = false 
			     OR SUBSTRING(pv_discharge_time, 1, 2)::integer >= 24 
			     OR SUBSTRING(pv_discharge_time, 3, 2)::integer >= 60 
			     OR SUBSTRING(pv_discharge_time, 5, 2)::integer >= 60 
			THEN TO_TIMESTAMP(pv_discharge_date || '000000','YYYYMMDDHH24MISS')
			ELSE TO_TIMESTAMP(pv_discharge_date || pv_discharge_time,'YYYYMMDDHH24MISS')
		END AS death_datetime,
        32817 AS death_type_concept_id,
        NULL AS cause_source_value,
        pv_unique_id AS load_row_id,
        ROW_NUMBER() OVER (PARTITION BY patient_id ORDER BY pv_discharge_date ASC, pv_discharge_time ASC) AS rn
    FROM :source_schema.patientvisit
    WHERE pv_discharge_date IS NOT NULL AND pv_discharge_cd_l = '20'
),

cte_final AS (
    SELECT 
        person_source_value,
        death_date,
        death_datetime,
        death_type_concept_id,
        cause_source_value,
        'PatientVisit' AS table_name,
        'pv_discharge_cd_l' AS field_name,
        load_row_id
    FROM cte_death
    WHERE rn = 1
)

SELECT * FROM cte_final;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_death_s;
--SELECT * FROM :working_schema.v_death_s LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.death_s;
--INSERT INTO :working_schema.death_s SELECT * FROM :working_schema.v_death_s;
