@echo off
chcp 65001 >nul

REM =====================================================
REM   Import various master CSV files
REM =====================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "各種マスタCSVファイルのインポート" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=02_import_master

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE%

REM Prepare log directory
if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%SOURCE_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL=%TARGET%_run.sql
powershell -Command "(Get-Content %TEMPLATE%) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%
del %SQL%

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "各種マスタCSVファイルのインポート" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%

