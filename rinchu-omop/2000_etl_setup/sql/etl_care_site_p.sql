\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_care_site_p
-- Purpose: Create production data from care_site_f
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_care_site_p AS 
SELECT 
	care_site_id,
	care_site_name,
    place_of_service_concept_id,
    location_id,
    care_site_source_value,
	place_of_service_source_value
FROM :working_schema.care_site_f
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_care_site_p;
--SELECT * FROM :working_schema.v_care_site_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.provider;
--INSERT INTO :production_schema.provider SELECT * FROM :working_schema.v_care_site_p
