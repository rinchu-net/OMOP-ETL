@echo off
chcp 65001 >nul

REM ====================================================================
REM  Drop source and master tables
REM ====================================================================

REM Common configuration path
SET SETPATH=..\..\0000_setting
    
REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "データソース・マスタテーブル削除" %ENVPATH%
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=drop_tables

REM PostgreSQL connection parameters
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM Set log file name
set LOGFILE=%TARGET%_%LOGTS%.log

REM Output DROP statements to temp file
setlocal enabledelayedexpansion
set DROPFILE=drop_tables.sql

echo -- DROP TABLES for create_rinchu.ddl > %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.InjectionData CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.PrescriptionData CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.ObservationResult CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.PatientDisease CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.PatientVisit CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.PatientAddress CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.PatientIdentification CASCADE; >> %DROPFILE%

echo -- DROP TABLES for create_master.ddl >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.mst_zipcode CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.mst_medis_byomei CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.mst_medis_hot13 CASCADE; >> %DROPFILE%
echo DROP TABLE IF EXISTS %SOURCE_SCHEMA%.mst_mendeley CASCADE; >> %DROPFILE%

REM psqlで実行
psql %PARAM% -f %DROPFILE% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

REM 一時ファイル削除
del %DROPFILE%
endlocal

REM 結果表示
CALL %SETPATH%\ShowResult.bat %RESULT% "テーブル削除" "%LOGFILE%"

PAUSE
