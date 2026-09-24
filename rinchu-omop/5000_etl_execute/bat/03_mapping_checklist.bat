@echo off
chcp 65001 >nul

REM ====================================================================
REM  Create mapping table checklist
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "マッピングテーブルチェックリストの作成" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=03_mapping_checklist

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE%

REM Prepare log directory
if not exist ..\log mkdir ..\log
if not exist ..\checklist mkdir ..\checklist

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM Set log file
set LOGFILE=..\log\%TARGET%_%LOGTS%.log

REM Execute SQL (schema replacement)
set SCHEMA=%WORKING_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL=%TARGET%_run.sql
powershell -Command "(Get-Content %TEMPLATE%) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%
del %SQL%

REM Convert output CSV to UTF-8 BOM and rename with timestamp
set CSVOUT=..\checklist\source_to_concept_map_checklist.csv
set CSVTS=..\checklist\source_to_concept_map_checklist_%LOGTS%.csv
if exist "%CSVOUT%" (
    powershell -Command "$bytes = [System.IO.File]::ReadAllBytes('%CSVOUT%'); $bom = [byte[]](0xEF, 0xBB, 0xBF); $newBytes = $bom + $bytes; [System.IO.File]::WriteAllBytes('%CSVOUT%', $newBytes)"
    move /Y "%CSVOUT%" "%CSVTS%"
)

REM Display results
CALL %SETPATH%\ShowResult.bat %RESULT% "マッピングテーブルチェックリストの作成" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%
