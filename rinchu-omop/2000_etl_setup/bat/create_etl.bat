@echo off
chcp 65001 >nul

REM ====================================================================
REM  OMOP ETL VIEW bulk creation
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "OMOP変換ETL VIEW一括作成" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=create_etl

echo ===================================================
echo =  ETL VIEW Bulk Creation Batch
echo =  This batch creates all ETL views in dependency order.
echo =============================================================
echo =  Targets: person, visit, death, stem_source, condition_occurrence, etc.
echo =  Executes each SQL for PostgreSQL in sequence.
echo =============================================================
echo.

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA% -v care_site_source_value=%CARE_SITE_SOURCE_VALUE%

if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%WORKING_SCHEMA%

REM === Execute ETL VIEW creation SQL ===
echo --- person ---
echo --- person --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_person_s.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_person_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_person_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_person_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_person_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- visit_occurrence/detail ---
echo --- visit_occurrence/detail --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_visit_occurrence_s.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_visit_occurrence_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_visit_occurrence_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_visit_occurrence_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_visit_occurrence_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_visit_detail_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_visit_detail_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- death ---
echo --- death --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_death_s.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_death_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_death_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_death_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_death_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- stem(Staging) ---
echo --- stem(Staging) --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_stem_source_disease.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem_source_disease_icd.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem_source_disease_icd_suspdiv.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem_source_injection.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem_source_observation.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem_source_prescription.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem_source_specimen.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_stem.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- condition_occurrence ---
echo --- condition_occurrence --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_condition_occurrence_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_condition_occurrence_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_condition_occurrence_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_condition_occurrence_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- drug_exposure ---
echo --- drug_exposure --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_drug_exposure_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_drug_exposure_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_drug_exposure_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_drug_exposure_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- device_exposure ---
echo --- device_exposure --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_device_exposure_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_device_exposure_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_device_exposure_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_device_exposure_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- measurement ---
echo --- measurement --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_measurement_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_measurement_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_measurement_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_measurement_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- observation ---
echo --- observation --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_observation_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_observation_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_observation_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_observation_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- specimen ---
echo --- specimen --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_specimen_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_specimen_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_specimen_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_specimen_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- procedure_occurrence ---
echo --- procedure_occurrence --- >> %LOGFILE%
psql %PARAM% -f ../sql/etl_procedure_occurrence_m.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_procedure_occurrence_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_procedure_occurrence_e.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_procedure_occurrence_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- others ---
echo --- others --- >> %LOGFILE%
REM psql %PARAM% -f ../sql/etl_location_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_location_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_care_site_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_provider_p.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_observation_period_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_condition_era_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
REM etl_drug_era_f.sqlとetl_dose_era_f.sqlは500_etl_execute.batで実行するためコメントアウト
REM psql %PARAM% -f ../sql/etl_drug_era_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
REM psql %PARAM% -f ../sql/etl_dose_era_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_source_code_list.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- source_to_concept_map ---
echo --- source_to_concept_map --- >> %LOGFILE%
psql %PARAM% -f ../sql/source_to_concept_map_diagnosis_from_athena_icd10.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/source_to_concept_map_diagnosis_from_athena_icd10_medisextention.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/source_to_concept_map_diagnosis_from_medis_exchgno.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/source_to_concept_map_diagnosis_from_medis_kanrino.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/source_to_concept_map_mendeley_yj.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/etl_source_to_concept_map_base.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
echo --- utilities ---
echo --- utilities --- >> %LOGFILE%
psql %PARAM% -f ../sql/report_etl_errors.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f ../sql/source_to_concept_map_viewer.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error

type %LOGFILE%

echo ===================================================
echo All ETL VIEW creation SQL executions are complete.
echo ===================================================

if not "%AUTO_EXEC%"=="1" pause
exit /b 0

:error
echo.
echo [ERROR] ETL VIEW creation failed. See log: %LOGFILE%
if not "%AUTO_EXEC%"=="1" pause
exit /b 1
