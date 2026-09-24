@echo off
chcp 65001 >nul

REM ====================================================================
REM  (Not normally used) Create specified ETL VIEW file for OMOP conversion
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Set target file name
SET TARGET=create_etl_test
SET SQLFILE=%1

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA% -v care_site_source_value=%CARE_SITE_SOURCE_VALUE%

if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%WORKING_SCHEMA%

psql %PARAM% -f ../sql/%SQLFILE% >> %LOGFILE% 2>&1

TYPE %LOGFILE%