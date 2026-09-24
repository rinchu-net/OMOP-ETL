@echo off
REM ====================================================================
REM Get timestamp
REM ====================================================================
REM Args: none
REM Environment variables set: YEAR, MONTH, DAY, HOUR, MINUTE, SECOND, LOGTS
REM ====================================================================

for /f "tokens=1-6" %%a in ('powershell -Command "Get-Date -Format 'yyyy MM dd HH mm ss'"') do (
    set YEAR=%%a
    set MONTH=%%b
    set DAY=%%c
    set HOUR=%%d
    set MINUTE=%%e
    set SECOND=%%f
)
set LOGTS=%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%%SECOND%
exit /b 0
