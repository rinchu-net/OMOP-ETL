\set ON_ERROR_STOP on
---------------------------------------------------------------------
-- ALTER TABLE SET UNLOGGED for all ETL tables
-- Purpose: Reduce disk usage by disabling WAL for all staging/source tables
-- Note: UNLOGGED tables are truncated on server crash and must be re-executed
---------------------------------------------------------------------

----------------------------------
-- source schema tables (create_rinchu.sql)
----------------------------------
ALTER TABLE :source_schema.PatientIdentification SET UNLOGGED;
ALTER TABLE :source_schema.PatientAddress SET UNLOGGED;
ALTER TABLE :source_schema.PatientVisit SET UNLOGGED;
ALTER TABLE :source_schema.PatientDisease SET UNLOGGED;
ALTER TABLE :source_schema.ObservationResult SET UNLOGGED;
ALTER TABLE :source_schema.PrescriptionData SET UNLOGGED;
ALTER TABLE :source_schema.InjectionData SET UNLOGGED;

----------------------------------
-- master schema tables (create_master.sql)
----------------------------------
ALTER TABLE :source_schema.mst_medis_byomei SET UNLOGGED;
ALTER TABLE :source_schema.mst_medis_hot13 SET UNLOGGED;
ALTER TABLE :source_schema.mst_zipcode SET UNLOGGED;
ALTER TABLE :source_schema.mst_mendeley SET UNLOGGED;
