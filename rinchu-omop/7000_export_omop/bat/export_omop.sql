\echo ==== person ====
\COPY (SELECT * FROM @schema.person WHERE person_id <= 1000) TO '../dat/person.csv' WITH CSV HEADER;
\echo ==== death ====
\COPY (SELECT * FROM @schema.death limit 100) TO '../dat/death.csv' WITH CSV HEADER;
\echo ==== visit_occurrence ====
\COPY (SELECT * FROM @schema.visit_occurrence WHERE person_id <= 1000) TO '../dat/visit_occurrence.csv' WITH CSV HEADER;
\echo ==== visit_detail ====
\COPY (SELECT * FROM @schema.visit_detail WHERE person_id <= 1000) TO '../dat/visit_detail.csv' WITH CSV HEADER;
\echo ==== condition_occurrence ====
\COPY (SELECT * FROM @schema.condition_occurrence WHERE person_id <= 1000) TO '../dat/condition_occurrence.csv' WITH CSV HEADER;
\echo ==== drug_exposure ====
\COPY (SELECT * FROM @schema.drug_exposure WHERE person_id <= 1000) TO '../dat/drug_exposure.csv' WITH CSV HEADER;
\echo ==== device_exposure ====
\COPY (SELECT * FROM @schema.device_exposure WHERE person_id <= 1000) TO '../dat/device_exposure.csv' WITH CSV HEADER;
\echo ==== procedure_occurrence ====
\COPY (SELECT * FROM @schema.procedure_occurrence WHERE person_id <= 1000) TO '../dat/procedure_occurrence.csv' WITH CSV HEADER;
\echo ==== measurement ====
\COPY (SELECT * FROM @schema.measurement WHERE person_id <= 1000) TO '../dat/measurement.csv' WITH CSV HEADER;
\echo ==== observation ====
\COPY (SELECT * FROM @schema.observation WHERE person_id <= 1000) TO '../dat/observation.csv' WITH CSV HEADER;
\echo ==== specimen ====
\COPY (SELECT * FROM @schema.specimen WHERE person_id <= 1000) TO '../dat/specimen.csv' WITH CSV HEADER;
\echo ==== observation_period ====
\COPY (SELECT * FROM @schema.observation_period WHERE person_id <= 1000) TO '../dat/observation_period.csv' WITH CSV HEADER;
\echo ==== condition_era ====
\COPY (SELECT * FROM @schema.condition_era WHERE person_id <= 1000) TO '../dat/condition_era.csv' WITH CSV HEADER;
\echo ==== drug_era ====
\COPY (SELECT * FROM @schema.drug_era WHERE person_id <= 1000) TO '../dat/drug_era.csv' WITH CSV HEADER;
\echo ==== dose_era ====
\COPY (SELECT * FROM @schema.dose_era WHERE person_id <= 1000) TO '../dat/dose_era.csv' WITH CSV HEADER;