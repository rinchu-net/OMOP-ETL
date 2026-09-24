@echo off
chcp 65001 >nul
REM Atlas+WebAPI+RStudio用docker-composeバッチ（引数対応）
cd /d %~dp0

if "%1"=="start" (
	echo === Atlas + WebAPI + HADES container start ===
	docker-compose -f docker-compose.yml up -d
) else if "%1"=="stop" (
	echo === Atlas + WebAPI + HADES container stop ===
	docker-compose -f docker-compose.yml stop
) else if "%1"=="restart" (
	echo === Atlas + WebAPI + HADES container restart ===
	docker-compose -f docker-compose.yml stop
	docker-compose -f docker-compose.yml up -d
) else if "%*"=="" (
	echo === Atlas + WebAPI + HADES container status ===
	docker-compose -f docker-compose.yml ps
) else (
	echo === docker-compose -f docker-compose.yml %* ===
	docker-compose -f docker-compose.yml %*
)

echo.
echo. [Usage]:
echo   controller ps         - check container status
echo   controller start      - start container(background)
echo   controller stop       - stop container
echo   controller restart    - restart container
echo.

