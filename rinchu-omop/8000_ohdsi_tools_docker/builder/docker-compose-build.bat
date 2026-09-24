@echo off
REM Atlas+WebAPI+RStudio用docker-composeバッチ（引数対応）
cd /d %~dp0

REM 環境変数 DOCKER_BUILDKIT を有効化
set DOCKER_BUILDKIT=1

if "%*"=="" (
	echo === build Atlas + WebAPI + RStudio コンテナ起動 ===
	docker-compose -f docker-compose-build.yml up -d
) else (
	echo === docker-compose -f docker-compose-build.yml %* ===
	docker-compose -f docker-compose-build.yml %*
)

echo.
echo サービスの状態確認: docker-compose -f docker-compose-build.yml ps
echo 停止する場合:        docker-compose -f docker-compose-build.yml down
echo.

