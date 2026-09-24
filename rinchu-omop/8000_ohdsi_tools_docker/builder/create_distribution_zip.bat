@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul
echo ========================================
echo Distribution ZIP Creator (Image Update)
echo ========================================
echo.

rem Get current directory
set SCRIPT_DIR=%~dp0
set PARENT_DIR=!SCRIPT_DIR:~0,-1!
for %%A in ("!PARENT_DIR!") do set PARENT_DIR=%%~dpA
set PARENT_DIR=!PARENT_DIR:~0,-1!

echo Script Dir: !SCRIPT_DIR!
echo Parent Dir: !PARENT_DIR!
echo.

rem ========================================
rem 1. File existence check
rem ========================================
echo [Step 1] File existence check...
echo.

set ALL_FILES_EXIST=1

rem Check images/*.tar files
set TAR_COUNT=0
for %%F in ("!PARENT_DIR!\images\*.tar") do (
    if exist "%%~F" (
        set /a TAR_COUNT+=1
    )
)
if !TAR_COUNT! GTR 0 (
    echo   [OK] images\*.tar ^(!TAR_COUNT! files^)
) else (
    echo   [NG] images\*.tar not found
    set ALL_FILES_EXIST=0
)

rem Check .env
if exist "!PARENT_DIR!\.env" (
    echo   [OK] .env
) else (
    echo   [NG] .env not found
    set ALL_FILES_EXIST=0
)

echo.

if !ALL_FILES_EXIST! EQU 0 (
    echo [ERROR] Required files are missing.
    echo.
    pause
    exit /b 1
)

echo [OK] All required files confirmed.
echo.

rem ========================================
rem 2. Create ZIP file
rem ========================================
echo [Step 2] Creating ZIP file...
echo.

set ZIP_OUTPUT=!SCRIPT_DIR!ohdsi_tools_docker_update.zip
set TEMP_WORK_DIR=!SCRIPT_DIR!ohdsi_tools_docker_update

rem Remove temporary folder if it exists
if exist "!TEMP_WORK_DIR!" (
    rmdir /s /q "!TEMP_WORK_DIR!" >nul 2>&1
)
mkdir "!TEMP_WORK_DIR!"

rem Copy .env
copy "!PARENT_DIR!\.env" "!TEMP_WORK_DIR!" >nul 2>&1

rem Copy images/*.tar
mkdir "!TEMP_WORK_DIR!\images"
xcopy "!PARENT_DIR!\images\*.tar" "!TEMP_WORK_DIR!\images\" /q >nul 2>&1

echo   - Creating ZIP file (this may take a few moments)...

if exist "!ZIP_OUTPUT!" del /q "!ZIP_OUTPUT!" >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "Add-Type -AssemblyName 'System.IO.Compression.FileSystem'; [System.IO.Compression.ZipFile]::CreateFromDirectory('!TEMP_WORK_DIR!', '!ZIP_OUTPUT!', 'Optimal', $true)" >nul 2>&1

if exist "!ZIP_OUTPUT!" (
    echo   [OK] ZIP file created successfully
) else (
    echo   [ERROR] Failed to create ZIP file
    rmdir /s /q "!TEMP_WORK_DIR!" >nul 2>&1
    pause
    exit /b 1
)

echo.

rem ========================================
rem 3. 完了処理
rem ========================================

if exist "!ZIP_OUTPUT!" (
    for /F "usebackq" %%A in ('!ZIP_OUTPUT!') do (
        set ZIP_SIZE=%%~zA
    )
    set /A ZIP_SIZE_MB=!ZIP_SIZE!/1048576

    echo [SUCCESS] Distribution ZIP file created!
    echo.
    echo   File: !ZIP_OUTPUT!
    echo   Size: !ZIP_SIZE_MB! MB
    echo   Contents: images\*.tar ^(!TAR_COUNT! files^), .env
    echo.
) else (
    echo [ERROR] ZIP file not found
    rmdir /s /q "!TEMP_WORK_DIR!"
    pause
    exit /b 1
)

rem 一時フォルダを削除
rmdir /s /q "!TEMP_WORK_DIR!"

echo [Completed] All processes completed.
echo.
pause
exit /b 0
