@echo off
chcp 65001 >nul
REM Export RINCHU source tables to CSV
REM Load environment variables
CALL _env_source.bat

SET PGCLIENTENCODING=UTF8
SET PARAM=-U %PGUSER% -d %PGDATABASE%

REM Get timestamp (locale independent)
for /f "tokens=1-6" %%a in ('powershell -NoProfile -Command "Get-Date -Format 'yyyy MM dd HH mm ss'"') do (
    set YEAR=%%a
    set MONTH=%%b
    set DAY=%%c
    set HOUR=%%d
    set MINUTE=%%e
    set SECOND=%%f
)
set LOGTS=%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%%SECOND%

SET TARGET=export_rinchu
if not exist log mkdir log
if not exist dat mkdir dat
set LOGFILE=log\%TARGET%_%LOGTS%.log
set SCHEMA=%SOURCE_SCHEMA%
set TEMPLATE=export_rinchu.sql
set SQL=export_rinchu_run.sql
powershell -NoProfile -Command "(Get-Content %TEMPLATE% -Encoding UTF8) -replace '@schema', '%SCHEMA%' | Set-Content %SQL% -Encoding UTF8"
psql %PARAM% -f %SQL% >> %LOGFILE% 2>&1
if errorlevel 1 (
    ECHO エクスポートに失敗しました。ログを確認してください: %LOGFILE%
    del %SQL%
    exit /b 1
)

del %SQL%
ECHO エクスポートが完了しました。 [%LOGFILE%]
