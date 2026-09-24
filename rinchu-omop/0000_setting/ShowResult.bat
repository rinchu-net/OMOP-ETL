@echo off
REM ====================================================================
REM Display execution result
REM ====================================================================
REM Args: %1 = Error level
REM       %2 = Process name
REM       %3 = Log file path
REM ====================================================================

setlocal
set "ERRLVL=%~1"
set "PROCESS_NAME=%~2"
set "LOGFILE=%~3"

if "%LOGFILE%" neq "" (
    if exist "%LOGFILE%" type "%LOGFILE%"
)

if "%ERRLVL%"=="0" (
    echo.
    echo =====================================
    echo  ✅ %PROCESS_NAME%は正常に完了しました
    echo =====================================
    if "%LOGFILE%" neq "" echo ログファイルを確認してください: %LOGFILE%
) else (
    echo.
    echo =====================================
    echo  ❌ %PROCESS_NAME%中にエラーが発生しました！
    echo =====================================
    if "%LOGFILE%" neq "" echo ログファイルを確認してください: %LOGFILE%
)
endlocal
exit /b %ERRLVL%
