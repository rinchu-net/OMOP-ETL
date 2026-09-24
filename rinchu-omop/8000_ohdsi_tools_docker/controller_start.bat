@echo off
chcp 65001 >nul
REM Atlas+WebAPI+RStudio用docker-composeバッチ（コンテナ起動用）
cd /d %~dp0

CALL controller.bat start

REM コンテナ起動後、ポータルを自動起動
timeout /t 3 /nobreak
start "" "%~dp0portal\portal.html"

PAUSE
