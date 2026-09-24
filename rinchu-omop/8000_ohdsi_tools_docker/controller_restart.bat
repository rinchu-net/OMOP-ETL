@echo off
chcp 65001 >nul
REM Atlas+WebAPI+RStudio用docker-composeバッチ（コンテナ再起動用）
cd /d %~dp0

CALL controller.bat restart
PAUSE
