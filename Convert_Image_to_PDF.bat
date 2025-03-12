@echo off
setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

echo ================================
echo      IMAGE TO PDF CONVERTER     
echo ================================

echo Script directory: %SCRIPT_DIR%

REM Check if any files were provided
if [%1]==[] (
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
echo [INFO] Number of files: %FILE_COUNT%

REM Create a temporary file to store the list of image files
set "TEMP_FILE=%TEMP%\image_list_%RANDOM%.txt"
echo [INFO] Creating temporary file for image list: %TEMP_FILE%

REM Write image paths to the temporary file
for %%f in (%*) do (
  echo %%~f>> "%TEMP_FILE%"
)

REM Prompt user for custom filename
echo.
echo [INPUT] Enter a name for the output PDF file (without extension):
echo Press Enter to use default name
set /p "CUSTOM_FILENAME="

set "PDF_PATH="
set "FILENAME_OPTION="

if not "!CUSTOM_FILENAME!"=="" (
  REM Trim trailing spaces
  for /l %%a in (1,1,100) do if "!CUSTOM_FILENAME:~-1!"==" " set "CUSTOM_FILENAME=!CUSTOM_FILENAME:~0,-1!"
  
  REM Replace remaining spaces with underscores
  set "CUSTOM_FILENAME=!CUSTOM_FILENAME: =_!"
  
  set "FILENAME_OPTION=--output-name "!CUSTOM_FILENAME!""
  echo [INFO] Using custom filename: !CUSTOM_FILENAME!.pdf
) else (
  echo [INFO] Using default filename
)

if %FILE_COUNT% GTR 1 (
  echo [INFO] Creating a multi-page PDF from %FILE_COUNT% images...
  
  REM Build the command with all image paths
  set "CMD=python "%SCRIPT_DIR%image_to_pdf_converter.py" --multi"
  
  REM Add each file to the command in correct order (first selected = first page)
  for %%f in (%*) do (
    echo [PAGE] Adding page: "%%~f"
    set "CMD=!CMD! "%%~f""
  )
  
  REM Add the output directory and custom filename if provided
  set "CMD=!CMD! --output-dir "%SCRIPT_DIR:~0,-1%" !FILENAME_OPTION!"
  
  echo [CMD] Command to execute: !CMD!
  
  REM Execute the command
  !CMD!
  
  if !ERRORLEVEL! NEQ 0 (
    echo [ERROR] Command failed with error code !ERRORLEVEL!
    del "%TEMP_FILE%" 2>nul
    pause
    exit /b 1
  )
  
  REM Determine the PDF path based on the first image and custom filename
  if defined CUSTOM_FILENAME (
    set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!CUSTOM_FILENAME!.pdf"
  ) else (
    for %%f in (%1) do set "BASE_NAME=%%~nf"
    set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!BASE_NAME!_multipage.pdf"
  )
) else (
  REM Single file mode
  echo [INFO] Processing single image: %1
  
  REM Execute the Python script
  python "%SCRIPT_DIR%image_to_pdf_converter.py" "%~1" --output-dir "%SCRIPT_DIR:~0,-1%" !FILENAME_OPTION!
  
  if !ERRORLEVEL! NEQ 0 (
    echo [ERROR] Command failed with error code !ERRORLEVEL!
    del "%TEMP_FILE%" 2>nul
    pause
    exit /b 1
  )
  
  REM Determine the PDF path based on the image and custom filename
  if defined CUSTOM_FILENAME (
    set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!CUSTOM_FILENAME!.pdf"
  ) else (
    for %%f in (%1) do set "BASE_NAME=%%~nf"
    set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!BASE_NAME!.pdf"
  )
)

echo.
echo [SUCCESS] All operations completed.

REM Clean up temporary file before exit
del "%TEMP_FILE%" 2>nul

REM Check if the PDF file exists and try to open it
if exist "!PDF_PATH!" (
  echo [CHECK] PDF file found at: !PDF_PATH!
  echo Opening PDF file...
  
  REM Try to open the PDF
  start "" "!PDF_PATH!"
  
  REM Wait for the PDF to open
  timeout /t 4 /nobreak > nul
  
  echo.
  echo Would you like to delete the original image files? (Y/N)
  echo Please check the PDF before deciding.
  set /p "DELETE_CHOICE=Your choice (Y/N, default=N): "
  
  if /i "!DELETE_CHOICE!"=="Y" (
    echo.
    echo Deleting original image files...
    set "DELETE_ERROR="
    for %%f in (%*) do (
      echo Deleting: "%%~f"
      del "%%~f" 2>nul || set "DELETE_ERROR=1"
    )
    if defined DELETE_ERROR (
      echo Some files could not be deleted. They may be in use.
    ) else (
      echo Original image files have been deleted.
    )
  ) else (
    echo.
    echo Original image files have been kept.
  )
  
  echo.
  echo Your PDF is ready at: !PDF_PATH!
  echo.
  echo Press any key to exit...
  pause > nul
  exit /b 0
) else (
  echo.
  echo Error: Could not create PDF file at expected location: !PDF_PATH!
  echo.
  echo Press any key to exit...
  pause > nul
  exit /b 1
)
