@echo off
chcp 65001 >nul
REM Atlas+WebAPI+RStudio用docker-composeバッチ（コンテナ停止用）
cd /d %~dp0

CALL controller.bat stop
PAUSE

