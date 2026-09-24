\set ON_ERROR_STOP on
-----------------------------------------------
-- View: v_provider_p
-- Purpose: Create production data from provider_f
-----------------------------------------------
CREATE OR REPLACE VIEW :working_schema.v_provider_p AS 
SELECT 
	provider_id,
	provider_name,
    npi,
    dea,
    specialty_concept_id,
    care_site_id,
	year_of_birth,
	gender_concept_id,
    provider_source_value,
    specialty_source_value,
    specialty_source_concept_id,
    gender_source_value,
    gender_source_concept_id
FROM :working_schema.provider_f
;

--- テストクエリ
--SELECT COUNT(1) FROM :working_schema.v_provider_p;
--SELECT * FROM :working_schema.v_provider_p LIMIT 100;

--- データ生成
--TRUNCATE TABLE :production_schema.provider;
--INSERT INTO :production_schema.provider SELECT * FROM :working_schema.v_provider_p
