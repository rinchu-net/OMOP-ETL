@echo off
setlocal enabledelayedexpansion

REM Get backup directory (current script directory)
set BACKUP_DIR=%~dp0volumes

REM Create volumes folder if it doesn't exist
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM === 1. Volume name list ===
set VOLUMES=iqvia_omopdbdata iqvia_pgadmindata

REM === 2. Save each volume ===
for %%V in (%VOLUMES%) do (
    echo Saving volume %%V ...
    docker run --rm -v "%%V:/volume" -v "%BACKUP_DIR%:/backup" busybox tar czf /backup/%%V.tar.gz -C /volume .
)

echo Done.
pause
