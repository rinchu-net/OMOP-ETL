@echo off

REM Clone OHDSI GitHub repositories
git clone https://github.com/OHDSI/WebAPI.git
git clone https://github.com/OHDSI/Atlas.git

REM Clone rocker-org GitHub repository for versioned R Docker images
git clone https://github.com/rocker-org/rocker-versioned2.git
pause