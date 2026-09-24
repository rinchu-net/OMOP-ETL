@echo off
chcp 65001 >nul

REM ========================================================
REM  (Not normally used) Delete all VIEWs in working_schema
REM ========================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

CALL %SETPATH%\ConfirmExecution.bat "working_schema全VIEW削除" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=drop_etl

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%WORKING_SCHEMA%

REM === Delete all VIEWs in specified schema ===
psql %PARAM% -c "DO $$ DECLARE r RECORD; BEGIN FOR r IN (SELECT table_schema, table_name FROM information_schema.views WHERE table_schema = '%WORKING_SCHEMA%') LOOP EXECUTE 'DROP VIEW IF EXISTS ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ' CASCADE'; END LOOP; END $$;"  >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

CALL %SETPATH%\ShowResult.bat %RESULT% "working_schema全VIEW削除" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" pause
exit /b %RESULT%
