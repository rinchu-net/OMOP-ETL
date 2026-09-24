\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_location_f AS
WITH 
cte_base AS (
SELECT DISTINCT left(jiscode,2) AS prefectureno, prefecture
FROM :source_schema.mst_zipcode GROUP BY left(jiscode,2), prefecture
),

cte_location AS (
SELECT
prefectureno::integer AS location_id,
NULL::varchar AS address_1,
NULL::varchar AS address_2,
NULL::varchar AS city,
NULL::varchar AS state,
NULL::varchar AS zip,
NULL::varchar AS county,
prefecture AS location_source_value,
4329983 AS country_concept_id,
'Japan' AS country_source_value,
NULL::integer AS latitude,
NULL::integer AS longitude
FROM cte_base
)

SELECT * FROM cte_location ORDER BY location_id;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_location_f;
--SELECT * FROM :working_schema.v_location_f LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.location_f;
--INSERT INTO :working_schema.location_f SELECT * FROM :working_schema.v_location_f;
