@echo off
chcp 65001 >nul

REM ====================================================================
REM Import ATHENA-related CSV files
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "ATHENA関連CSVファイルのインポート" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=01_import_athena

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE%

REM Prepare log directory
if not exist ..\log mkdir ..\log

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM Set log file
set LOGFILE=..\log\%TARGET%_%LOGTS%.log

REM Check for required CSV files
set CSV_FILES=CONCEPT.csv CONCEPT_ANCESTOR.csv CONCEPT_CLASS.csv CONCEPT_RELATIONSHIP.csv CONCEPT_SYNONYM.csv DOMAIN.csv DRUG_STRENGTH.csv RELATIONSHIP.csv VOCABULARY.csv
set CSV_MISSING=0

for %%F in (%CSV_FILES%) do (
    if not exist ..\athena\%%F (
        echo [ERROR] Required CSV file not found: %%F
        echo [ERROR] Required CSV file not found: %%F >> %LOGFILE%
        set CSV_MISSING=1
    )
)

if "%CSV_MISSING%"=="1" (
    echo.
    echo [ERROR] One or more required CSV files are missing in ..\athena folder
    echo [ERROR] Process aborted without executing SQL
    echo. >> %LOGFILE%
    echo [ERROR] One or more required CSV files are missing in ..\athena folder >> %LOGFILE%
    echo [ERROR] Process aborted without executing SQL >> %LOGFILE%
    set RESULT=1
    goto :SKIP_SQL
)

REM Execute SQL (schema replacement)
set SCHEMA=%WORKING_SCHEMA%
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
    echo Required CSV files are missing in ..\athena folder
    echo Process was not executed due to missing files
    echo ====================================================================
    echo.
)

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "ATHENA関連CSVファイルのインポート" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%