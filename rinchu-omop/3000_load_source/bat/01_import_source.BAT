@echo off
chcp 65001 >nul

REM =====================================================
REM   Import CSV from Rinchu standard database
REM =====================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "ソースデータのインポート" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=01_import_source

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE%

REM Prepare log directory
if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log

REM Check for required CSV files
set CSV_FILES=InjectionData.csv ObservationResult.csv PatientAddress.csv PatientDisease.csv PatientIdentification.csv PatientVisit.csv PrescriptionData.csv
set CSV_MISSING=0

for %%F in (%CSV_FILES%) do (
    if not exist ..\dat\%%F (
        echo [ERROR] Required CSV file not found: %%F
        echo [ERROR] Required CSV file not found: %%F >> %LOGFILE%
        set CSV_MISSING=1
    )
)

if "%CSV_MISSING%"=="1" (
    echo.
    echo [ERROR] One or more required CSV files are missing in ..\dat folder
    echo [ERROR] Process aborted without executing SQL
    echo. >> %LOGFILE%
    echo [ERROR] One or more required CSV files are missing in ..\dat folder >> %LOGFILE%
    echo [ERROR] Process aborted without executing SQL >> %LOGFILE%
    set RESULT=1
    goto :SKIP_SQL
)

set SCHEMA=%SOURCE_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL=%TARGET%_run.sql
powershell -Command "(Get-Content %TEMPLATE%) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%
del %SQL%

:SKIP_SQL

REM Output message if CSV files were missing
if "%CSV_MISSING%"=="1" (
    echo.
    echo ====================================================================
    echo [WARNING] CSV file verification failed
    echo ====================================================================
    echo Required CSV files are missing in ..\dat folder
    echo Process was not executed due to missing files
    echo ====================================================================
    echo.
)

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "ソースデータのインポート" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%