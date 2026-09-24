@echo off
chcp 65001 >nul

REM Move to the directory where this bat file is located
REM This ensures relative paths work correctly when launched from task scheduler etc.
cd /d "%~dp0"

REM ====================================================================
REM OMOP ETL All-in-One Execution Batch File
REM ====================================================================
REM This batch file executes the following steps in sequence:
REM 1. Database environment setup (1000_database_setup)
REM 2. ETL setup (2000_etl_setup)
REM 3. Source data load (3000_load_source)
REM 4. Vocabulary load (4000_load_vocab)
REM 5. ETL execution (5000_etl_execute)
REM ====================================================================

REM Common settings path
SET SETPATH=0000_setting

REM Initialize execution result variable (0=success, 1=error)
SET EXECUTION_RESULT=0

REM Load environment variables
SET ENVPATH=%SETPATH%\_env.bat
CALL %SETPATH%\LoadEnv.bat "%ENVPATH%"
if errorlevel 1 exit /b 1

cls

echo.
echo ====================================================================
echo   OMOP ETL Execution Manager
echo ====================================================================
echo.
echo The following steps will be executed in order:
echo   1. Create schema
echo   2. Create source tables
echo   3. Create OMOP tables
echo   4. ETL setup
echo   5. Load source data
echo   6. Load ATHENA vocabulary
echo   7. Auto-generate mapping tables
echo   8. Import mapping tables
echo   9. Import initial data
echo  10. ETL execution [staging]
echo  11. Staging table Mapping
echo  12. Mapping checklist
echo  13. ETL execution [final]
echo  14. Result checklist
echo  15. Production deployment
echo  16. Statistics Analyze
echo.
echo ====================================================================
echo   Pre-execution checklist:
echo   - _env.bat is properly configured
echo   - PostgreSQL is running
echo   - Required CSV files are placed
echo     * 3000_load_source/dat/: source data CSV
echo     * 3000_load_source/mst/: master CSV
echo     * 4000_load_vocab/athena/: ATHENA vocabulary CSV
echo ====================================================================
echo.

REM ====================================================================
REM Argument processing
REM ====================================================================
REM Check for --skipathena flag (can be used with other parameters)
set SKIP_ATHENA=0
if "%3"=="--skipathena" set SKIP_ATHENA=1
if "%4"=="--skipathena" set SKIP_ATHENA=1

REM Check for --silent flag (background/scheduled execution: skips confirmation and final PAUSE)
set SILENT_MODE=0
if "%3"=="--silent" set SILENT_MODE=1
if "%4"=="--silent" set SILENT_MODE=1

REM Check if main parameter is provided
if "%1"=="" (
    REM No arguments - Interactive mode
    goto :INTERACTIVE_MODE
) else if "%1"=="--start" (
    REM --start mode: %2 is the starting step number
    if "%2"=="" (
        REM No step number provided - Interactive mode
        goto :INTERACTIVE_MODE
    )
    SET STEP_START=%2
    goto :START_MODE
) else if "%1"=="--select" (
    REM --select mode: %2 is optional comma-separated list of steps
    if "%2"=="" (
        REM No arguments - User input mode
        goto :SELECT_INPUT_MODE
    )
    SET SELECTED_STEPS=%2
    goto :SELECT_MODE
) else if "%1"=="--skipathena" (
    REM --skipathena only - defaults to interactive mode
    set SKIP_ATHENA=1
    goto :INTERACTIVE_MODE
) else if "%1"=="--silent" (
    echo [ERROR] --silent requires --start or --select option.
    echo.
    echo Usage:
    echo   execute_all_process.bat --start ^<step_number^> --silent [--skipathena]
    echo   execute_all_process.bat --select "^<steps^>" --silent [--skipathena]
    exit /b 1
) else (
    echo [ERROR] Unknown argument: %1
    echo.
    echo Usage:
    echo   execute_all_process.bat
    echo   execute_all_process.bat --start ^<step_number^> [--skipathena] [--silent]
    echo   execute_all_process.bat --select [--skipathena] [--silent]
    echo   execute_all_process.bat --select "^<step1^>:^<step2^>..." [--skipathena] [--silent]
    echo   execute_all_process.bat --skipathena
    exit /b 1
)

