@echo off
REM === 1. Get versions from .env ===
for /f "usebackq tokens=1,2 delims==" %%a in ("../.env") do (
    if "%%a"=="COMPOSE_PROJECT_NAME" set PROJECT=%%b
    if "%%a"=="WEBAPI_VERSION" set WEBAPI_VERSION=%%b
    if "%%a"=="ATLAS_VERSION" set ATLAS_VERSION=%%b
    if "%%a"=="HADES_VERSION" set HADES_VERSION=%%b
    if "%%a"=="OMOPDB_VERSION" set OMOPDB_VERSION=%%b
)

REM === 2. Save each image ===
echo Saving %PROJECT%/webapi:%WEBAPI_VERSION% ...
docker save -o %PROJECT%_webapi_%WEBAPI_VERSION%.tar %PROJECT%/webapi:%WEBAPI_VERSION%

echo Saving %PROJECT%/atlas:%ATLAS_VERSION% ...
docker save -o %PROJECT%_atlas_%ATLAS_VERSION%.tar %PROJECT%/atlas:%ATLAS_VERSION%

echo Saving %PROJECT%/hades:%HADES_VERSION% ...
docker save -o %PROJECT%_hades_%HADES_VERSION%.tar %PROJECT%/hades:%HADES_VERSION%

echo Saving %PROJECT%/omopdb:%OMOPDB_VERSION% ...
docker save -o %PROJECT%_omopdb_%OMOPDB_VERSION%.tar %PROJECT%/omopdb:%OMOPDB_VERSION%

echo Saving dpage/pgadmin4:latest ...
docker save -o dpage_pgadmin4_latest.tar dpage/pgadmin4:latest

echo Done.
