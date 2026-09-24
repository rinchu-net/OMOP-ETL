@echo off
chcp 65001 >nul

REM ====================================================================
REM  ALTER TABLE SET UNLOGGED for staging/production tables
REM  Purpose: Reduce disk usage by disabling WAL for all staging/production tables
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "テーブルUNLOGGED化" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=unlogged_table

REM PostgreSQL connection parameters
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA% -v atlasresult_schema=%ATLASRESULT_SCHEMA%

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM Set log file name
set LOGFILE=%TARGET%_%LOGTS%.log

REM Execute ALTER TABLE script
echo Altering all tables to UNLOGGED...
psql --set ON_ERROR_STOP=1 %PARAM% -f unlogged_table.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto error

REM Normal completion
set RESULT=0
goto show_result

:error
set RESULT=1

:show_result
CALL %SETPATH%\ShowResult.bat %RESULT% "テーブルUNLOGGED化" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%
