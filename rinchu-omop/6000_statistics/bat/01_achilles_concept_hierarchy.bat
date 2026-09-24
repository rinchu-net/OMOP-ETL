@echo off
chcp 65001 >nul

REM ===============================================================
REM  Achilles Concept hierarchy generation batch file
REM  - Executes: 01_achilles_concept_hierarchy.sql
REM  - Then executes: 01_achilles_analysis.sql (for WebAPI compatibility)
REM ===============================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "Achilles Concept hierarchy生成" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA% -v atlasresult_schema=%ATLASRESULT_SCHEMA%

REM Prepare log directory
if not exist ..\log mkdir ..\log

REM Set log file (shared for both SQL executions)
SET TARGET=01_achilles_concept_hierarchy
set LOGFILE=..\log\%TARGET%_%LOGTS%.log

REM ========== 1st: Execute 01_achilles_concept_hierarchy1.sql ==========
psql %PARAM% -f 01_achilles_concept_hierarchy1.sql >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

if not %RESULT% EQU 0 (
    CALL %SETPATH%\ShowResult.bat %RESULT% "Achilles Concept hierarchy生成" "%LOGFILE%"
    if not "%AUTO_EXEC%"=="1" PAUSE
    exit /b 1
)

REM ========== 2nd: Execute 01_achilles_concept_hierarchy2.sql (WebAPI compatibility) ==========
REM Note: Using same LOGFILE from above
psql %PARAM% -f 01_achilles_concept_hierarchy2.sql >> %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

REM Show final result
CALL %SETPATH%\ShowResult.bat %RESULT% "Achilles Concept hierarchy生成" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%
