\set ON_ERROR_STOP on
\echo ==== conversion result checklist  ====
\copy (SELECT * FROM @schema.v_report_etl_errors) TO '../result/report_etl_errors.csv' CSV HEADER
\copy (SELECT * FROM @schema.person_e) TO '../result/person_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.visit_occurrence_e) TO '../result/visit_occurrence_e.csv' CSV HEADER
--\copy (SELECT * FROM @schema.visit_detail_e) TO '../result/visit_detail_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.death_e) TO '../result/death_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.condition_occurrence_e) TO '../result/condition_occurrence_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.drug_exposure_e) TO '../result/drug_exposure_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.procedure_occurrence_e) TO '../result/procedure_occurrence_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.measurement_e) TO '../result/measurement_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.observation_e) TO '../result/observation_e.csv' CSV HEADER
\copy (SELECT * FROM @schema.specimen_e) TO '../result/specimen_e.csv' CSV HEADER

