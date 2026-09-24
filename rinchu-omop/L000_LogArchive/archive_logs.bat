@echo off
chcp 65001 >nul
REM ====================================
REM Log File Archive Batch
REM ====================================
REM Collects log files scattered across folders
REM and moves them to a timestamped archive folder.
REM ====================================

setlocal enabledelayedexpansion

REM Get timestamp (YYYYMMDDHHMMSS)
REM Use PowerShell to reliably obtain timestamp
for /f "usebackq" %%i in (`powershell -Command "Get-Date -Format 'yyyyMMddHHmmss'"`) do set TIMESTAMP=%%i

echo ====================================
echo ログファイルアーカイブ開始
echo ====================================
echo.

REM Get the location of the current batch file
set "SCRIPT_DIR=%~dp0"
REM Remove trailing backslash
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
REM Project root directory (3.Development)
set "PROJECT_ROOT=%SCRIPT_DIR%\.."

REM Create archive directory
set "ARCHIVE_DIR=%SCRIPT_DIR%\%TIMESTAMP%"
echo アーカイブディレクトリ作成: %ARCHIVE_DIR%
if not exist "%ARCHIVE_DIR%" mkdir "%ARCHIVE_DIR%"
echo.

REM List of folders containing log files
set LOG_FOLDERS=1000_database_setup\01_database 1000_database_setup\02_schema 1000_database_setup\03_table_source 1000_database_setup\04_table_omop 2000_etl_setup\log 3000_load_source\log 4000_load_vocab\log 5000_etl_execute\log 6000_statistics\log 7000_export_omop\log S000_export_source\log L000_LogArchive

echo ====================================
echo ログファイル収集開始
echo ====================================
echo.

set TOTAL_COUNT=0

for %%F in (%LOG_FOLDERS%) do (
    set "FOLDER_PATH=%PROJECT_ROOT%\%%F"
    echo [処理中] %%F
    
    REM Check for existence of log files
    if exist "!FOLDER_PATH!\*.log" (
        REM Recreate folder structure in archive destination
        set "DEST_FOLDER=%ARCHIVE_DIR%\%%F"
        if not exist "!DEST_FOLDER!" (
            md "!DEST_FOLDER!"
        )
        
        REM Count and move log files
        set COUNT=0
        for %%L in ("!FOLDER_PATH!\*.log") do (
            move "%%L" "!DEST_FOLDER!\" 1>nul
            if !ERRORLEVEL! equ 0 (
                set /a COUNT+=1
                set /a TOTAL_COUNT+=1
                echo   移動: %%~nxL
            ) else (
                echo   [警告] 移動失敗: %%~nxL
            )
        )
        echo   --^> !COUNT! 件のログファイルを移動しました
    ) else (
        echo   --^> ログファイルが見つかりません
    )
    echo.
)

echo ====================================
echo ログファイルアーカイブ完了
echo ====================================
echo 総移動ファイル数: %TOTAL_COUNT% 件
echo アーカイブ場所: %ARCHIVE_DIR%
echo ====================================
echo.

pause
endlocal
