@echo off
chcp 65001 >nul

REM =====================================================
REM Auto-generate mapping tables from disease and drug masters
REM =====================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "ATHENAマッピングテーブル自動生成" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=02_generate_automapping

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE%

REM Prepare log directory
if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%WORKING_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL=%TARGET%_run.sql
powershell -Command "(Get-Content %TEMPLATE%) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%
del %SQL%

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "ATHENAマッピングテーブル自動生成" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%