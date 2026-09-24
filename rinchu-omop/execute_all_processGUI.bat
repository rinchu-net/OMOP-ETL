@echo off
REM ====================================================================
REM HTA Menu Launcher (Simple version)
REM ====================================================================

cd /d "%~dp0"
start mshta "%cd%\execute_all_process.hta"
