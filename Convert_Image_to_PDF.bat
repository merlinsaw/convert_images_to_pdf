@echo off
setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

REM Get current date in YYYY_MM_DD format (no trailing underscore)
for /f "delims=" %%a in ('powershell -command "Get-Date -Format 'yyyy_MM_dd'"') do set "DATESTAMP=%%a"

cls
color 09
echo ================================
echo      IMAGE TO PDF CONVERTER     
echo ================================
echo.

REM Set color for info messages (Cyan)
color 0b

echo Script directory: %SCRIPT_DIR%

REM Check if any files were provided
if [%1]==[] (
    REM Set color for errors (Red)
    color 0c
    echo [ERROR] No files were provided.
    echo.
    echo Drag and drop image files onto this batch file to convert them to PDF.
    echo - Single image: Creates a single-page PDF
    echo - Multiple images: Creates a multi-page PDF with pages in selection order
    pause
    exit /b 1
)

REM Check if multiple files were provided
set FILE_COUNT=0
for %%f in (%*) do set /a FILE_COUNT+=1

REM Info messages in cyan
color 0b
echo [INFO] Number of files: %FILE_COUNT%

REM Create a temporary file to store the list of image files
set "TEMP_FILE=%TEMP%\image_list_%RANDOM%.txt"
echo [INFO] Creating temporary file for image list: %TEMP_FILE%

REM Write image paths to the temporary file
for %%f in (%*) do (
    echo %%~f>> "%TEMP_FILE%"
)

REM User input in yellow
color 0e
echo.
echo [INPUT] Enter a name for the output PDF file (without extension):
echo Press Enter to use default name
set /p "CUSTOM_FILENAME="

set "PDF_PATH="
set "OUTPUT_NAME="

REM Get base name from first file for default filename
for %%f in (%1) do set "BASE_NAME=%%~nf"

if not "!CUSTOM_FILENAME!"=="" (
    REM Trim trailing spaces
    for /l %%a in (1,1,100) do if "!CUSTOM_FILENAME:~-1!"==" " set "CUSTOM_FILENAME=!CUSTOM_FILENAME:~0,-1!"
    
    REM Replace remaining spaces with underscores
    set "CUSTOM_FILENAME=!CUSTOM_FILENAME: =_!"
    
    REM Add date prefix to custom filename
    set "OUTPUT_NAME=%DATESTAMP%_!CUSTOM_FILENAME!"
) else (
    if %FILE_COUNT% GTR 1 (
        set "OUTPUT_NAME=%DATESTAMP%_!BASE_NAME!_multipage"
    ) else (
        set "OUTPUT_NAME=%DATESTAMP%_!BASE_NAME!"
    )
)

REM Set the output name option for the Python script
set "FILENAME_OPTION=--output-name "!OUTPUT_NAME!""

color 0b
echo [INFO] Using filename: !OUTPUT_NAME!.pdf

if %FILE_COUNT% GTR 1 (
    color 0b
    echo [INFO] Creating a multi-page PDF from %FILE_COUNT% images...
    
    REM Build the command with all image paths
    set "CMD=python "%SCRIPT_DIR%image_to_pdf_converter.py" --multi"
    
    REM Add each file to the command in correct order (first selected = first page)
    for %%f in (%*) do (
        echo [INFO] Adding page: "%%~f"
        set "CMD=!CMD! "%%~f""
    )
    
    REM Add the output directory and filename
    set "CMD=!CMD! --output-dir "%SCRIPT_DIR:~0,-1%" !FILENAME_OPTION!"
    
    echo [INFO] Command to execute: !CMD!
    
    REM Execute the command
    !CMD!
    
    if !ERRORLEVEL! NEQ 0 (
        color 0c
        echo [ERROR] Command failed with error code !ERRORLEVEL!
        del "%TEMP_FILE%" 2>nul
        pause
        exit /b 1
    )
    
    REM Set the PDF path for later use
    set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!OUTPUT_NAME!.pdf"
) else (
    color 0b
    echo [INFO] Processing single image: %1
    
    REM Execute the Python script with the date-prefixed filename
    python "%SCRIPT_DIR%image_to_pdf_converter.py" "%~1" --output-dir "%SCRIPT_DIR:~0,-1%" !FILENAME_OPTION!
    
    if !ERRORLEVEL! NEQ 0 (
        color 0c
        echo [ERROR] Command failed with error code !ERRORLEVEL!
        del "%TEMP_FILE%" 2>nul
        pause
        exit /b 1
    )
    
    REM Set the PDF path for later use
    set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!OUTPUT_NAME!.pdf"
)

echo.
REM Success messages in green
color 0a
echo [SUCCESS] All operations completed.

REM Clean up temporary file before exit
del "%TEMP_FILE%" 2>nul

REM Check if the PDF file exists and try to open it
if exist "!PDF_PATH!" (
    color 0a
    echo [SUCCESS] PDF file found at: !PDF_PATH!
    
    color 0b
    echo [INFO] Opening PDF file...
    
    REM Try to open the PDF
    start "" "!PDF_PATH!"
    
    REM Wait for the PDF to open
    timeout /t 4 /nobreak > nul
    
    echo.
    color 0e
    echo [INPUT] Would you like to delete the original image files? (Y/N)
    echo Please check the PDF before deciding.
    set /p "DELETE_CHOICE=Your choice (Y/N, default=N): "
    
    if /i "!DELETE_CHOICE!"=="Y" (
        echo.
        color 0b
        echo [INFO] Deleting original image files...
        set "DELETE_ERROR="
        for %%f in (%*) do (
            echo [INFO] Deleting: "%%~f"
            del "%%~f" 2>nul || set "DELETE_ERROR=1"
        )
        if defined DELETE_ERROR (
            color 0c
            echo [ERROR] Some files could not be deleted. They may be in use.
        ) else (
            color 0a
            echo [SUCCESS] Original image files have been deleted.
        )
    ) else (
        echo.
        color 0b
        echo [INFO] Original image files have been kept.
    )
    
    echo.
    color 0a
    echo [SUCCESS] Your PDF is ready at: !PDF_PATH!
    echo.
    color 0b
    echo [INFO] Press any key to exit...
    pause > nul
    exit /b 0
) else (
    color 0c
    echo [ERROR] Could not create PDF file at expected location: !PDF_PATH!
    echo.
    echo Press any key to exit...
    pause > nul
    exit /b 1
)