REM ====================================================================
REM INTERACTIVE MODE - User inputs starting step number
REM ====================================================================
:INTERACTIVE_MODE
REM Clear SELECTED_STEPS to prevent SELECT_MODE checks
set SELECTED_STEPS=
echo ====================================================================
echo   Which step do you want to start from?
echo ====================================================================
echo.

:STEP_INPUT_LOOP
set /p "STEP_START=Enter the starting step number (1-16, or X to cancel): "
if /I "%STEP_START%"=="X" (
    echo [INFO] Batch execution cancelled by user.
    exit /b 0
)
if "%STEP_START%"=="" (
    echo [ERROR] No input. Please enter a number between 1 and 16, or X to cancel.
    goto :STEP_INPUT_LOOP
)
set /a CHECK_STEP=%STEP_START%+0 2>nul
if "%CHECK_STEP%"=="0" if not "%STEP_START%"=="0" (
    echo [ERROR] Invalid input. Please enter a number between 1 and 16.
    goto :STEP_INPUT_LOOP
)
if %STEP_START% LSS 1 (
    echo [ERROR] Invalid input. Please enter a number between 1 and 16.
    goto :STEP_INPUT_LOOP
)
if %STEP_START% GTR 16 (
    echo [ERROR] Invalid input. Please enter a number between 1 and 16.
    goto :STEP_INPUT_LOOP
)

echo.
echo Starting from step %STEP_START%
echo.

REM Execution confirmation
CALL %SETPATH%\ConfirmExecution.bat "OMOP ETL All Steps Execution" "%ENVPATH%"
if errorlevel 1 exit /b 0

REM Set batch execution mode
SET AUTO_EXEC=1

echo.
echo ====================================================================
echo   Starting batch execution
echo ====================================================================
echo.

REM Record start time
echo [%date% %time%] Batch execution started

REM Jump to selected step
GOTO :STEP%STEP_START%

REM ====================================================================
REM START MODE - Execute from specified step number
REM ====================================================================
:START_MODE
REM Clear SELECTED_STEPS to prevent SELECT_MODE checks
set SELECTED_STEPS=
REM Validate step number
set /a CHECK_STEP=%STEP_START%+0 2>nul
if "%CHECK_STEP%"=="0" if not "%STEP_START%"=="0" (
    echo [ERROR] Invalid step number: %STEP_START%
    exit /b 1
)
if %STEP_START% LSS 1 (
    echo [ERROR] Step number must be between 1 and 16. Got: %STEP_START%
    exit /b 1
)
if %STEP_START% GTR 16 (
    echo [ERROR] Step number must be between 1 and 16. Got: %STEP_START%
    exit /b 1
)

echo.
echo Starting from step %STEP_START%
echo.

if not "%SILENT_MODE%"=="1" (
    CALL %SETPATH%\ConfirmExecution.bat "OMOP ETL All Steps Execution" "%ENVPATH%"
    if errorlevel 1 exit /b 0
)

SET AUTO_EXEC=1

echo.
echo ====================================================================
echo   Starting batch execution
echo ====================================================================
echo.

echo [%date% %time%] Batch execution started

GOTO :STEP%STEP_START%

REM ====================================================================
REM SELECT INPUT MODE - User inputs step numbers for selection
REM ====================================================================
:SELECT_INPUT_MODE
echo ====================================================================
echo   Which steps do you want to execute?
echo ====================================================================
echo.

:SELECT_STEP_INPUT_LOOP
set /p "SELECTED_STEPS=Enter step numbers (e.g., 5 or 5,6,8,11), or X to cancel: "
if /I "%SELECTED_STEPS%"=="X" (
    echo [INFO] Batch execution cancelled by user.
    exit /b 0
)
if "%SELECTED_STEPS%"=="" (
    echo [ERROR] No input. Please enter step numbers.
    goto :SELECT_STEP_INPUT_LOOP
)

REM Proceed to SELECT_MODE to process the entered steps
goto :SELECT_MODE

REM ====================================================================
REM SELECT MODE - Execute only selected steps
REM ====================================================================
:SELECT_MODE
setlocal enabledelayedexpansion

REM Set flag to indicate SELECT_MODE
SET SELECT_MODE_FLAG=1

