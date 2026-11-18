@echo off
chcp 65001 >nul

REM =====================================================
REM   Import source data from Rinchu standard database
REM   SOURCE_LOAD_MODE=CSV : import CSV files in ..\dat
REM   SOURCE_LOAD_MODE=DB  : import tables via postgres_fdw
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

REM Select source load mode (default: CSV)
if "%SOURCE_LOAD_MODE%"=="" set SOURCE_LOAD_MODE=CSV
if /I "%SOURCE_LOAD_MODE%"=="DB" goto :DB_LOAD
if /I not "%SOURCE_LOAD_MODE%"=="CSV" (
    echo [ERROR] SOURCE_LOAD_MODE must be CSV or DB: %SOURCE_LOAD_MODE%
    echo [ERROR] SOURCE_LOAD_MODE must be CSV or DB: %SOURCE_LOAD_MODE% >> %LOGFILE%
    set RESULT=1
    goto :SHOW_RESULT
)

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
goto :SHOW_RESULT

:DB_LOAD
REM ===== Import tables from Rinchu database via postgres_fdw =====
set DB_MISSING=0
for %%V in (RINCHU_HOST RINCHU_PORT RINCHU_DB RINCHU_SCHEMA RINCHU_USER RINCHU_PASSWORD RINCHU_SSLMODE RINCHU_FETCH_SIZE) do (
    if not defined %%V (
        echo [ERROR] %%V is not set in _env.bat
        echo [ERROR] %%V is not set in _env.bat >> %LOGFILE%
        set DB_MISSING=1
    )
)
if "%RINCHU_PASSWORD%"=="(your password here)" (
    echo [ERROR] RINCHU_PASSWORD in _env.bat is not configured
    echo [ERROR] RINCHU_PASSWORD in _env.bat is not configured >> %LOGFILE%
    set DB_MISSING=1
)
if "%DB_MISSING%"=="1" (
    echo [ERROR] Process aborted without executing SQL
    echo [ERROR] Process aborted without executing SQL >> %LOGFILE%
    set RESULT=1
    goto :SHOW_RESULT
)

echo [INFO] Import from Rinchu DB %RINCHU_HOST%:%RINCHU_PORT%/%RINCHU_DB% schema=%RINCHU_SCHEMA%
echo [INFO] Import from Rinchu DB %RINCHU_HOST%:%RINCHU_PORT%/%RINCHU_DB% schema=%RINCHU_SCHEMA% >> %LOGFILE%
psql %PARAM% -v source_schema=%SOURCE_SCHEMA% -v "rinchu_host=%RINCHU_HOST%" -v "rinchu_port=%RINCHU_PORT%" -v "rinchu_db=%RINCHU_DB%" -v "rinchu_schema=%RINCHU_SCHEMA%" -v "rinchu_user=%RINCHU_USER%" -v "rinchu_password=%RINCHU_PASSWORD%" -v "rinchu_sslmode=%RINCHU_SSLMODE%" -v "rinchu_fetch_size=%RINCHU_FETCH_SIZE%" -f %TARGET%_fdw.sql >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

:SHOW_RESULT
REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "ソースデータのインポート" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%