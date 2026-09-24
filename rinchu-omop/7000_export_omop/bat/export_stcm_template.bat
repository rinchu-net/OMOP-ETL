@echo off
chcp 65001 >nul

REM ===============================================================
REM  CSV extraction process for source_to_concept_map verification
REM ===============================================================

REM Common settings path
SET SETPATH=..\..\0000_setting

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "source_to_concept_mapテンプレートCSV抽出" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set target file name
SET TARGET=export_stcm_template

REM Set timestamp
CALL %SETPATH%\SetTimestamp.bat

REM PostgreSQL connection parameters
SET PGCLIENTENCODING=UTF8
set PARAM=-h %PGHOST% -p %PGPORT% -d %PGDATABASE% -U %PGUSER% -v working_schema=%WORKING_SCHEMA% -v source_schema=%SOURCE_SCHEMA% -v production_schema=%PRODUCTION_SCHEMA%

REM Prepare log directory
if not exist ..\log mkdir ..\log
if not exist ..\stcm mkdir ..\stcm
set LOGFILE=..\log\%TARGET%_%LOGTS%.log
set SCHEMA=%WORKING_SCHEMA%

ECHO ======================================== >> %LOGFILE%
ECHO source_to_concept_map エクスポート開始 >> %LOGFILE%
ECHO 実行日時: %YEAR%-%MONTH%-%DAY% %HOUR%:%MINUTE%:%SECOND% >> %LOGFILE%
ECHO ======================================== >> %LOGFILE%

REM 1. Get list of source_vocabulary_id
ECHO source_vocabulary_idのリストを取得中... >> %LOGFILE%
set VOCAB_LIST_SQL=export_stcm_template_vocabulary_list_run.sql
set VOCAB_LIST_FILE=export_stcm_template_vocabulary_list.tmp

REM Replace schema name in SQL file
powershell -Command "(Get-Content 'export_stcm_template_vocabulary_list.sql') -replace ':working_schema', '%SCHEMA%' | Set-Content '%VOCAB_LIST_SQL%' -Encoding UTF8"

REM Get vocabulary_id list
psql %PARAM% -t -A -f "%VOCAB_LIST_SQL%" > "%VOCAB_LIST_FILE%" 2>> %LOGFILE%

REM 2. Execute export for each vocabulary_id
ECHO. >> %LOGFILE%
ECHO 各vocabulary_idのエクスポートを開始します... >> %LOGFILE%
ECHO. >> %LOGFILE%

for /f "usebackq delims=" %%V in ("%VOCAB_LIST_FILE%") do (
    ECHO ==== Processing: %%V ==== >> %LOGFILE%
    ECHO 処理中: %%V
    
    REM Replace schema name and vocabulary_id in SQL file
    powershell -Command "$content = Get-Content 'export_stcm_template.sql' -Raw; $content = $content -replace ':working_schema', '%SCHEMA%'; $content = $content -replace ':source_vocabulary_id', '%%V'; $content = $content -replace ':output_file', 'template_%%V.csv'; Set-Content 'export_stcm_template_run.sql' -Value $content -Encoding UTF8" >> %LOGFILE% 2>&1
    
    REM Execute export
    psql %PARAM% -f "export_stcm_template_run.sql" >> %LOGFILE% 2>&1
    set RESULT=%ERRORLEVEL%

    REM Convert to UTF-8 with BOM
    powershell -Command "$content = Get-Content '..\stcm\template_%%V.csv' -Raw -Encoding UTF8; $utf8BOM = New-Object System.Text.UTF8Encoding $true; [System.IO.File]::WriteAllText('..\stcm\template_%%V.csv', $content, $utf8BOM)" >> %LOGFILE% 2>&1
    
    ECHO 完了: %%V >> %LOGFILE%
    ECHO. >> %LOGFILE%
)

REM Delete temporary files
del "%VOCAB_LIST_FILE%" 2>nul
del "export_stcm_template_vocabulary_list_run.sql" 2>nul
del "export_stcm_template_run.sql" 2>nul

REM Show result
CALL %SETPATH%\ShowResult.bat %RESULT% "source_to_concept_mapテンプレートエクスポート" "%LOGFILE%"

PAUSE

