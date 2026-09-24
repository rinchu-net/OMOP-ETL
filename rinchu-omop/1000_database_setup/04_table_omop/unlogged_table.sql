\set ON_ERROR_STOP on
---------------------------------------------------------------------
-- ALTER TABLE SET UNLOGGED for all ETL tables
-- Purpose: Reduce disk usage by disabling WAL for all staging/production tables
-- Note: UNLOGGED tables are truncated on server crash and must be re-executed
---------------------------------------------------------------------

----------------------------------
-- working schema tables (OMOPETL_Staging_ddl.sql)
----------------------------------

-- location / care_site / provider
ALTER TABLE :working_schema.location_f SET UNLOGGED;
ALTER TABLE :working_schema.care_site_f SET UNLOGGED;
ALTER TABLE :working_schema.provider_f SET UNLOGGED;

-- person
ALTER TABLE :working_schema.person_s SET UNLOGGED;
ALTER TABLE :working_schema.person_m SET UNLOGGED;
ALTER TABLE :working_schema.person_f SET UNLOGGED;
ALTER TABLE :working_schema.person_e SET UNLOGGED;

-- visit_occurrence / visit_detail
ALTER TABLE :working_schema.visit_occurrence_s SET UNLOGGED;
ALTER TABLE :working_schema.visit_occurrence_m SET UNLOGGED;
ALTER TABLE :working_schema.visit_occurrence_f SET UNLOGGED;
ALTER TABLE :working_schema.visit_occurrence_e SET UNLOGGED;
ALTER TABLE :working_schema.visit_detail_f SET UNLOGGED;

-- death
ALTER TABLE :working_schema.death_s SET UNLOGGED;
ALTER TABLE :working_schema.death_m SET UNLOGGED;
ALTER TABLE :working_schema.death_f SET UNLOGGED;
ALTER TABLE :working_schema.death_e SET UNLOGGED;

-- condition_occurrence
ALTER TABLE :working_schema.condition_occurrence_m SET UNLOGGED;
ALTER TABLE :working_schema.condition_occurrence_f SET UNLOGGED;
ALTER TABLE :working_schema.condition_occurrence_e SET UNLOGGED;

-- drug_exposure
ALTER TABLE :working_schema.drug_exposure_m SET UNLOGGED;
ALTER TABLE :working_schema.drug_exposure_f SET UNLOGGED;
ALTER TABLE :working_schema.drug_exposure_e SET UNLOGGED;

-- device_exposure
ALTER TABLE :working_schema.device_exposure_m SET UNLOGGED;
ALTER TABLE :working_schema.device_exposure_f SET UNLOGGED;
ALTER TABLE :working_schema.device_exposure_e SET UNLOGGED;

-- measurement
ALTER TABLE :working_schema.measurement_m SET UNLOGGED;
ALTER TABLE :working_schema.measurement_f SET UNLOGGED;
ALTER TABLE :working_schema.measurement_e SET UNLOGGED;

-- observation
ALTER TABLE :working_schema.observation_m SET UNLOGGED;
ALTER TABLE :working_schema.observation_f SET UNLOGGED;
ALTER TABLE :working_schema.observation_e SET UNLOGGED;

-- procedure_occurrence
ALTER TABLE :working_schema.procedure_occurrence_m SET UNLOGGED;
ALTER TABLE :working_schema.procedure_occurrence_f SET UNLOGGED;
ALTER TABLE :working_schema.procedure_occurrence_e SET UNLOGGED;

-- specimen
ALTER TABLE :working_schema.specimen_m SET UNLOGGED;
ALTER TABLE :working_schema.specimen_f SET UNLOGGED;
ALTER TABLE :working_schema.specimen_e SET UNLOGGED;

-- era / period
ALTER TABLE :working_schema.observation_period_f SET UNLOGGED;
ALTER TABLE :working_schema.condition_era_f SET UNLOGGED;
ALTER TABLE :working_schema.drug_era_f SET UNLOGGED;
ALTER TABLE :working_schema.dose_era_f SET UNLOGGED;

-- stem_source
ALTER TABLE :working_schema.stem_source SET UNLOGGED;
ALTER TABLE :working_schema.stem_m SET UNLOGGED;

-- source_to_concept_map
ALTER TABLE :working_schema.source_to_concept_map_f SET UNLOGGED;

-- vocabulary tables
ALTER TABLE :working_schema.concept_f SET UNLOGGED;
ALTER TABLE :working_schema.concept_ancestor_f SET UNLOGGED;
ALTER TABLE :working_schema.concept_class_f SET UNLOGGED;
ALTER TABLE :working_schema.concept_relationship_f SET UNLOGGED;
ALTER TABLE :working_schema.concept_synonym_f SET UNLOGGED;
ALTER TABLE :working_schema.domain_f SET UNLOGGED;
ALTER TABLE :working_schema.drug_strength_f SET UNLOGGED;
ALTER TABLE :working_schema.relationship_f SET UNLOGGED;
ALTER TABLE :working_schema.vocabulary_f SET UNLOGGED;
ALTER TABLE :working_schema.metadata_f SET UNLOGGED;
ALTER TABLE :working_schema.cdm_source_f SET UNLOGGED;

