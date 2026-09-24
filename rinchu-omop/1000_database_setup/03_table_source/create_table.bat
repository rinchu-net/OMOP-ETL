@echo off
chcp 65001 >nul

REM ====================================================================
REM  Data Source / Master Table Creation
REM ====================================================================

REM Common configuration path
SET SETPATH=..\..\0000_setting
    
REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation prompt
CALL %SETPATH%\ConfirmExecution.bat "データソース・マスタテーブル作成" %ENVPATH%
if errorlevel 1 exit /b 1

REM Set target file name
SET TARGET=create_table

REM PostgreSQL connection parameter settings
SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -U %PGUSER% -d %PGDATABASE% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat 2>nul

REM Set log file name
set LOGFILE=%TARGET%_%LOGTS%.log

REM Extract and display table names from ddl files
set TABLES=create_rinchu.sql create_master.sql
for %%F in (%TABLES%) do (
    echo.
    echo ==============================
    echo [対象DDLファイル: %%F]
    echo ==============================
    for /f "tokens=3 delims= " %%T in ('findstr /R /C:"^CREATE TABLE" %%F') do (
        echo   %%T >> %LOGFILE% 2>&1
    )
)
echo.

REM Execute SQL
psql %PARAM% -f create_rinchu.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
psql %PARAM% -f create_master.sql >> %LOGFILE% 2>&1
if errorlevel 1 goto :error
REM Set UNLOGGED mode to reduce WAL logging (PGS_UNLOGGED=Y の場合のみ実行)
if /i "%PGS_UNLOGGED%"=="Y" (
    psql %PARAM% -f unlogged_table.sql >> %LOGFILE% 2>&1
    if errorlevel 1 goto :error
)

set RESULT=0
CALL %SETPATH%\ShowResult.bat %RESULT% "データソース・マスタテーブル作成" "%LOGFILE%"
if not "%AUTO_EXEC%"=="1" PAUSE
exit /b 0

:error
set RESULT=%ERRORLEVEL%
CALL %SETPATH%\ShowResult.bat %RESULT% "データソース・マスタテーブル作成" "%LOGFILE%"
if not "%AUTO_EXEC%"=="1" PAUSE
exit /b 1
