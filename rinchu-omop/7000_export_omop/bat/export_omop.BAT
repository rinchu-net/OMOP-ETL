@echo off
chcp 65001 >nul

echo ===============================================================
echo  OMOP CDMサンプルデータ抽出処理
echo ===============================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "OMOP CDMサンプルデータ抽出" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=export_omop

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

REM Prepare log directory
if not exist ..\log mkdir ..\log
if not exist ..\dat mkdir ..\dat
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%PRODUCTION_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL=%TARGET%_run.sql
powershell -Command "(Get-Content %TEMPLATE%) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%
del %SQL%

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "OMOP CDMサンプルデータ抽出" "%LOGFILE%"

PAUSE
