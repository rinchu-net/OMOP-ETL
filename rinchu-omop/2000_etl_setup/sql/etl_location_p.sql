\set ON_ERROR_STOP on
CREATE OR REPLACE VIEW :working_schema.v_location_p AS
WITH 

cte_location AS (
SELECT
    location_id,
    address_1,
    address_2,
    city,
    state,
    zip,
    county,
    location_source_value,
    country_concept_id,
    country_source_value,
    latitude,
    longitude
FROM :working_schema.location_f
)

SELECT * FROM cte_location ORDER BY location_id;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_location_p;
--SELECT * FROM :working_schema.v_location_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :working_schema.location_p;
--INSERT INTO :working_schema.location_p SELECT * FROM :working_schema.v_location_p;
