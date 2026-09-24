@echo off
chcp 65001 >nul

REM ===============================================================
REM  Deploy data to OMOP CDM production environment
REM ===============================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Validate arguments
if not "%1"=="" (
    if not "%1"=="--data" (
        if not "%1"=="--master" (
            echo [ERROR] 無効な引数: %1
            echo 有効な引数: --data, --master, または引数なし（両方実行）
            exit /b 1
        )
    )
)

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "OMOP CDM本番スキーマへのデータ反映" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=06_production_deployment

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

REM Prepare log directory
if not exist ..\log mkdir ..\log
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%SOURCE_SCHEMA%
set TEMPLATE=%TARGET%.sql
set SQL_DATA=%TARGET%_data.sql
set SQL_MASTER=%TARGET%_master.sql

REM Execute based on argument
if "%1"=="--data" (
    REM Execute data only
    psql %PARAM% -f %SQL_DATA% >> %LOGFILE% 2>&1
    if errorlevel 1 goto :error
) else if "%1"=="--master" (
    REM Execute master only
    psql %PARAM% -f %SQL_MASTER% >> %LOGFILE% 2>&1
    if errorlevel 1 goto :error
) else (
    REM Execute both (no argument)
    psql %PARAM% -f %SQL_DATA% >> %LOGFILE% 2>&1
    if errorlevel 1 goto :error
    psql %PARAM% -f %SQL_MASTER% >> %LOGFILE% 2>&1
    if errorlevel 1 goto :error
)
set RESULT=0
CALL %SETPATH%\ShowResult.bat %RESULT% "OMOP CDM本番スキーマへのデータ反映" "%LOGFILE%"
if not "%AUTO_EXEC%"=="1" PAUSE
exit /b 0

:error
set RESULT=%ERRORLEVEL%
CALL %SETPATH%\ShowResult.bat %RESULT% "OMOP CDM本番スキーマへのデータ反映" "%LOGFILE%"
if not "%AUTO_EXEC%"=="1" PAUSE
exit /b 1
