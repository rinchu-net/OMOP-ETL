---------------------------------------------------------------------------------------------------------
-- OMOP ETL Staging Tables for RINCHU Project
---------------------------------------------------------------------------------------------------------
--  each etl target table has 3 or 4 staging tables as below:
--   _s: source tables: raw data from source system mapped to cdm fields
--   _m: mapped tables: mapped to standard concepts and cleaned
--   _f: finalized tables: ready to be loaded to production
--   _e: error tables: records with errors during ETL process(lacked required fields, invalid data, etc)
--  * Tables using common staging table do not have _s table
--    (Condition, Drug, Procedure, Measurement, Observation, Specimen)
--  Data Flow:
--    source --> _s --> _m --> _f/_e --> production(_f only)
---------------------------------------------------------------------------------------------------------

--------------------------------------------------
-- location
--------------------------------------------------
CREATE TABLE :working_schema.location_f (
			location_id integer NOT NULL,
			address_1 varchar(50) NULL,
			address_2 varchar(50) NULL,
			city varchar(50) NULL,
			state varchar(2) NULL,
			zip varchar(9) NULL,
			county varchar(20) NULL,
			location_source_value varchar(50) NULL,
			country_concept_id integer NULL,
			country_source_value varchar(80) NULL,
			latitude NUMERIC NULL,
			longitude NUMERIC NULL );

--------------------------------------------------
-- care_site
--------------------------------------------------
CREATE TABLE :working_schema.care_site_f (
			care_site_id integer NOT NULL,
			care_site_name varchar(255) NULL,
			place_of_service_concept_id integer NULL,
			location_id integer NULL,
			care_site_source_value varchar(50) NULL,
			place_of_service_source_value varchar(50) NULL );

--------------------------------------------------
-- provider
--------------------------------------------------
CREATE TABLE :working_schema.provider_f (
			provider_id integer NOT NULL,
			provider_name varchar(255) NULL,
			npi varchar(20) NULL,
			dea varchar(20) NULL,
			specialty_concept_id integer NULL,
			care_site_id integer NULL,
			year_of_birth integer NULL,
			gender_concept_id integer NULL,
			provider_source_value varchar(50) NULL,
			specialty_source_value varchar(50) NULL,
			specialty_source_concept_id integer NULL,
			gender_source_value varchar(50) NULL,
			gender_source_concept_id integer NULL );

