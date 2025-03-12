@echo off
setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Check if any files were provided
if [%1]==[] (
    REM No files provided, just run the main script
    call "%SCRIPT_DIR%Droplet_to_Convert_Image_to_PDF.bat"
) else (
    REM Files were provided, pass them to the main script
    set "PARAMS="
    
    REM Loop through all parameters and add them to the PARAMS variable
    for %%i in (%*) do (
        set "PARAMS=!PARAMS! "%%~i""
    )
    
    REM Call the main script with the parameters
    call "%SCRIPT_DIR%Droplet_to_Convert_Image_to_PDF.bat" !PARAMS!
) 