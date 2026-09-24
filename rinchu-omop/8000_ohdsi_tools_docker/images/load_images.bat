@echo off
REM === 1. Get versions from .env ===
for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
    if "%%a"=="COMPOSE_PROJECT_NAME" set PROJECT=%%b
    if "%%a"=="WEBAPI_VERSION" set WEBAPI_VERSION=%%b
    if "%%a"=="ATLAS_VERSION" set ATLAS_VERSION=%%b
    if "%%a"=="HADES_VERSION" set HADES_VERSION=%%b
    if "%%a"=="OMOPDB_VERSION" set OMOPDB_VERSION=%%b
)

REM === 2. Load each image ===
echo Loading %PROJECT%_webapi_%WEBAPI_VERSION%.tar ...
docker load -i %PROJECT%_webapi_%WEBAPI_VERSION%.tar

echo Loading %PROJECT%_atlas_%ATLAS_VERSION%.tar ...
docker load -i %PROJECT%_atlas_%ATLAS_VERSION%.tar

echo Loading %PROJECT%_hades_%HADES_VERSION%.tar ...
docker load -i %PROJECT%_hades_%HADES_VERSION%.tar

echo Loading %PROJECT%_omopdb_%OMOPDB_VERSION%.tar ...
docker load -i %PROJECT%_omopdb_%OMOPDB_VERSION%.tar

echo Loading dpage_pgadmin4_latest.tar ...
docker load -i dpage_pgadmin4_latest.tar

echo 完了しました。
