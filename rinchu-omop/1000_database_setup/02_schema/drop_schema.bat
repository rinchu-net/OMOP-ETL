@echo off
chcp 65001 >nul

REM ====================================================================
REM OMOP database schema deletion
REM ====================================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "OMOPデータベース スキーマ削除" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=drop_schema

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM Set log file name
set LOGFILE=%TARGET%_%LOGTS%.log

REM Execute DDL
psql -h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA% -v atlasresult_schema=%ATLASRESULT_SCHEMA% -v temp_schema=%TEMP_SCHEMA% -f drop_schema.sql > %LOGFILE% 2>&1
set RESULT=%ERRORLEVEL%

REM Display results
CALL %SETPATH%\ShowResult.bat %RESULT% "OMOPデータベース スキーマ削除" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