--------------------------------------------------
-- person
--------------------------------------------------
CREATE TABLE :working_schema.person_s (
	person_id bigint,
	year_of_birth integer,
	month_of_birth integer,
	day_of_birth integer,
	birth_datetime TIMESTAMP,
	location_source_value varchar(50),
	provider_source_value varchar(50),
	care_site_source_value varchar(50),
	person_source_value varchar(50),
	gender_source_value varchar(50),
	gender_vocabulary_id varchar(50),
	gender_domain_id varchar(50),
	gender_source_regvalue varchar(50),
	race_source_value varchar(50),
	race_vocabulary_id varchar(50),
	race_domain_id varchar(50),
	race_source_regvalue varchar(50),
	ethnicity_source_value varchar(50),
	ethnicity_vocabulary_id varchar(50),
	ethnicity_domain_id varchar(50),
	ethnicity_source_regvalue varchar(50),
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.person_m (
	person_id bigint,
	gender_concept_id integer,
	year_of_birth integer,
	month_of_birth integer,
	day_of_birth integer,
	birth_datetime TIMESTAMP,
	race_concept_id integer,
	ethnicity_concept_id integer,
	location_id integer,
	provider_id integer,
	care_site_id integer,
	person_source_value varchar(50),
	gender_source_value varchar(50),
	gender_source_concept_id integer,
	race_source_value varchar(50),
	race_source_concept_id integer,
	ethnicity_source_value varchar(50),
	ethnicity_source_concept_id integer,
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.person_f (
	person_id bigint NOT NULL,
	gender_concept_id integer NOT NULL,
	year_of_birth integer NOT NULL,
	month_of_birth integer,
	day_of_birth integer,
	birth_datetime TIMESTAMP,
	race_concept_id integer NOT NULL,
	ethnicity_concept_id integer NOT NULL,
	location_id integer,
	provider_id integer,
	care_site_id integer,
	person_source_value varchar(50),
	gender_source_value varchar(50),
	gender_source_concept_id integer,
	race_source_value varchar(50),
	race_source_concept_id integer,
	ethnicity_source_value varchar(50),
	ethnicity_source_concept_id integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.person_e (
	person_id bigint,
	gender_concept_id integer,
	year_of_birth integer,
	month_of_birth integer,
	day_of_birth integer,
	birth_datetime TIMESTAMP,
	race_concept_id integer,
	ethnicity_concept_id integer,
	location_id integer,
	provider_id integer,
	care_site_id integer,
	person_source_value varchar(50),
	gender_source_value varchar(50),
	gender_source_concept_id integer,
	race_source_value varchar(50),
	race_source_concept_id integer,
	ethnicity_source_value varchar(50),
	ethnicity_source_concept_id integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- visit_occurrence/visit_detail
--------------------------------------------------
CREATE TABLE :working_schema.visit_occurrence_s (
	person_source_value varchar(50),
	visit_start_date date,
	visit_start_datetime TIMESTAMP NULL,
	visit_end_date date,
	visit_end_datetime TIMESTAMP NULL,
	visit_type_concept_id Integer,
	provider_source_value varchar(50),
	care_site_source_value varchar(50),
	visit_source_value varchar(50) NULL,
	visit_source_vocabulary_id varchar(50) NULL,
	visit_source_domain_id varchar(50) NULL,
	visit_source_regvalue varchar(50) NULL,
	admitted_from_source_value varchar(50) NULL,
	admitted_from_vocabulary_id varchar(50) NULL,
	admitted_from_domain_id varchar(50) NULL,
	discharged_to_source_value varchar(50) NULL,
	discharged_to_vocabulary_id varchar(50) NULL,
	discharged_to_domain_id varchar(50) NULL,
	preceding_visit_occurrence_id integer,
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	parent_load_row_id varchar(100)
);

CREATE TABLE :working_schema.visit_occurrence_m (
	person_id integer,
	visit_concept_id integer,
	visit_start_date date,
	visit_start_datetime TIMESTAMP,
	visit_end_date date,
	visit_end_datetime TIMESTAMP,
	visit_type_concept_id Integer,
	provider_id integer,
	care_site_id integer,
	visit_source_value varchar(50),
	visit_source_concept_id integer,
	visit_source_regvalue varchar(50) NULL,
	admitted_from_concept_id integer,
	admitted_from_source_value varchar(50),
	discharged_to_concept_id integer,
	discharged_to_source_value varchar(50),
	preceding_visit_occurrence_id integer,
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	parent_load_row_id varchar(100)
);

CREATE TABLE :working_schema.visit_occurrence_f (
	visit_occurrence_id bigint NOT NULL,
	person_id integer NOT NULL,
	visit_concept_id integer NOT NULL,
	visit_start_date date NOT NULL,
	visit_start_datetime TIMESTAMP,
	visit_end_date date NOT NULL,
	visit_end_datetime TIMESTAMP,
	visit_type_concept_id Integer NOT NULL,
	provider_id integer,
	care_site_id integer,
	visit_source_value varchar(50),
	visit_source_concept_id integer,
	visit_source_regvalue varchar(50) NULL,
	admitted_from_concept_id integer,
	admitted_from_source_value varchar(50),
	discharged_to_concept_id integer,
	discharged_to_source_value varchar(50),
	preceding_visit_occurrence_id integer,
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.visit_occurrence_e (
	visit_occurrence_id bigint,
	person_id integer,
	visit_concept_id integer,
	visit_start_date date,
	visit_start_datetime TIMESTAMP,
	visit_end_date date,
	visit_end_datetime TIMESTAMP,
	visit_type_concept_id Integer,
	provider_id integer,
	care_site_id integer,
	visit_source_value varchar(50),
	visit_source_concept_id integer,
	visit_source_regvalue varchar(50) NULL,
	admitted_from_concept_id integer,
	admitted_from_source_value varchar(50),
	discharged_to_concept_id integer,
	discharged_to_source_value varchar(50),
	preceding_visit_occurrence_id integer,
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);


CREATE TABLE :working_schema.visit_detail_f (
	visit_detail_id bigint NOT NULL,
	person_id integer NOT NULL,
	visit_detail_concept_id integer NOT NULL,
	visit_detail_start_date date NOT NULL,
	visit_detail_start_datetime TIMESTAMP,
	visit_detail_end_date date NOT NULL,
	visit_detail_end_datetime TIMESTAMP,
	visit_detail_type_concept_id Integer NOT NULL,
	provider_id integer,
	care_site_id integer,
	visit_detail_source_value varchar(50),
	visit_detail_source_concept_id integer,
	visit_detail_source_regvalue varchar(50) NULL,
	admitted_from_concept_id integer,
	admitted_from_source_value varchar(50),
	discharged_to_concept_id integer,
	discharged_to_source_value varchar(50),
	preceding_visit_detail_id integer,
	parent_visit_detail_id integer,
	visit_occurrence_id bigint NOT NULL,
	rownum integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

--------------------------------------------------
-- death
--------------------------------------------------
CREATE TABLE :working_schema.death_s (
	person_source_value varchar(50),
	death_date date,
	death_datetime TIMESTAMP,
	death_type_concept_id integer,
	cause_source_value varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.death_m (
	person_id integer,
	person_source_value varchar(50),
	death_date date,
	death_datetime TIMESTAMP,
	death_type_concept_id integer,
	cause_concept_id integer,
	cause_source_value varchar(50),
	cause_source_concept_id integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.death_f (
	person_id integer NOT NULL,
	person_source_value varchar(50),
	death_date date NOT NULL,
	death_datetime TIMESTAMP,
	death_type_concept_id integer,
	cause_concept_id integer,
	cause_source_value varchar(50),
	cause_source_concept_id integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.death_e (
	person_id integer,
	person_source_value varchar(50),
	death_date date,
	death_datetime TIMESTAMP,
	death_type_concept_id integer,
	cause_concept_id integer,
	cause_source_value varchar(50),
	cause_source_concept_id integer,
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- condition_occcurrence
--------------------------------------------------
CREATE TABLE :working_schema.condition_occurrence_m (
	condition_occurrence_id integer,
	person_id integer,
	person_source_value varchar(50),
	condition_concept_id integer,
	condition_concept_name varchar(255),
	condition_concept_vocabulary_id varchar(50),
	condition_concept_domain_id varchar(50),
	condition_start_date date,
	condition_start_datetime TIMESTAMP,
	condition_end_date date,
	condition_end_datetime TIMESTAMP,
	condition_type_concept_id integer,
	condition_status_concept_id integer,
	stop_reason varchar(20),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	condition_source_value varchar(255),  --> size extend for long length value
	condition_source_concept_id integer,
	condition_status_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.condition_occurrence_f (
	condition_occurrence_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	condition_concept_id integer NOT NULL,
	condition_concept_name varchar(255),
	condition_concept_vocabulary_id varchar(50),
	condition_concept_domain_id varchar(50),
	condition_start_date date NOT NULL,
	condition_start_datetime TIMESTAMP,
	condition_end_date date,
	condition_end_datetime TIMESTAMP,
	condition_type_concept_id integer NOT NULL,
	condition_status_concept_id integer,
	stop_reason varchar(20),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	condition_source_value varchar(255),  --> size extend for long length value
	condition_source_concept_id integer,
	condition_status_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.condition_occurrence_e (
	condition_occurrence_id integer,
	person_id integer,
	person_source_value varchar(50),
	condition_concept_id integer,
	condition_concept_name varchar(255),
	condition_concept_vocabulary_id varchar(50),
	condition_concept_domain_id varchar(50),
	condition_start_date date,
	condition_start_datetime TIMESTAMP,
	condition_end_date date,
	condition_end_datetime TIMESTAMP,
	condition_type_concept_id integer,
	condition_status_concept_id integer,
	stop_reason varchar(20),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	condition_source_value varchar(255),  --> size extend for long length value
	condition_source_concept_id integer,
	condition_status_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- drug_exposure
--------------------------------------------------
CREATE TABLE :working_schema.drug_exposure_m (
	drug_exposure_id integer,
	person_id integer,
	person_source_value varchar(50),
	drug_concept_id integer,
	drug_concept_name varchar(255),
	drug_concept_vocabulary_id varchar(50),
	drug_concept_domain_id varchar(50),
	drug_exposure_start_date date,
	drug_exposure_start_datetime TIMESTAMP,
	drug_exposure_end_date date,
	drug_exposure_end_datetime TIMESTAMP,
	verbatim_end_date date,
	drug_type_concept_id integer,
	stop_reason varchar(20),
	refills integer,
	quantity NUMERIC,
	days_supply integer,
	sig TEXT,
	route_concept_id integer,
	route_concept_name varchar(255),
	route_concept_vocabulary_id varchar(50),
	route_concept_domain_id varchar(50),
	lot_number varchar(50),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	drug_source_value varchar(255),  --> size extend for long length value
	drug_source_concept_id integer,
	route_source_value varchar(255),  --> size extend for long length value
	dose_unit_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.drug_exposure_f (
	drug_exposure_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	drug_concept_id integer NOT NULL,
	drug_concept_name varchar(255),
	drug_concept_vocabulary_id varchar(50),
	drug_concept_domain_id varchar(50),
	drug_exposure_start_date date NOT NULL,
	drug_exposure_start_datetime TIMESTAMP,
	drug_exposure_end_date date NOT NULL,
	drug_exposure_end_datetime TIMESTAMP,
	verbatim_end_date date,
	drug_type_concept_id integer NOT NULL,
	stop_reason varchar(20),
	refills integer,
	quantity NUMERIC,
	days_supply integer,
	sig TEXT,
	route_concept_id integer,
	route_concept_name varchar(255),
	route_concept_vocabulary_id varchar(50),
	route_concept_domain_id varchar(50),
	lot_number varchar(50),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	drug_source_value varchar(255),  --> size extend for long length value
	drug_source_concept_id integer,
	route_source_value varchar(255),  --> size extend for long length value
	dose_unit_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.drug_exposure_e (
	drug_exposure_id integer,
	person_id integer,
	person_source_value varchar(50),
	drug_concept_id integer,
	drug_concept_name varchar(255),
	drug_concept_vocabulary_id varchar(50),
	drug_concept_domain_id varchar(50),
	drug_exposure_start_date date,
	drug_exposure_start_datetime TIMESTAMP,
	drug_exposure_end_date date,
	drug_exposure_end_datetime TIMESTAMP,
	verbatim_end_date date,
	drug_type_concept_id integer,
	stop_reason varchar(20),
	refills integer,
	quantity NUMERIC,
	days_supply integer,
	sig TEXT,
	route_concept_id integer,
	route_concept_name varchar(255),
	route_concept_vocabulary_id varchar(50),
	route_concept_domain_id varchar(50),
	lot_number varchar(50),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	drug_source_value varchar(255),  --> size extend for long length value
	drug_source_concept_id integer,
	route_source_value varchar(255),  --> size extend for long length value
	dose_unit_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- device_exposure
--------------------------------------------------
CREATE TABLE :working_schema.device_exposure_m (
	device_exposure_id integer,
	person_id integer,
	person_source_value varchar(50),
	device_concept_id integer,
	device_concept_name varchar(255),
	device_concept_vocabulary_id varchar(255),
	device_concept_domain_id varchar(50),
	device_exposure_start_date date,
	device_exposure_start_datetime TIMESTAMP,
	device_exposure_end_date date,
	device_exposure_end_datetime TIMESTAMP,
	device_type_concept_id integer,
	unique_device_id varchar(255),
	production_id varchar(255),
	quantity integer,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	device_source_value varchar(255),  --> size extend for long length value
	device_source_concept_id integer,
	unit_concept_id integer,
	unit_source_value varchar(50),
	unit_source_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.device_exposure_f (
	device_exposure_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	device_concept_id integer NOT NULL,
	device_concept_name varchar(255),
	device_concept_vocabulary_id varchar(255),
	device_concept_domain_id varchar(50),
	device_exposure_start_date date NOT NULL,
	device_exposure_start_datetime TIMESTAMP,
	device_exposure_end_date date,
	device_exposure_end_datetime TIMESTAMP,
	device_type_concept_id integer NOT NULL,
	unique_device_id varchar(255),
	production_id varchar(255),
	quantity integer,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	device_source_value varchar(255),  --> size extend for long length value
	device_source_concept_id integer,
	unit_concept_id integer,
	unit_source_value varchar(50),
	unit_source_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.device_exposure_e (
	device_exposure_id integer,
	person_id integer,
	person_source_value varchar(50),
	device_concept_id integer,
	device_concept_name varchar(255),
	device_concept_vocabulary_id varchar(255),
	device_concept_domain_id varchar(50),
	device_exposure_start_date date,
	device_exposure_start_datetime TIMESTAMP,
	device_exposure_end_date date,
	device_exposure_end_datetime TIMESTAMP,
	device_type_concept_id integer,
	unique_device_id varchar(255),
	production_id varchar(255),
	quantity integer,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	device_source_value varchar(255),  --> size extend for long length value
	device_source_concept_id integer,
	unit_concept_id integer,
	unit_source_value varchar(50),
	unit_source_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- measurement
--------------------------------------------------
CREATE TABLE :working_schema.measurement_m (
	measurement_id integer,
	person_id integer,
	person_source_value varchar(50),
	measurement_concept_id integer,
	measurement_concept_name varchar(255),
	measurement_concept_vocabulary_id varchar(50),
	measurement_concept_domain_id varchar(50),
	measurement_date date,
	measurement_datetime TIMESTAMP,
	measurement_time varchar(10),
	measurement_type_concept_id integer,
	operator_concept_id integer,
	operator_concept_name varchar(255),
	operator_concept_vocabulary_id varchar(50),
	operator_concept_domain_id varchar(50),
	value_as_number NUMERIC,
	value_as_concept_id integer,
	value_as_concept_name varchar(255),
	value_as_concept_vocabulary_id varchar(50),
	value_as_concept_domain_id varchar(50),
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	range_low NUMERIC,
	range_high NUMERIC,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	measurement_source_value varchar(255),  --> size extend for long length value
	measurement_source_concept_id integer,
	unit_source_value varchar(50),
	unit_source_concept_id integer,
	value_source_value varchar(255),  --> size extend for long length value
	operator_source_value varchar(50),
	measurement_event_id bigint,
	meas_event_field_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.measurement_f (
	measurement_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	measurement_concept_id integer NOT NULL,
	measurement_concept_name varchar(255),
	measurement_concept_vocabulary_id varchar(50),
	measurement_concept_domain_id varchar(50),
	measurement_date date NOT NULL,
	measurement_datetime TIMESTAMP,
	measurement_time varchar(10),
	measurement_type_concept_id integer NOT NULL,
	operator_concept_id integer,
	operator_concept_name varchar(255),
	operator_concept_vocabulary_id varchar(50),
	operator_concept_domain_id varchar(50),
	value_as_number NUMERIC,
	value_as_concept_id integer,
	value_as_concept_name varchar(255),
	value_as_concept_vocabulary_id varchar(50),
	value_as_concept_domain_id varchar(50),
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	range_low NUMERIC,
	range_high NUMERIC,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	measurement_source_value varchar(255),  --> size extend for long length value
	measurement_source_concept_id integer,
	unit_source_value varchar(50),
	unit_source_concept_id integer,
	value_source_value varchar(255),  --> size extend for long length value
	operator_source_value varchar(50),
	measurement_event_id bigint,
	meas_event_field_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.measurement_e (
	measurement_id integer,
	person_id integer,
	person_source_value varchar(50),
	measurement_concept_id integer,
	measurement_concept_name varchar(255),
	measurement_concept_vocabulary_id varchar(50),
	measurement_concept_domain_id varchar(50),
	measurement_date date,
	measurement_datetime TIMESTAMP,
	measurement_time varchar(10),
	measurement_type_concept_id integer,
	operator_concept_id integer,
	operator_concept_name varchar(255),
	operator_concept_vocabulary_id varchar(50),
	operator_concept_domain_id varchar(50),
	value_as_number NUMERIC,
	value_as_concept_id integer,
	value_as_concept_name varchar(255),
	value_as_concept_vocabulary_id varchar(50),
	value_as_concept_domain_id varchar(50),
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	range_low NUMERIC,
	range_high NUMERIC,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	measurement_source_value varchar(255),  --> size extend for long length value
	measurement_source_concept_id integer,
	unit_source_value varchar(50),
	unit_source_concept_id integer,
	value_source_value varchar(255),  --> size extend for long length value
	operator_source_value varchar(50),
	measurement_event_id bigint,
	meas_event_field_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);


--------------------------------------------------
-- observation
--------------------------------------------------
CREATE TABLE :working_schema.observation_m (
	observation_id integer,
	person_id integer,
	person_source_value varchar(50),
	observation_concept_id integer,
	observation_concept_name varchar(255),
	observation_concept_vocabulary_id varchar(50),
	observation_concept_domain_id varchar(50),
	observation_date date,
	observation_datetime TIMESTAMP,
	observation_type_concept_id integer,
	value_as_number NUMERIC,
	value_as_string varchar(60),
	value_as_concept_id integer,
	value_as_concept_name varchar(255),
	value_as_concept_vocabulary_id varchar(50),
	value_as_concept_domain_id varchar(50),
	qualifier_concept_id integer,
	qualifier_concept_name varchar(255),
	qualifier_concept_vocabulary_id varchar(50),
	qualifier_concept_domain_id varchar(50),
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	observation_source_value varchar(255),  --> size extend for long length value
	observation_source_concept_id integer,
	unit_source_value varchar(50),
	qualifier_source_value varchar(50),
	value_source_value varchar(255),  --> size extend for long length value
	observation_event_id bigint,
	obs_event_field_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.observation_f (
	observation_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	observation_concept_id integer NOT NULL,
	observation_concept_name varchar(255),
	observation_concept_vocabulary_id varchar(50),
	observation_concept_domain_id varchar(50),
	observation_date date NOT NULL,
	observation_datetime TIMESTAMP,
	observation_type_concept_id integer NOT NULL,
	value_as_number NUMERIC,
	value_as_string varchar(60),
	value_as_concept_id integer,
	value_as_concept_name varchar(255),
	value_as_concept_vocabulary_id varchar(50),
	value_as_concept_domain_id varchar(50),
	qualifier_concept_id integer,
	qualifier_concept_name varchar(255),
	qualifier_concept_vocabulary_id varchar(50),
	qualifier_concept_domain_id varchar(50),
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	observation_source_value varchar(255),  --> size extend for long length value
	observation_source_concept_id integer,
	unit_source_value varchar(50),
	qualifier_source_value varchar(50),
	value_source_value varchar(255),  --> size extend for long length value
	observation_event_id bigint,
	obs_event_field_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.observation_e (
	observation_id integer,
	person_id integer,
	person_source_value varchar(50),
	observation_concept_id integer,
	observation_concept_name varchar(255),
	observation_concept_vocabulary_id varchar(50),
	observation_concept_domain_id varchar(50),
	observation_date date,
	observation_datetime TIMESTAMP,
	observation_type_concept_id integer,
	value_as_number NUMERIC,
	value_as_string varchar(60),
	value_as_concept_id integer,
	value_as_concept_name varchar(255),
	value_as_concept_vocabulary_id varchar(50),
	value_as_concept_domain_id varchar(50),
	qualifier_concept_id integer,
	qualifier_concept_name varchar(255),
	qualifier_concept_vocabulary_id varchar(50),
	qualifier_concept_domain_id varchar(50),
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	observation_source_value varchar(255),  --> size extend for long length value
	observation_source_concept_id integer,
	unit_source_value varchar(50),
	qualifier_source_value varchar(50),
	value_source_value varchar(255),  --> size extend for long length value
	observation_event_id bigint,
	obs_event_field_concept_id integer,
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);


--------------------------------------------------
-- procedure_occurrence
--------------------------------------------------
CREATE TABLE :working_schema.procedure_occurrence_m (
	procedure_occurrence_id integer,
	person_id integer,
	person_source_value varchar(50),
	procedure_concept_id integer,
	procedure_concept_name varchar(255),
	procedure_concept_vocabulary_id varchar(50),
	procedure_concept_domain_id varchar(50),
	procedure_date date,
	procedure_datetime TIMESTAMP,
	procedure_end_date date,
	procedure_end_datetime TIMESTAMP,
	procedure_type_concept_id integer,
	modifier_concept_id integer,
	modifier_concept_name varchar(255),
	modifier_concept_vocabulary_id varchar(50),
	modifier_concept_domain_id varchar(50),
	quantity integer,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	procedure_source_value varchar(255),  --> size extend for long length value
	procedure_source_concept_id integer,
	modifier_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.procedure_occurrence_f (
	procedure_occurrence_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	procedure_concept_id integer NOT NULL,
	procedure_concept_name varchar(255),
	procedure_concept_vocabulary_id varchar(50),
	procedure_concept_domain_id varchar(50),
	procedure_date date NOT NULL,
	procedure_datetime TIMESTAMP,
	procedure_end_date date,
	procedure_end_datetime TIMESTAMP,
	procedure_type_concept_id integer NOT NULL,
	modifier_concept_id integer,
	modifier_concept_name varchar(255),
	modifier_concept_vocabulary_id varchar(50),
	modifier_concept_domain_id varchar(50),
	quantity integer,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	procedure_source_value varchar(255),  --> size extend for long length value
	procedure_source_concept_id integer,
	modifier_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.procedure_occurrence_e (
	procedure_occurrence_id integer,
	person_id integer,
	person_source_value varchar(50),
	procedure_concept_id integer,
	procedure_concept_name varchar(255),
	procedure_concept_vocabulary_id varchar(50),
	procedure_concept_domain_id varchar(50),
	procedure_date date,
	procedure_datetime TIMESTAMP,
	procedure_end_date date,
	procedure_end_datetime TIMESTAMP,
	procedure_type_concept_id integer,
	modifier_concept_id integer,
	modifier_concept_name varchar(255),
	modifier_concept_vocabulary_id varchar(50),
	modifier_concept_domain_id varchar(50),
	quantity integer,
	provider_id integer,
	visit_occurrence_id integer,
	visit_detail_id integer,
	procedure_source_value varchar(255),  --> size extend for long length value
	procedure_source_concept_id integer,
	modifier_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- specimen
--------------------------------------------------
CREATE TABLE :working_schema.specimen_m (
	specimen_id integer,
	person_id integer,
	person_source_value varchar(50),
	specimen_concept_id integer,
	specimen_concept_name varchar(255),
	specimen_concept_vocabulary_id varchar(50),
	specimen_concept_domain_id varchar(50),
	specimen_type_concept_id integer,
	specimen_date date,
	specimen_datetime TIMESTAMP,
	quantity NUMERIC,
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	anatomic_site_concept_id integer,
	anatomic_site_concept_name varchar(255),
	anatomic_site_concept_vocabulary_id varchar(50),
	anatomic_site_concept_domain_id varchar(50),
	disease_status_concept_id integer,
	disease_status_concept_name varchar(255),
	disease_status_concept_vocabulary_id varchar(50),
	disease_status_concept_domain_id varchar(50),
	specimen_source_id varchar(50),
	specimen_source_value varchar(255),  --> size extend for long length value
	unit_source_value varchar(50),
	anatomic_site_source_value varchar(50),
	disease_status_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.specimen_f (
	specimen_id integer NOT NULL,
	person_id integer NOT NULL,
	person_source_value varchar(50),
	specimen_concept_id integer NOT NULL,
	specimen_concept_name varchar(255),
	specimen_concept_vocabulary_id varchar(50),
	specimen_concept_domain_id varchar(50),
	specimen_type_concept_id integer NOT NULL,
	specimen_date date NOT NULL,
	specimen_datetime TIMESTAMP,
	quantity NUMERIC,
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	anatomic_site_concept_id integer,
	anatomic_site_concept_name varchar(255),
	anatomic_site_concept_vocabulary_id varchar(50),
	anatomic_site_concept_domain_id varchar(50),
	disease_status_concept_id integer,
	disease_status_concept_name varchar(255),
	disease_status_concept_vocabulary_id varchar(50),
	disease_status_concept_domain_id varchar(50),
	specimen_source_id varchar(50),
	specimen_source_value varchar(255),  --> size extend for long length value
	unit_source_value varchar(50),
	anatomic_site_source_value varchar(50),
	disease_status_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100)
);

CREATE TABLE :working_schema.specimen_e (
	specimen_id integer,
	person_id integer,
	person_source_value varchar(50),
	specimen_concept_id integer,
	specimen_concept_name varchar(255),
	specimen_concept_vocabulary_id varchar(50),
	specimen_concept_domain_id varchar(50),
	specimen_type_concept_id integer,
	specimen_date date,
	specimen_datetime TIMESTAMP,
	quantity NUMERIC,
	unit_concept_id integer,
	unit_concept_name varchar(255),
	unit_concept_vocabulary_id varchar(50),
	unit_concept_domain_id varchar(50),
	anatomic_site_concept_id integer,
	anatomic_site_concept_name varchar(255),
	anatomic_site_concept_vocabulary_id varchar(50),
	anatomic_site_concept_domain_id varchar(50),
	disease_status_concept_id integer,
	disease_status_concept_name varchar(255),
	disease_status_concept_vocabulary_id varchar(50),
	disease_status_concept_domain_id varchar(50),
	specimen_source_id varchar(50),
	specimen_source_value varchar(255),  --> size extend for long length value
	unit_source_value varchar(50),
	anatomic_site_source_value varchar(50),
	disease_status_source_value varchar(50),
	mapped_source_vocabulary_id varchar(50),
	table_name varchar(50),
	field_name varchar(50),
	load_row_id varchar(100),
	error_field varchar(50)
);

--------------------------------------------------
-- observation_period_f
--------------------------------------------------
CREATE TABLE :working_schema.observation_period_f (
			observation_period_id integer NOT NULL,
			person_id integer NOT NULL,
			observation_period_start_date date NOT NULL,
			observation_period_end_date date NOT NULL,
			period_type_concept_id integer NOT NULL );

--------------------------------------------------
-- condition_era_f
--------------------------------------------------
CREATE TABLE :working_schema.condition_era_f (
			condition_era_id integer NOT NULL,
			person_id integer NOT NULL,
			condition_concept_id integer NOT NULL,
			condition_era_start_date TIMESTAMP NOT NULL,
			condition_era_end_date TIMESTAMP NOT NULL,
			condition_occurrence_count integer NULL );

--------------------------------------------------
-- drug_era_f
--------------------------------------------------
CREATE TABLE :working_schema.drug_era_f (
			drug_era_id integer NOT NULL,
			person_id integer NOT NULL,
			drug_concept_id integer NOT NULL,
			drug_era_start_date TIMESTAMP NOT NULL,
			drug_era_end_date TIMESTAMP NOT NULL,
			drug_exposure_count integer NULL,
			gap_days integer NULL );

--------------------------------------------------
-- dose_era_f
--------------------------------------------------
CREATE TABLE :working_schema.dose_era_f (
			dose_era_id integer NOT NULL,
			person_id integer NOT NULL,
			drug_concept_id integer NOT NULL,
			unit_concept_id integer NOT NULL,
			dose_value NUMERIC NOT NULL,
			dose_era_start_date TIMESTAMP NOT NULL,
			dose_era_end_date TIMESTAMP NOT NULL );

--------------------------------------------------
-- OMStandardized Table for Extracted Mapping Table
--  This table is used to stage common fields across multiple cdm tables below.
--    Condition_occurrence
--    Drug_exposure
--    Measurement
--    Observation
--    Procedure_occurrence
--    Specimen
--------------------------------------------------
CREATE TABLE :working_schema.stem_source
(
	person_source_value varchar(50),
	start_date date,
	start_datetime timestamp,
	start_time time,
	end_date date,
	end_datetime timestamp,
	provider_source_value varchar(50),
	visit_source_value varchar(50),
	visit_detail_source_value varchar(50),
	source_value varchar(50),
	source_domain_id varchar(20),
	source_vocabulary_id varchar(64),
	source_secondary_vocabulary_id varchar(64),
	source_regvalue varchar(255),
	type_category varchar(50),
	value_source_value varchar(50),
	value_domain_id varchar(20),
	value_vocabulary_id varchar(64),
	value_secondary_vocabulary_id varchar(64),
	value_source_regvalue varchar(255),
	unit_source_value varchar(50),
	unit_domain_id varchar(20),
	unit_vocabulary_id varchar(64),
	unit_secondary_vocabulary_id varchar(64),
	unit_source_regvalue varchar(50),
	value_as_number numeric,
	qualifier_source_value varchar(50),
	qualifier_domain_id varchar(20),
	qualifier_vocabulary_id varchar(64),
	qualifier_secondary_vocabulary_id varchar(64),
	qualifier_source_regvalue varchar(50),
	value_as_string varchar(255),
	range_low numeric,
	range_high numeric,
	operator_source_value varchar(50),
	operator_domain_id varchar(20),
	operator_vocabulary_id varchar(64),
	operator_secondary_vocabulary_id varchar(64),
	operator_source_regvalue varchar(50),
	quantity double precision,
	anatomic_site_source_value varchar(50),
	anatomic_site_domain_id varchar(20),
	anatomic_site_vocabulary_id varchar(64),
	anatomic_site_secondary_vocabulary_id varchar(64),
	anatomic_site_source_regvalue varchar(50),
	specimen_source_id varchar(50),
	status_source_value varchar(50),
	status_domain_id varchar(20),
	status_vocabulary_id varchar(64),
	status_secondary_vocabulary_id varchar(64),
	status_source_regvalue varchar(50),
	unique_device_id varchar(50),
	modifier_source_value varchar(50),
	modifier_domain_id varchar(20),
	modifier_vocabulary_id varchar(64),
	modifier_secondary_vocabulary_id varchar(64),
	modifier_source_regvalue varchar(50),
	stop_reason varchar(50),
	refills bigint,
	days_supply bigint,
	sig text,
	lot_number varchar(50),
	verbatim_end_date date,
	route_source_value varchar(50),
	route_domain_id varchar(20),
	route_vocabulary_id varchar(64),
	route_secondary_vocabulary_id varchar(64),
	route_source_regvalue varchar(255),
	stem_source_table varchar(50),
	stem_source_field varchar(50),
	stem_source_rowid varchar(100)
);
CREATE INDEX idx_stem_source_1  ON :working_schema.stem_source (source_domain_id ASC);
CREATE INDEX idx_stem_source_2  ON :working_schema.stem_source (source_value ASC);

--------------------------------------------------
-- Source to concept map
--------------------------------------------------
CREATE TABLE :working_schema.source_to_concept_map_f (
			source_code varchar(50) NOT NULL,
			source_concept_id integer NOT NULL,
			source_vocabulary_id varchar(20) NOT NULL,
			source_code_description varchar(255) NULL,
			target_concept_id integer NOT NULL,
			target_vocabulary_id varchar(20) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
CREATE INDEX idx_source_to_concept_map_f_1  ON :working_schema.source_to_concept_map_f (target_concept_id ASC);
CREATE INDEX idx_source_to_concept_map_f_2 ON :working_schema.source_to_concept_map_f (source_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_f_3 ON :working_schema.source_to_concept_map_f (target_vocabulary_id ASC);
CREATE INDEX idx_source_to_concept_map_f_4 ON :working_schema.source_to_concept_map_f (source_code ASC);
CREATE INDEX idx_source_to_concept_map_f_5 ON :working_schema.source_to_concept_map_f (source_code ASC, source_vocabulary_id ASC);

--------------------------------------------------
-- ATHENA Vocabulary TABLES
--------------------------------------------------
CREATE TABLE :working_schema.concept_f (
			concept_id integer NOT NULL,
			concept_name varchar(1000) NOT NULL,
			domain_id varchar(20) NOT NULL,
			vocabulary_id varchar(20) NOT NULL,
			concept_class_id varchar(20) NOT NULL,
			standard_concept varchar(1) NULL,
			concept_code varchar(50) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
CREATE INDEX idx_concept_f_concept_id  ON :working_schema.concept_f (concept_id ASC);
CLUSTER :working_schema.concept_f USING idx_concept_f_concept_id ;

CREATE TABLE :working_schema.concept_ancestor_f (
			ancestor_concept_id integer NOT NULL,
			descendant_concept_id integer NOT NULL,
			min_levels_of_separation integer NOT NULL,
			max_levels_of_separation integer NOT NULL );
CREATE INDEX idx_concept_ancestor_f_id_1  ON :working_schema.concept_ancestor_f (ancestor_concept_id ASC);
CLUSTER :working_schema.concept_ancestor_f USING idx_concept_ancestor_f_id_1 ;
CREATE INDEX idx_concept_ancestor_f_id_2 ON :working_schema.concept_ancestor_f (descendant_concept_id ASC);

CREATE TABLE :working_schema.concept_class_f (
			concept_class_id varchar(20) NOT NULL,
			concept_class_name varchar(255) NOT NULL,
			concept_class_concept_id integer NOT NULL );

CREATE TABLE :working_schema.concept_relationship_f (
			concept_id_1 integer NOT NULL,
			concept_id_2 integer NOT NULL,
			relationship_id varchar(20) NOT NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
CREATE INDEX idx_concept_relationship_f_id_1  ON :working_schema.concept_relationship_f (concept_id_1 ASC);
CLUSTER :working_schema.concept_relationship_f USING idx_concept_relationship_f_id_1 ;
CREATE INDEX idx_concept_relationship_f_id_2 ON :working_schema.concept_relationship_f (concept_id_2 ASC);
CREATE INDEX idx_concept_relationship_f_id_3 ON :working_schema.concept_relationship_f (relationship_id ASC);

CREATE TABLE :working_schema.concept_synonym_f (
			concept_id integer NOT NULL,
			concept_synonym_name varchar(1000) NOT NULL,
			language_concept_id integer NOT NULL );
CREATE INDEX idx_concept_synonym_f_id  ON :working_schema.concept_synonym_f (concept_id ASC);
CLUSTER :working_schema.concept_synonym_f USING idx_concept_synonym_f_id ;

CREATE TABLE :working_schema.domain_f (
			domain_id varchar(20) NOT NULL,
			domain_name varchar(255) NOT NULL,
			domain_concept_id integer NOT NULL );

CREATE TABLE :working_schema.drug_strength_f (
			drug_concept_id integer NOT NULL,
			ingredient_concept_id integer NOT NULL,
			amount_value NUMERIC NULL,
			amount_unit_concept_id integer NULL,
			numerator_value NUMERIC NULL,
			numerator_unit_concept_id integer NULL,
			denominator_value NUMERIC NULL,
			denominator_unit_concept_id integer NULL,
			box_size integer NULL,
			valid_start_date date NOT NULL,
			valid_end_date date NOT NULL,
			invalid_reason varchar(1) NULL );
CREATE INDEX idx_drug_strength_f_id_1  ON :working_schema.drug_strength_f (drug_concept_id ASC);
CLUSTER :working_schema.drug_strength_f USING idx_drug_strength_f_id_1 ;
CREATE INDEX idx_drug_strength_f_id_2 ON :working_schema.drug_strength_f (ingredient_concept_id ASC);

CREATE TABLE :working_schema.relationship_f (
			relationship_id varchar(20) NOT NULL,
			relationship_name varchar(255) NOT NULL,
			is_hierarchical varchar(1) NOT NULL,
			defines_ancestry varchar(1) NOT NULL,
			reverse_relationship_id varchar(20) NOT NULL,
			relationship_concept_id integer NOT NULL );

CREATE TABLE :working_schema.vocabulary_f (
			vocabulary_id varchar(20) NOT NULL,
			vocabulary_name varchar(255) NOT NULL,
			vocabulary_reference varchar(255) NULL,
			vocabulary_version varchar(255) NULL,
			vocabulary_concept_id integer NOT NULL );

--------------------------------------------------
-- Other TABLES
--------------------------------------------------
CREATE TABLE :working_schema.metadata_f (
			metadata_id integer NOT NULL,
			metadata_concept_id integer NOT NULL,
			metadata_type_concept_id integer NOT NULL,
			name varchar(250) NOT NULL,
			value_as_string varchar(250) NULL,
			value_as_concept_id integer NULL,
			value_as_number NUMERIC NULL,
			metadata_date date NULL,
			metadata_datetime TIMESTAMP NULL );

CREATE TABLE :working_schema.cdm_source_f (
			cdm_source_name varchar(255) NOT NULL,
			cdm_source_abbreviation varchar(25) NOT NULL,
			cdm_holder varchar(255) NOT NULL,
			source_description TEXT NULL,
			source_documentation_reference varchar(255) NULL,
			cdm_etl_reference varchar(255) NULL,
			source_release_date date NOT NULL,
			cdm_release_date date NOT NULL,
			cdm_version varchar(10) NULL,
			cdm_version_concept_id integer NOT NULL,
			vocabulary_version varchar(20) NOT NULL );

--------------------------------------------------
-- stem_m
--  Materialized intermediate table for v_stem.
--  Common across Condition / Drug / Device / Measurement /
--  Observation / Procedure / Specimen domains.
--  All columns are nullable (originate from LEFT JOINs).
--------------------------------------------------
CREATE TABLE :working_schema.stem_m (
	domain_id varchar(20),  -- (内部フィルタ用、CDM 直接マップなし)
	person_source_value varchar(50),  -- *.person_source_value
	person_id bigint,  -- *.person_id
	start_date date,  -- *.*_start_date / drug_exposure.drug_exposure_start_date / device_exposure.device_exposure_start_date / measurement.measurement_date / observation.observation_date / procedure_occurrence.procedure_date / specimen.specimen_date
	start_datetime timestamp,  -- condition_occurrence.condition_start_datetime / drug_exposure.drug_exposure_start_datetime / device_exposure.device_exposure_start_datetime / measurement.measurement_datetime / observation.observation_datetime / procedure_occurrence.procedure_datetime / specimen.specimen_datetime
	start_time time,  -- measurement.measurement_time
	end_date date,  -- condition_occurrence.condition_end_date / drug_exposure.drug_exposure_end_date / device_exposure.device_exposure_end_date / procedure_occurrence.procedure_end_date
	end_datetime timestamp,  -- condition_occurrence.condition_end_datetime / drug_exposure.drug_exposure_end_datetime / device_exposure.device_exposure_end_datetime / procedure_occurrence.procedure_end_datetime
	provider_source_value varchar(50),  -- (内部参照用、CDM マップなし)
	provider_id integer,  -- *.provider_id (specimen 除く)
	visit_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	visit_occurrence_id bigint,  -- *.visit_occurrence_id (specimen 除く)
	visit_detail_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	visit_detail_id bigint,  -- *.visit_detail_id (specimen 除く)
	source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	source_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	source_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	source_secondary_vocabulary_id varchar(64),  -- stcm.source_secondary_vocabulary_id (STCM 検索キー)
	mapped_source_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	source_concept_id integer,  -- *.*_source_concept_id
	concept_id integer,  -- *.*_concept_id
	concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	source_regvalue varchar(255),  -- *.*_source_value
	type_category varchar(50),  -- stcm.source_code (STCM 検索キー)
	type_concept_id integer,  -- *.*_type_concept_id
	value_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	value_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	value_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	value_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_value_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	value_as_concept_id integer,  -- measurement.value_as_concept_id / observation.value_as_concept_id
	value_as_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	value_as_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	value_as_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	value_source_regvalue varchar(255),  -- measurement.value_source_value / observation.value_source_value
	unit_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	unit_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	unit_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	unit_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_unit_vocabulary_id varchar(64),  -- (内部参照用、CDM マップなし)
	unit_source_concept_id integer,  -- device_exposure.unit_source_concept_id / measurement.unit_source_concept_id
	unit_concept_id integer,  -- device_exposure.unit_concept_id / measurement.unit_concept_id / observation.unit_concept_id / specimen.unit_concept_id
	unit_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	unit_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	unit_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	unit_source_regvalue varchar(50),  -- *.*unit_source_value
	value_as_number numeric,  -- measurement.value_as_number / observation.value_as_number
	qualifier_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	qualifier_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	qualifier_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	qualifier_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_qualifier_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id (STCM 検索キー)
	qualifier_concept_id integer,  -- observation.qualifier_concept_id
	qualifier_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	qualifier_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	qualifier_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	qualifier_source_regvalue varchar(50),  -- observation.qualifier_source_value
	value_as_string varchar(255),  -- observation.value_as_string
	range_low numeric,  -- measurement.range_low
	range_high numeric,  -- measurement.range_high
	operator_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	operator_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	operator_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	operator_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_operator_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	operator_concept_id integer,  -- measurement.operator_concept_id
	operator_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	operator_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	operator_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	operator_source_regvalue varchar(50),  -- (stcmチェックリスト出力用)
	quantity double precision,  -- drug_exposure.quantity / device_exposure.quantity / procedure_occurrence.quantity / specimen.quantity
	anatomic_site_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	anatomic_site_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	anatomic_site_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	anatomic_site_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_anatomic_site_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	anatomic_site_concept_id integer,  -- specimen.anatomic_site_concept_id
	anatomic_site_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	anatomic_site_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	anatomic_site_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	specimen_source_id varchar(50),  -- specimen.specimen_source_id
	anatomic_site_source_regvalue varchar(50),  -- specimen.anatomic_site_source_value
	status_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	status_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	status_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	status_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_status_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	status_concept_id integer,  -- condition_occurrence.condition_status_concept_id / specimen.disease_status_concept_id
	status_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	status_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	status_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	status_source_regvalue varchar(50),  -- condition_occurrence.condition_status_source_value / specimen.disease_status_source_value
	unique_device_id varchar(50),  -- (現状 device_exposure では NULL リテラル投入のため stem 値は未使用、CDM マップなし)
	modifier_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	modifier_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	modifier_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	modifier_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_modifier_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	modifier_concept_id integer,  -- procedure_occurrence.modifier_concept_id
	modifier_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	modifier_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	modifier_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	modifier_source_regvalue varchar(50),  -- procedure_occurrence.modifier_source_value
	stop_reason varchar(50),  -- condition_occurrence.stop_reason / drug_exposure.stop_reason
	refills bigint,  -- drug_exposure.refills
	days_supply bigint,  -- drug_exposure.days_supply
	sig text,  -- drug_exposure.sig
	lot_number varchar(50),  -- drug_exposure.lot_number
	verbatim_end_date date,  -- drug_exposure.verbatim_end_date
	route_source_value varchar(50),  -- stcm.source_code (STCM 検索キー)
	route_domain_id varchar(20),  -- (内部参照用、CDM マップなし)
	route_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	route_secondary_vocabulary_id varchar(64),  -- stcm.source_vocabulary_id (STCM 検索キー)
	mapped_route_vocabulary_id varchar(64),  -- concept_id にマップされたvocabulary_id
	route_concept_id integer,  -- drug_exposure.route_concept_id
	route_concept_name varchar(1000),  -- (stcmチェックリスト出力用)
	route_concept_domain_id varchar(20),  -- (stcmチェックリスト出力用)
	route_concept_vocabulary_id varchar(20),  -- (stcmチェックリスト出力用)
	route_source_regvalue varchar(255),  -- drug_exposure.route_source_value
	stem_source_table varchar(50),  -- レコード生成元テーブル
	stem_source_field varchar(50),  -- レコード生成元テーブルのフィールド
	stem_source_rowid varchar(100)  -- レコード生成元テーブルのレコード識別ID 
);
CREATE INDEX idx_stem_m_domain ON :working_schema.stem_m (domain_id);