REM Remove surrounding quotes from SELECTED_STEPS if present
SET SELECTED_STEPS=%SELECTED_STEPS:"=%

REM Convert colon delimiters to comma and add commas at beginning/end
SET SELECTED_STEPS=,!SELECTED_STEPS::=,!,

echo.
echo ====================================================================
echo  Steps to execute:

REM Initialize all flags to 0
for /L %%N in (1,1,16) do set STEP%%NFLG=0

REM Check and set flag for each step
for /L %%N in (1,1,16) do (
    set TEMP=!SELECTED_STEPS:,%%N,=!
    if not "!TEMP!"=="!SELECTED_STEPS!" (
        set STEP%%NFLG=1
        call :DISPLAY_STEP_NAME %%N
    )
)

echo ====================================================================
echo.

if not "%SILENT_MODE%"=="1" (
    CALL %SETPATH%\ConfirmExecution.bat "OMOP ETL Selected Steps Execution" "%ENVPATH%"
    if errorlevel 1 exit /b 0
)

SET AUTO_EXEC=1

echo.
echo ====================================================================
echo   Starting batch execution
echo ====================================================================
echo.

echo [%date% %time%] Batch execution started
echo.

REM Execute from STEP1 - each step will check if it's in the selected list
GOTO :STEP1

REM ====================================================================
REM Subroutine to display step name
REM =====================================================================
:DISPLAY_STEP_NAME
set SNUM=%1
set FOUND=0

if "!SNUM!"=="1" (
    echo   1. Create schema
    set FOUND=1
)
if "!SNUM!"=="2" (
    echo   2. Create source tables
    set FOUND=1
)
if "!SNUM!"=="3" (
    echo   3. Create OMOP tables
    set FOUND=1
)
if "!SNUM!"=="4" (
    echo   4. ETL setup
    set FOUND=1
)
if "!SNUM!"=="5" (
    echo   5. Load source data
    set FOUND=1
)
if "!SNUM!"=="6" (
    echo   6. Load ATHENA vocabulary
    set FOUND=1
)
if "!SNUM!"=="7" (
    echo   7. Auto-generate mapping tables
    set FOUND=1
)
if "!SNUM!"=="8" (
    echo   8. Import mapping tables
    set FOUND=1
)
if "!SNUM!"=="9" (
    echo   9. Import initial data
    set FOUND=1
)
if "!SNUM!"=="10" (
    echo   10. ETL execution [staging]
    set FOUND=1
)
if "!SNUM!"=="11" (
    echo   11. Staging table Mapping 
    set FOUND=1
)
if "!SNUM!"=="12" (
    echo   12. Mapping checklist
    set FOUND=1
)
if "!SNUM!"=="13" (
    echo   13. ETL execution [final]
    set FOUND=1
)
if "!SNUM!"=="14" (
    echo   14. Result checklist
    set FOUND=1
)
if "!SNUM!"=="15" (
    echo   15. Production deployment
    set FOUND=1
)
if "!SNUM!"=="16" (
    echo   16. Statistics Analyze
    set FOUND=1
)

if !FOUND! equ 0 (
    echo   [ERROR] Invalid step number: !SNUM!
)
exit /b 0

:STEP1
REM ====================================================================
REM 1. Schema creation
REM =====================================================================
REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP1FLG!"=="0" goto :STEP2
echo.
echo ====================================================================
echo [1/16] Create schema
echo ====================================================================
echo [STEP1] Started
cd 1000_database_setup\02_schema
call create_schema.bat
if errorlevel 1 (
    echo [ERROR] Schema creation failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP1] Completed

:STEP2
REM ====================================================================
REM 2. Source table creation
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP2FLG!"=="0" goto :STEP3
echo.
echo ====================================================================
echo [2/16] Create source tables
echo ====================================================================
echo [STEP2] Started
cd 1000_database_setup\03_table_source
call create_table.bat
if errorlevel 1 (
    echo [ERROR] Source table creation failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP2] Completed

:STEP3
REM ====================================================================
REM 3. OMOP table creation
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP3FLG!"=="0" goto :STEP4
echo.
echo ====================================================================
echo [3/16] Create OMOP tables
echo ====================================================================
echo [STEP3] Started
cd 1000_database_setup\04_table_omop
call create_table.bat
if errorlevel 1 (
    echo [ERROR] OMOP table creation failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP3] Completed

