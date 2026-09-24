@echo off
chcp 65001 >nul

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM ===============================================================
REM  Convert intermediate tables to OMOP CDM format data
REM ===============================================================

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "中間テーブルからOMOP CDM形式データへの変換" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=04_etl_execution_to_final

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

REM Prepare log directory
if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%SOURCE_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL=%TARGET%.sql


REM general_etl_execution
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
REM drug_era_etl_execution
psql %PARAM% -f ..\..\2000_etl_setup\sql\etl_drug_era_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
REM dose_era_etl_execution
psql %PARAM% -f ..\..\2000_etl_setup\sql\etl_dose_era_f.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error

set RESULT=0
CALL %SETPATH%\ShowResult.bat %RESULT% "中間テーブルからOMOP CDM形式データへの変換" "%LOGFILE%"
if not "%AUTO_EXEC%"=="1" PAUSE
exit /b 0

:error
set RESULT=%ERRORLEVEL%
CALL %SETPATH%\ShowResult.bat %RESULT% "中間テーブルからOMOP CDM形式データへの変換" "%LOGFILE%"
if not "%AUTO_EXEC%"=="1" PAUSE
exit /b 1
