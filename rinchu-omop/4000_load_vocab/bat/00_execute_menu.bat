@echo off
chcp 65001

REM Argument check
set FORCE=0
if /I "%1"=="--force" set FORCE=1

echo ============================================================
echo このバッチでは以下の3つの処理を順に実行します。
echo ------------------------------------------------------------
echo STEP1. ATHENAから取得したVocabularyデータのインポート
echo .
echo STEP2. 各種マスタとATHENAマスタからマッピングテーブルの生成
echo .
echo STEP3. source_to_concept_map用CSVファイルの一括インポート
echo ------------------------------------------------------------
echo 各処理ごとに実行するかどうかを選択できます。
echo =====================================================

setlocal

REM Execution confirmation for 01_import_athena.bat
set RUN1=N
if not %FORCE%==1 set /p RUN1="ATHENAから取得したVocabularyデータのインポートを実行しますか？ (Y/N): "
if /I "%RUN1%"=="Y" goto RUNSTEP1
if "%FORCE%"=="1" goto RUNSTEP1

echo 01_import_athena.bat をスキップします。
goto STEP2

:RUNSTEP1
call 01_import_athena.bat
if %ERRORLEVEL% neq 0 (
    echo 01_import_athena.bat でエラーが発生しました。
    exit /b %ERRORLEVEL%
)

:STEP2
REM Execution confirmation for 02_generate_automapping.bat
set RUN2=N
if not %FORCE%==1 set /p RUN2="各種マスタとATHENAマスタからマッピングテーブルの生成を実行しますか？ (Y/N): "
if /I "%RUN2%"=="Y" goto RUNSTEP2
if "%FORCE%"=="1" goto RUNSTEP2

echo 02_generate_automapping.bat をスキップします。
goto STEP3

:RUNSTEP2
call 02_generate_automapping.bat
if %ERRORLEVEL% neq 0 (
    echo 02_generate_automapping.bat でエラーが発生しました。
    exit /b %ERRORLEVEL%
)

:STEP3
REM Execution confirmation for 03_import_stcm.bat
set RUN3=N
if not %FORCE%==1 set /p RUN3="source_to_concept_map用CSVファイルの一括インポートを実行しますか？ (Y/N): "
if /I "%RUN3%"=="Y" goto RUNSTEP3
if "%FORCE%"=="1" goto RUNSTEP3

echo 03_import_stcm.bat をスキップします。
goto ENDALL

:RUNSTEP3
call 03_import_stcm.bat
if %ERRORLEVEL% neq 0 (
    echo 03_import_stcm.bat でエラーが発生しました。
    exit /b %ERRORLEVEL%
)

:ENDALL
endlocal
echo 全てのバッチ処理が完了しました.
