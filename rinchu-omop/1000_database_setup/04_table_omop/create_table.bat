@echo off
chcp 65001 >nul

REM ====================================================================
REM  Create OMOP-related tables
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "OMOP関連テーブル作成" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=create_table

REM PostgreSQL connection parameters
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA% -v atlasresult_schema=%ATLASRESULT_SCHEMA%

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM Set log file name
set LOGFILE=%TARGET%_%LOGTS%.log

REM Execute the DDL script with variable substitution in correct order
echo Creating Production tables...
psql --set ON_ERROR_STOP=1 %PARAM% -f OMOPCDM_postgresql_5.4_ddl.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto error

echo Creating indices...
psql --set ON_ERROR_STOP=1 %PARAM% -f OMOPCDM_postgresql_5.4_indices.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto error

echo Creating primary keys...
psql --set ON_ERROR_STOP=1 %PARAM% -f OMOPCDM_postgresql_5.4_primary_keys.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto error

echo Creating Staging tables...
psql --set ON_ERROR_STOP=1 %PARAM% -f OMOPETL_Staging_ddl.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto error

REM Set UNLOGGED mode to reduce WAL logging (PGS_UNLOGGED=Y の場合のみ実行)
if /i "%PGS_UNLOGGED%"=="Y" (
    echo Setting UNLOGGED mode for all tables...
    psql --set ON_ERROR_STOP=1 %PARAM% -f unlogged_table.sql >> %LOGFILE% 2>&1
    if errorlevel 1 goto error
)

echo Creating Atlas Results tables...
psql --set ON_ERROR_STOP=1 %PARAM% -f OHDSI_atlas_results.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto error

REM Not executed during initialization, execute after production table data is loaded
REM echo Creating Achilles count tables...
REM psql --set ON_ERROR_STOP=1 %PARAM% -f OHDSI_achilles_counts.sql
REM if errorlevel 1 goto error

REM Normal completion
set RESULT=0
goto show_result

:error
set RESULT=1

:show_result
REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "OMOP関連テーブル作成" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%
