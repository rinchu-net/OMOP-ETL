\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_person_s
-- Purpose: Create source data from PatientIdentification and PatientAddress
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_person_s AS 
WITH
-- 郵便番号7桁の先頭でユニーク化し、jiscode昇順でprefectureの先頭1件のみ取得
cte_zip7 AS (
	SELECT zip7, jiscode, prefecture FROM (
		SELECT
			zipcode AS zip7,
			jiscode,
			prefecture,
			ROW_NUMBER() OVER (PARTITION BY zipcode ORDER BY zipcode ASC, jiscode ASC) AS rn
		FROM :source_schema.mst_zipcode
	) t
	WHERE rn = 1
),
-- 郵便番号5桁の先頭でユニーク化し、jiscode昇順でprefectureの先頭1件のみ取得
cte_zip5 AS (
	SELECT zip5, jiscode, prefecture FROM (
		SELECT
			LEFT(zipcode,5) AS zip5,
			jiscode,
			prefecture,
			ROW_NUMBER() OVER (PARTITION BY LEFT(zipcode,5) ORDER BY LEFT(zipcode,5) ASC, jiscode ASC) AS rn
		FROM :source_schema.mst_zipcode
	) t
	WHERE rn = 1
),
-- 郵便番号3桁の先頭でユニーク化し、jiscode昇順でprefectureの先頭1件のみ取得
cte_zip3 AS (
	SELECT zip3, jiscode, prefecture FROM (
		SELECT
			LEFT(zipcode,3) AS zip3,
			jiscode,
			prefecture,
			ROW_NUMBER() OVER (PARTITION BY LEFT(zipcode,3) ORDER BY LEFT(zipcode,3) ASC, jiscode ASC) AS rn
		FROM :source_schema.mst_zipcode
	) t
	WHERE rn = 1
),
cte_person_s AS (
SELECT 
	i.pi_unique_id AS person_id,
	EXTRACT(YEAR FROM i.sch_birthdate) AS year_of_birth,
	EXTRACT(MONTH FROM i.sch_birthdate) AS month_of_birth,
	EXTRACT(DAY FROM i.sch_birthdate) AS day_of_birth,
	sch_birthdate::timestamp AS birth_datetime,
	z7.prefecture AS prefecture_7,
	z5.prefecture AS prefecture_5,
	z3.prefecture AS prefecture_3,
	NULL AS provider_source_value,
	CAST(:care_site_source_value AS VARCHAR) AS care_site_source_value,
	i.patient_id AS person_source_value,
	i.sex AS gender_source_value,
	CASE
		WHEN i.sex = 'M' THEN 'M:男性'
		WHEN i.sex = 'F' THEN 'F:女性'
		WHEN i.sex = 'U' THEN 'U:未知'
		ELSE 'O:その他'
	END AS gender_source_regvalue,
	'Gender' AS gender_vocabulary_id,
	'Gender' AS gender_domain_id,
	i.race AS race_source_value,
	'RINCHU_RACE' AS race_vocabulary_id,
	'Race' AS race_domain_id,
	i.race AS race_source_regvalue,
	i.ethnic_group AS ethnicity_source_value,
	'RINCHU_ETHINICITY' AS ethnicity_vocabulary_id,
	'Ethnicity' AS ethnicity_domain_id,
	i.ethnic_group AS ethnicity_source_regvalue,
	ROW_NUMBER() OVER (PARTITION BY i.patient_id ORDER BY a.pa_start_date DESC) AS rownum,
	'PatientIdentification' AS table_name,
	'PATIENT_ID' AS field_name,
	i.pi_unique_id AS load_row_id
FROM :source_schema.patientidentification i
LEFT JOIN :source_schema.patientaddress a ON i.pi_unique_id = a.pa_unique_id
LEFT JOIN cte_zip7 z7 ON z7.zip7 = a.postal_cd
LEFT JOIN cte_zip5 z5 ON z5.zip5 = LEFT(a.postal_cd,5)
LEFT JOIN cte_zip3 z3 ON z3.zip3 = LEFT(a.postal_cd,3)
),

cte_final AS (
SELECT 
	person_id,
	year_of_birth,
	month_of_birth,
	day_of_birth,
	birth_datetime,
	-- 7桁->5桁->3桁の順で優先的にprefectureを採用
	COALESCE(prefecture_7, prefecture_5, prefecture_3) AS location_source_value,
	provider_source_value,
	care_site_source_value,
	person_source_value,
	gender_source_value,
	gender_vocabulary_id,
	gender_domain_id,
	gender_source_regvalue,
	race_source_value,
	race_vocabulary_id,
	race_domain_id,
	race_source_regvalue,
	ethnicity_source_value,
	ethnicity_vocabulary_id,
	ethnicity_domain_id,
	ethnicity_source_regvalue,
	rownum,
	table_name,
	field_name,
	load_row_id
FROM cte_person_s
)

SELECT * FROM cte_final ORDER BY person_id, rownum;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_person_s;
--SELECT * FROM :working_schema.v_person_s LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.person_s;
--INSERT INTO :working_schema.person_s SELECT * FROM :working_schema.v_person_s
