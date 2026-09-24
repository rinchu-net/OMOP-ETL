@echo off

if not exist WebAPI (
    echo Error: WebAPI folder not found
    goto :error
)
if not exist Atlas (
    echo Error: Atlas folder not found
    goto :error
)
if not exist rocker-versioned2 (
    echo Error: rocker-versioned2 folder not found
    goto :error
)

REM Pull updates from OHDSI GitHub repositories
echo.
echo Pulling WebAPI...
cd WebAPI
git pull
cd ..

echo.
echo Pulling Atlas...
cd Atlas
git pull
cd ..

REM Pull updates from rocker-org GitHub repository for versioned R Docker images
echo.
echo Pulling rocker-versioned2...
cd rocker-versioned2
git pull
cd ..

echo.
echo All repositories pulled successfully.
pause
goto :end

:error
echo.
echo Error: Please run git_clone.bat first to clone the repositories.
pause
exit /b 1

:end
