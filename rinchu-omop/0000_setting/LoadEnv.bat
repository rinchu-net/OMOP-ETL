@echo off
REM ====================================================================
REM Load environment variable file
REM ====================================================================
REM Args: %1 = Environment variable file path
REM Return: exit /b 1 if file not found
REM ====================================================================

set "ENVPATH=%~1"

if not exist "%ENVPATH%" (
    echo.
    echo ====================================================
    echo   エラー: 環境変数ファイルが見つかりません。
    echo   ファイルパス: %ENVPATH%
    echo ====================================================
    echo.
    pause
    exit /b 1
)

call "%ENVPATH%"
exit /b 0
