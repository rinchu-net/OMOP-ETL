@echo off
chcp 65001

REM Argument check
set FORCE=0
if /I "%1"=="--force" set FORCE=1

echo .
echo ============================================================
echo このバッチでは以下の2つの処理を順に実行します。
echo ------------------------------------------------------------
echo STEP1. 臨中標準DBから取得したCSVデータのインポート
echo .
echo STEP2. 各種マスタのインポート
echo ------------------------------------------------------------
echo 各処理ごとに実行するかどうかを選択できます。
echo =====================================================

setlocal

REM Execution confirmation for 01_import_source.bat
set RUN1=N
if not %FORCE%==1 set /p RUN1="[STEP1]臨中標準DBから取得したCSVデータのインポートを実行しますか？ (Y/N): "
if /I "%RUN1%"=="Y" goto RUNSTEP1
if "%FORCE%"=="1" goto RUNSTEP1

echo 01_import_source.bat をスキップします。
goto STEP2

:RUNSTEP1
echo 01_import_source.batを実行します...
call 01_import_source.bat
if %ERRORLEVEL% neq 0 (
    echo 01_import_source.bat でエラーが発生しました。
    exit /b %ERRORLEVEL%
)

:STEP2
REM Execution confirmation for 02_import_master.bat
set RUN2=N
if not %FORCE%==1 set /p RUN2="[STEP2]各種マスタのインポートを実行しますか？ (Y/N): "
if /I "%RUN2%"=="Y" goto RUNSTEP2
if "%FORCE%"=="1" goto RUNSTEP2

echo 02_import_master.bat をスキップします。
goto ENDALL

:RUNSTEP2
echo 02_import_master.batを実行します...
call 02_import_master.bat
if %ERRORLEVEL% neq 0 (
    echo 02_import_master.bat でエラーが発生しました。
    exit /b %ERRORLEVEL%
)

:ENDALL
endlocal
echo 全てのバッチ処理が完了しました.