:STEP4
REM ====================================================================
REM 4. ETL setup
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP4FLG!"=="0" goto :STEP5
echo.
echo ====================================================================
echo [4/16] ETL setup
echo ====================================================================
echo [STEP4] Started
cd 2000_etl_setup\bat
call drop_etl.bat
if errorlevel 1 (
    echo [ERROR] ETL VIEW deletion failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
call create_etl.bat
if errorlevel 1 (
    echo [ERROR] ETL setup failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP4] Completed

:STEP5

REM ====================================================================
REM 5. Source data load
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP5FLG!"=="0" goto :STEP6
echo.
echo ====================================================================
echo [5/16] Load source data
echo ====================================================================
echo [STEP5] Started
cd 3000_load_source\bat
call 01_import_source.BAT
if errorlevel 1 (
    echo [ERROR] Source data load failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)

call 02_import_master.BAT
if errorlevel 1 (
    echo [ERROR] Master data load failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP5] Completed

:STEP6
REM ====================================================================
REM 6. ATHENA Vocabulary load
REM ====================================================================

REM If in SELECT_MODE but step NOT selected (flag=0), skip to next step
if "!SELECT_MODE_FLAG!"=="1" if "!STEP6FLG!"=="0" goto :STEP7

REM Skip STEP 6 if --skipathena flag is set
if "%SKIP_ATHENA%"=="1" (
    echo.
    echo ====================================================================
    echo [6/16] Load ATHENA vocabulary [SKIPPED]
    echo ====================================================================
    echo [STEP6] Skipped [--skipathena flag is set]
    goto :STEP6_SKIP
)

echo.
echo ====================================================================
echo [6/16] Load ATHENA vocabulary
echo ====================================================================
echo [STEP6] Started
cd 4000_load_vocab\bat
call 01_import_athena.BAT
if errorlevel 1 (
    echo [ERROR] ATHENA Vocabulary load failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP6] Completed

:STEP6_SKIP

:STEP7

REM ====================================================================
REM 7. Auto-generation of mapping tables
REM ====================================================================

REM If in SELECT_MODE but step NOT selected (flag=0), skip to next step
if "!SELECT_MODE_FLAG!"=="1" if "!STEP7FLG!"=="0" goto :STEP8

echo.
echo ====================================================================
echo [7/16] Auto-generate mapping tables
echo ====================================================================
echo [STEP7] Started
cd 4000_load_vocab\bat
call 02_generate_automapping.BAT
if errorlevel 1 (
    echo [ERROR] Auto-generation of mapping tables failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP7] Completed

:STEP8

REM ====================================================================
REM 8. Mapping table import
REM ====================================================================

REM If in SELECT_MODE but step NOT selected (flag=0), skip to next step
if "!SELECT_MODE_FLAG!"=="1" if "!STEP8FLG!"=="0" goto :STEP9
echo.
echo ====================================================================
echo [8/16] Import mapping tables
echo ====================================================================
echo [STEP8] Started
cd 4000_load_vocab\bat
call 03_import_stcm.BAT
if errorlevel 1 (
    echo [ERROR] Mapping table import failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP8] Completed

:STEP9
REM ====================================================================
REM 9. Initial data import
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP9FLG!"=="0" goto :STEP10
echo.
echo ====================================================================
echo [9/16] Import initial data
echo ====================================================================
echo [STEP9] Started
cd 4000_load_vocab\bat
call 04_import_initdata.BAT
if errorlevel 1 (
    echo [ERROR] Initial data import failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP9] Completed


:STEP10
REM ====================================================================
REM 10. ETL execution (Staging)
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP10FLG!"=="0" goto :STEP11
echo.
echo ====================================================================
echo [10/16] ETL execution [staging]
echo ====================================================================
echo [STEP10] Started
cd 5000_etl_execute\bat
call 01_etl_execution_to_stem.bat
if errorlevel 1 (
    echo [ERROR] ETL execution [Staging] failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP10] Completed

:STEP11
REM ====================================================================
REM 11. Staging table Mapping
REM ====================================================================

REM If in SELECT_MODE but step NOT selected (flag=0), skip to next step
if "!SELECT_MODE_FLAG!"=="1" if "!STEP11FLG!"=="0" goto :STEP12

echo.
echo ====================================================================
echo [11/16] Staging table Mapping
echo ====================================================================
echo [STEP11] Started
cd 5000_etl_execute\bat
call 02_etl_execution_stem_mapped.bat
if errorlevel 1 (
    echo [ERROR] Staging table Mapping failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP11] Completed

:STEP12
REM ====================================================================
REM 12. Mapping checklist
REM ====================================================================

REM If in SELECT_MODE but step NOT selected (flag=0), skip to next step
if "!SELECT_MODE_FLAG!"=="1" if "!STEP12FLG!"=="0" goto :STEP13

echo.
echo ====================================================================
echo [12/16] Mapping checklist
echo ====================================================================
echo [STEP12] Started
cd 5000_etl_execute\bat
call 03_mapping_checklist.bat
if errorlevel 1 (
    echo [ERROR] Mapping checklist failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP12] Completed

:STEP13
REM ====================================================================
REM 13. ETL execution [Final]
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP13FLG!"=="0" goto :STEP14
echo.
echo ====================================================================
echo [13/16] ETL execution [Final]
echo ====================================================================
echo [STEP13] Started
cd 5000_etl_execute\bat

call 04_etl_execution_to_final.bat
if errorlevel 1 (
    echo [ERROR] ETL execution [Final] failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP13] Completed

:STEP14
REM ====================================================================
REM 14. Result checklist
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP14FLG!"=="0" goto :STEP15
echo.
echo ====================================================================
echo [14/16] Result checklist
echo ====================================================================
echo [STEP14] Started
cd 5000_etl_execute\bat
call 05_result_checklist.bat
if errorlevel 1 (
    echo [ERROR] Result checklist failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP14] Completed

:STEP15
REM ====================================================================
REM 15. Production deployment
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP15FLG!"=="0" goto :STEP16
echo.
echo ====================================================================
echo [15/16] Production deployment
echo ====================================================================
echo [STEP15] Started
cd 5000_etl_execute\bat

REM Execute with --data option if --skipathena flag is set
if "%SKIP_ATHENA%"=="1" (
    call 06_production_deployment.bat --data
) else (
    call 06_production_deployment.bat
)

if errorlevel 1 (
    echo [ERROR] Production deployment failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP15] Completed

:STEP16
REM ====================================================================
REM 16. Statistics Analyze
REM ====================================================================

REM If in SELECT_MODE, check if this step is selected
if "!SELECT_MODE_FLAG!"=="1" if "!STEP16FLG!"=="0" goto :END
echo.
echo ====================================================================
echo [16/16] Statistics Analyze
echo ====================================================================
echo [STEP16] Started
cd 6000_statistics\bat
call 01_achilles_concept_hierarchy.bat
if errorlevel 1 (
    echo [ERROR] Achilles concept hierarchy failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
call 02_achilles_statistics.bat
if errorlevel 1 (
    echo [ERROR] Achilles statistics failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
call 03_achilles_concept_count.bat
if errorlevel 1 (
    echo [ERROR] Achilles concept count failed.
    SET EXECUTION_RESULT=1
    cd ..\..
    if not "%AUTO_EXEC%"=="1" pause
    goto :END
)
cd ..\..
echo [STEP16] Completed

:END

REM Record end time
echo.
if "%EXECUTION_RESULT%"=="1" (
    echo ====================================================================
    echo   Batch execution ended with errors!
    echo ====================================================================
    echo [%date% %time%] Batch execution completed with errors
    echo.
    echo Next steps:
    echo   - Check the log file for the failed step
    echo   - Fix the issue and re-run from the failed step
    echo.
    echo ====================================================================
    echo [❌] Batch execution ended with errors.
    if not "%SILENT_MODE%"=="1" pause
    exit /b 1
) else (
    echo ====================================================================
    echo   Batch execution completed successfully!
    echo ====================================================================
    echo [%date% %time%] Batch execution completed
    echo.
    echo Next steps:
    echo   - Please check the log file
    echo   - Check the result checklist if needed
    echo.
    echo ====================================================================
    echo [✅] Batch execution completed successfully.
    if not "%SILENT_MODE%"=="1" pause
    exit /b 0
)


