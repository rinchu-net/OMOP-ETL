@echo off
chcp 65001 >nul 2>&1
REM ====================================================================
REM Execution confirmation prompt
REM ====================================================================
REM Args: %1 = Process name
REM       %2 = Environment file path (optional)
REM Return: exit /b 1 if user selects N
REM ====================================================================
REM Note: If AUTO_EXEC=1 is set, skip confirmation
REM ====================================================================

REM Check for auto-execution mode
if "%AUTO_EXEC%"=="1" (
    echo [AUTO_EXEC MODE] %~1 を実行します...
    exit /b 0
)

setlocal
set "PROCESS_NAME=%~1"
set "ENVPATH=%~2"

echo.
echo =====================================================
echo %PROCESS_NAME%
echo =====================================================
echo.

REM 環境変数ファイルが指定されている場合は設定値を表示
if not "%ENVPATH%"=="" (
    if exist "%ENVPATH%" (
        echo [PostgreSQL接続情報]
        echo   DB SERVER:PORT = %PGHOST%:%PGPORT%
        echo   DATABASE       = %PGDATABASE%
        echo   USER           = %PGUSER%
        echo.
        echo [スキーマ情報]
        echo   SOURCE_SCHEMA      = %SOURCE_SCHEMA%
        echo   WORKING_SCHEMA     = %WORKING_SCHEMA%
        echo   PRODUCTION_SCHEMA  = %PRODUCTION_SCHEMA%
        echo   ATLASRESULT_SCHEMA = %ATLASRESULT_SCHEMA%
        echo.
        echo [病院固有設定]
        echo   CARE_SITE_SOURCE_VALUE = %CARE_SITE_SOURCE_VALUE%
        echo.
    )
)

echo ======================================================================
echo   パラメータ設定は正しい内容か確認してください。実行しますか？ (Y/N)
echo ======================================================================
echo.
set /p RUN1="[Y/N]: "
if /I not "%RUN1%"=="Y" (
    echo %PROCESS_NAME%の実行を中止しました。
    endlocal
    exit /b 1
)
endlocal
exit /b 0
