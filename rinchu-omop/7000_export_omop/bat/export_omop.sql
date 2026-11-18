-- ====================================================================
-- OMOP CDM 提供用データ抽出（仮名化済み）
-- ====================================================================
-- OHDSI "Preserving Privacy in an OMOP CDM Implementation"
-- (https://ohdsi.github.io/CommonDataModel/cdmPrivacy.html) に沿って、
-- 施設外へ提供するCSVから以下を除外・置換する。
--
--   - person_id            : 出力ごとにランダムな連番へ振り直す（院内IDと突合不可）
--   - person_source_value  : NULL（院内の患者ID）
--   - day_of_birth         : NULL（生年月日は年月まで）
--   - birth_datetime       : NULL
--   - care_site_id         : NULL（医療機関番号）
--   - drug_exposure.sig                 : NULL（処方コメント等の自由記述）
--   - measurement.value_source_value    : NULL（検査結果の原文）
--   - observation.value_as_string       : NULL（検査結果の原文）
--   - observation.value_source_value    : NULL
--
-- 列は許可リスト方式で明示している。SELECT * に戻さないこと。
-- 施設内での別環境への移行には本スクリプトではなく pg_dump を使用すること。
-- ====================================================================

\set ON_ERROR_STOP on

-- 抽出対象の患者と、提供用のランダムな person_id の対応表（セッション終了時に破棄）
-- 抽出条件は用途にあわせて修正すること
CREATE TEMP TABLE export_person_map AS
SELECT
    person_id,
    ROW_NUMBER() OVER (ORDER BY random())::integer AS export_person_id
FROM @schema.person
WHERE person_id <= 1000;

\echo ==== person ====
\COPY (SELECT m.export_person_id AS person_id, t.gender_concept_id, t.year_of_birth, t.month_of_birth, NULL::integer AS day_of_birth, NULL::timestamp AS birth_datetime, t.race_concept_id, t.ethnicity_concept_id, t.location_id, t.provider_id, NULL::integer AS care_site_id, NULL::varchar AS person_source_value, t.gender_source_value, t.gender_source_concept_id, t.race_source_value, t.race_source_concept_id, t.ethnicity_source_value, t.ethnicity_source_concept_id FROM @schema.person t JOIN export_person_map m ON m.person_id = t.person_id ORDER BY m.export_person_id) TO '../dat/person.csv' WITH CSV HEADER;
\echo ==== death ====
\COPY (SELECT m.export_person_id AS person_id, t.death_date, t.death_datetime, t.death_type_concept_id, t.cause_concept_id, t.cause_source_value, t.cause_source_concept_id FROM @schema.death t JOIN export_person_map m ON m.person_id = t.person_id ORDER BY m.export_person_id) TO '../dat/death.csv' WITH CSV HEADER;
\echo ==== visit_occurrence ====
\COPY (SELECT t.visit_occurrence_id, m.export_person_id AS person_id, t.visit_concept_id, t.visit_start_date, t.visit_start_datetime, t.visit_end_date, t.visit_end_datetime, t.visit_type_concept_id, t.provider_id, NULL::integer AS care_site_id, t.visit_source_value, t.visit_source_concept_id, t.admitted_from_concept_id, t.admitted_from_source_value, t.discharged_to_concept_id, t.discharged_to_source_value, t.preceding_visit_occurrence_id FROM @schema.visit_occurrence t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/visit_occurrence.csv' WITH CSV HEADER;
\echo ==== visit_detail ====
\COPY (SELECT t.visit_detail_id, m.export_person_id AS person_id, t.visit_detail_concept_id, t.visit_detail_start_date, t.visit_detail_start_datetime, t.visit_detail_end_date, t.visit_detail_end_datetime, t.visit_detail_type_concept_id, t.provider_id, NULL::integer AS care_site_id, t.visit_detail_source_value, t.visit_detail_source_concept_id, t.admitted_from_concept_id, t.admitted_from_source_value, t.discharged_to_source_value, t.discharged_to_concept_id, t.preceding_visit_detail_id, t.parent_visit_detail_id, t.visit_occurrence_id FROM @schema.visit_detail t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/visit_detail.csv' WITH CSV HEADER;
\echo ==== condition_occurrence ====
\COPY (SELECT t.condition_occurrence_id, m.export_person_id AS person_id, t.condition_concept_id, t.condition_start_date, t.condition_start_datetime, t.condition_end_date, t.condition_end_datetime, t.condition_type_concept_id, t.condition_status_concept_id, t.stop_reason, t.provider_id, t.visit_occurrence_id, t.visit_detail_id, t.condition_source_value, t.condition_source_concept_id, t.condition_status_source_value FROM @schema.condition_occurrence t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/condition_occurrence.csv' WITH CSV HEADER;
\echo ==== drug_exposure ====
\COPY (SELECT t.drug_exposure_id, m.export_person_id AS person_id, t.drug_concept_id, t.drug_exposure_start_date, t.drug_exposure_start_datetime, t.drug_exposure_end_date, t.drug_exposure_end_datetime, t.verbatim_end_date, t.drug_type_concept_id, t.stop_reason, t.refills, t.quantity, t.days_supply, NULL::text AS sig, t.route_concept_id, t.lot_number, t.provider_id, t.visit_occurrence_id, t.visit_detail_id, t.drug_source_value, t.drug_source_concept_id, t.route_source_value, t.dose_unit_source_value FROM @schema.drug_exposure t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/drug_exposure.csv' WITH CSV HEADER;
\echo ==== device_exposure ====
\COPY (SELECT t.device_exposure_id, m.export_person_id AS person_id, t.device_concept_id, t.device_exposure_start_date, t.device_exposure_start_datetime, t.device_exposure_end_date, t.device_exposure_end_datetime, t.device_type_concept_id, t.unique_device_id, t.production_id, t.quantity, t.provider_id, t.visit_occurrence_id, t.visit_detail_id, t.device_source_value, t.device_source_concept_id, t.unit_concept_id, t.unit_source_value, t.unit_source_concept_id FROM @schema.device_exposure t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/device_exposure.csv' WITH CSV HEADER;
\echo ==== procedure_occurrence ====
\COPY (SELECT t.procedure_occurrence_id, m.export_person_id AS person_id, t.procedure_concept_id, t.procedure_date, t.procedure_datetime, t.procedure_end_date, t.procedure_end_datetime, t.procedure_type_concept_id, t.modifier_concept_id, t.quantity, t.provider_id, t.visit_occurrence_id, t.visit_detail_id, t.procedure_source_value, t.procedure_source_concept_id, t.modifier_source_value FROM @schema.procedure_occurrence t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/procedure_occurrence.csv' WITH CSV HEADER;
\echo ==== measurement ====
\COPY (SELECT t.measurement_id, m.export_person_id AS person_id, t.measurement_concept_id, t.measurement_date, t.measurement_datetime, t.measurement_time, t.measurement_type_concept_id, t.operator_concept_id, t.value_as_number, t.value_as_concept_id, t.unit_concept_id, t.range_low, t.range_high, t.provider_id, t.visit_occurrence_id, t.visit_detail_id, t.measurement_source_value, t.measurement_source_concept_id, t.unit_source_value, t.unit_source_concept_id, NULL::varchar AS value_source_value, t.measurement_event_id, t.meas_event_field_concept_id FROM @schema.measurement t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/measurement.csv' WITH CSV HEADER;
\echo ==== observation ====
\COPY (SELECT t.observation_id, m.export_person_id AS person_id, t.observation_concept_id, t.observation_date, t.observation_datetime, t.observation_type_concept_id, t.value_as_number, NULL::varchar AS value_as_string, t.value_as_concept_id, t.qualifier_concept_id, t.unit_concept_id, t.provider_id, t.visit_occurrence_id, t.visit_detail_id, t.observation_source_value, t.observation_source_concept_id, t.unit_source_value, t.qualifier_source_value, NULL::varchar AS value_source_value, t.observation_event_id, t.obs_event_field_concept_id FROM @schema.observation t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/observation.csv' WITH CSV HEADER;
\echo ==== specimen ====
\COPY (SELECT t.specimen_id, m.export_person_id AS person_id, t.specimen_concept_id, t.specimen_type_concept_id, t.specimen_date, t.specimen_datetime, t.quantity, t.unit_concept_id, t.anatomic_site_concept_id, t.disease_status_concept_id, t.specimen_source_id, t.specimen_source_value, t.unit_source_value, t.anatomic_site_source_value, t.disease_status_source_value FROM @schema.specimen t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/specimen.csv' WITH CSV HEADER;
\echo ==== observation_period ====
\COPY (SELECT t.observation_period_id, m.export_person_id AS person_id, t.observation_period_start_date, t.observation_period_end_date, t.period_type_concept_id FROM @schema.observation_period t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/observation_period.csv' WITH CSV HEADER;
\echo ==== condition_era ====
\COPY (SELECT t.condition_era_id, m.export_person_id AS person_id, t.condition_concept_id, t.condition_era_start_date, t.condition_era_end_date, t.condition_occurrence_count FROM @schema.condition_era t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/condition_era.csv' WITH CSV HEADER;
\echo ==== drug_era ====
\COPY (SELECT t.drug_era_id, m.export_person_id AS person_id, t.drug_concept_id, t.drug_era_start_date, t.drug_era_end_date, t.drug_exposure_count, t.gap_days FROM @schema.drug_era t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/drug_era.csv' WITH CSV HEADER;
\echo ==== dose_era ====
\COPY (SELECT t.dose_era_id, m.export_person_id AS person_id, t.drug_concept_id, t.unit_concept_id, t.dose_value, t.dose_era_start_date, t.dose_era_end_date FROM @schema.dose_era t JOIN export_person_map m ON m.person_id = t.person_id) TO '../dat/dose_era.csv' WITH CSV HEADER;
