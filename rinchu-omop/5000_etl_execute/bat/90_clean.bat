@echo off
chcp 65001 >nul

REM ===============================================================
REM  ETL 中間テーブルの TRUNCATE (対話選択)
REM   1) stem  : 90_clean_stem.sql  (01+02 の INSERT 対象)
REM   2) final : 90_clean_final.sql (04 の INSERT 対象)
REM ===============================================================

SET SETPATH=..\..\0000_setting
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

echo.
echo ================================================
echo  TRUNCATE 対象を選択してください
echo    [1] stem  : 01+02 INSERT 対象 [person/visit/death/stem_source/stem_m 系]
echo    [2] final : 04 INSERT 対象    [condition/drug/device/measurement/... 系]
echo    [q] 中止
echo ================================================
set /p CHOICE=選択 [1/2/q]:

if "%CHOICE%"=="1" (
    SET SQL=90_clean_stem.sql
    SET LABEL=stem
    SET TITLE=中間テーブル[stem系]のTRUNCATE
) else if "%CHOICE%"=="2" (
    SET SQL=90_clean_final.sql
    SET LABEL=final
    SET TITLE=中間テーブル[final系]のTRUNCATE
) else if /i "%CHOICE%"=="q" (
    echo 中止しました
    exit /b 0
) else (
    echo 無効な選択: %CHOICE%
    exit /b 1
)

CALL %SETPATH%\ConfirmExecution.bat "%TITLE%" "%ENVPATH%"
if errorlevel 1 exit /b 0

SET TARGET=90_clean_%LABEL%
CALL %SETPATH%\SetTimestamp.bat

SET PGCLIENTENCODING=UTF8
SET PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA%

if not exist ..\log mkdir ..\log
SET LOGFILE=..\log\%TARGET%_%LOGTS%.log

psql %PARAM% -v ON_ERROR_STOP=1 -f "%SQL%" >> "%LOGFILE%" 2>&1
SET RESULT=%ERRORLEVEL%

CALL %SETPATH%\ShowResult.bat %RESULT% "%TITLE%" "%LOGFILE%"

if not "%AUTO_EXEC%"=="1" PAUSE
exit /b %RESULT%
