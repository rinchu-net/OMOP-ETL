@echo off
chcp 65001 >nul

REM =====================================================
REM Import source_to_concept_map CSV files
REM =====================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "source_to_concept_map CSVファイルのインポート" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=03_import_stcm

REM Parse command line arguments
SET BACKUP_ENABLED=1
IF "%1"=="--nobackup" (
    SET BACKUP_ENABLED=0
)

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE%

REM Prepare log directory
if not exist ..\log mkdir ..\log
if not exist ..\backup mkdir ..\backup
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%WORKING_SCHEMA%
set BACKUPSQL=import_stcm_backup.sql
set BACKUPFILE=..\backup\source_to_concept_map_f_%LOGTS%.csv
set ZIPFILE=..\backup\source_to_concept_map_f_%LOGTS%.zip

REM Backup source_to_concept_map_f before update
IF %BACKUP_ENABLED% EQU 1 (
    echo Saving Backup current source_to_concept_map_f ... %BACKUPFILE% >> %LOGFILE%
    echo \copy %SCHEMA%.source_to_concept_map_f TO '%BACKUPFILE%' WITH ^(FORMAT csv, HEADER true, ENCODING 'UTF8'^); > %BACKUPSQL%
    psql %PARAM% -f %BACKUPSQL% >> %LOGFILE% 2>&1
    del %BACKUPSQL%
    if exist "%BACKUPFILE%" (
        powershell -Command "Compress-Archive -Path '%BACKUPFILE%' -DestinationPath '%ZIPFILE%'"
        ECHO %BACKUPFILE%
        if exist "%BACKUPFILE%" del "%BACKUPFILE%"
    )
) ELSE (
    echo Backup skipped due to --nobackup flag >> %LOGFILE%
)

REM Initialize source_to_concept_map_f
echo Delete current source_to_concept_map before loading CSVs >> %LOGFILE%
psql %PARAM% -c "TRUNCATE TABLE %SCHEMA%.source_to_concept_map_f;" >> %LOGFILE% 2>&1

REM Import each CSV file
set IMPORT_RESULT=0
for %%F in (..\stcm\*.csv) do (
    echo Importing file: %%F >> %LOGFILE%
    psql %PARAM% -c "\copy %SCHEMA%.source_to_concept_map_f FROM '%%F' WITH (FORMAT csv, DELIMITER ',', HEADER true, ENCODING 'UTF8');" >> %LOGFILE% 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to import: %%F >> %LOGFILE%
        set IMPORT_RESULT=1
    )
)

REM Analyze after import (only when import succeeded)
IF %IMPORT_RESULT% EQU 0 (
    echo Running ANALYZE VERBOSE on %SCHEMA%.source_to_concept_map_f ... >> %LOGFILE%
    psql %PARAM% -c "ANALYZE VERBOSE %SCHEMA%.source_to_concept_map_f;" >> %LOGFILE% 2>&1
)

set RESULT=%IMPORT_RESULT%

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "source_to_concept_map CSVファイルのインポート" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%
