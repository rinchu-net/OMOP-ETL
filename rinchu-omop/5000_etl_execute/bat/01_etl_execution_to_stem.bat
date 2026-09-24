@echo off
chcp 65001 >nul

REM ===============================================================
REM  Data conversion from source to intermediate tables
REM ===============================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "ソースデータから中間テーブルまでのデータ変換" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=01_etl_execution_to_stem

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


psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

REM Display results
CALL %SETPATH%\ShowResult.bat %RESULT% "ソースデータから中間テーブルまでのデータ変換" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%