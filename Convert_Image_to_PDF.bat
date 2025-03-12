@echo off
setlocal enabledelayedexpansion

REM Enable virtual terminal processing for ANSI colors
for /f "tokens=4-5 delims=. " %%i in ('ver') do set VERSION=%%i.%%j
if "%version%" == "10.0" (
  reg add HKCU\Console /v VirtualTerminalLevel /t REG_DWORD /d 1 /f >nul 2>&1
)

REM Define color codes
set "GREEN=[32m"
set "BRIGHT_GREEN=[92m"
set "YELLOW=[33m"
set "BRIGHT_YELLOW=[93m"
set "CYAN=[36m"
set "BRIGHT_CYAN=[96m"
set "RED=[31m"
set "BRIGHT_RED=[91m"
set "MAGENTA=[35m"
set "BOLD=[1m"
set "RESET=[0m"

echo %GREEN%%BOLD%=================================%RESET%
echo %GREEN%%BOLD%     IMAGE TO PDF CONVERTER     %RESET%
echo %GREEN%%BOLD%=================================%RESET%

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"
echo %CYAN%Script directory: %BOLD%%SCRIPT_DIR%%RESET%

REM Check if any files were provided
if [%1]==[] (
  echo %RED%%BOLD%[ERROR] No files were provided.%RESET%
  echo.
  echo %YELLOW%Drag and drop image files onto this batch file to convert them to PDF.%RESET%
  echo %CYAN%- Single image: Creates a single-page PDF%RESET%
  echo %CYAN%- Multiple images: Creates a multi-page PDF with pages in selection order%RESET%
  pause
  exit /b 1
)

REM Check if multiple files were provided
set FILE_COUNT=0
for %%f in (%*) do set /a FILE_COUNT+=1
echo %YELLOW%%BOLD%[INFO] Number of files: %FILE_COUNT%%RESET%

REM Prompt user for custom filename
echo.
echo %YELLOW%%BOLD%[INPUT] Enter a name for the output PDF file (without extension):%RESET%
echo %CYAN%Press Enter to use default name%RESET%
set /p "CUSTOM_FILENAME="

set "PDF_PATH="
set "FILENAME_OPTION="

if not "!CUSTOM_FILENAME!"=="" (
  REM Trim trailing spaces
  for /l %%a in (1,1,100) do if "!CUSTOM_FILENAME:~-1!"==" " set "CUSTOM_FILENAME=!CUSTOM_FILENAME:~0,-1!"
  
  REM Replace remaining spaces with underscores
  set "CUSTOM_FILENAME=!CUSTOM_FILENAME: =_!"
  
  set "FILENAME_OPTION=--output-name "!CUSTOM_FILENAME!""
  echo %GREEN%%BOLD%[INFO] Using custom filename: %CYAN%!CUSTOM_FILENAME!.pdf%RESET%
) else (
  echo %YELLOW%%BOLD%[INFO] Using default filename%RESET%
)

REM Create a temporary file to store the list of image files
set "TEMP_FILE=%TEMP%\image_list_%RANDOM%.txt"
echo %CYAN%[INFO] Creating temporary file for image list: %TEMP_FILE%%RESET%

REM Write image paths to the temporary file
for %%f in (%*) do (
  echo %%~f>> "%TEMP_FILE%"
)

if %FILE_COUNT% GTR 1 (
  echo %GREEN%%BOLD%[INFO] Creating a multi-page PDF from %FILE_COUNT% images...%RESET%
  
  REM Build the command with all image paths
  set "CMD=python "%SCRIPT_DIR%image_to_pdf_converter.py" --multi"
  
  REM Add each file to the command in correct order (first selected = first page)
  for %%f in (%*) do (
    echo %CYAN%[PAGE] Adding page: "%%~f"%RESET%
    set "CMD=!CMD! "%%~f""
  )
  
  REM Add the output directory and custom filename if provided
  set "CMD=!CMD! --output-dir "%SCRIPT_DIR:~0,-1%" !FILENAME_OPTION! --return-path"
  
  echo %MAGENTA%[CMD] Command to execute: !CMD!%RESET%
  
  REM Execute the command and capture the output path
  for /f "usebackq delims=" %%p in (`!CMD!`) do (
    set "PDF_PATH=%%p"
  )
  
  if !ERRORLEVEL! NEQ 0 (
    echo %RED%%BOLD%[ERROR] Command failed with error code !ERRORLEVEL!%RESET%
    del "%TEMP_FILE%" 2>nul
    pause
    exit /b 1
  )
  
  REM If no PDF_PATH was captured, determine it based on the first image and custom filename
  if "!PDF_PATH!"=="" (
    if defined CUSTOM_FILENAME (
      set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!CUSTOM_FILENAME!.pdf"
    ) else (
      for %%f in (%1) do set "BASE_NAME=%%~nf"
      set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!BASE_NAME!_multipage.pdf"
    )
  )
) else (
  REM Single file mode
  echo %GREEN%%BOLD%[INFO] Processing single image:%RESET% %CYAN%%1%RESET%
  
  REM Execute the Python script with return-path to capture the output path
  for /f "usebackq delims=" %%p in (`python "%SCRIPT_DIR%image_to_pdf_converter.py" "%~1" --output-dir "%SCRIPT_DIR:~0,-1%" !FILENAME_OPTION! --return-path`) do (
    set "PDF_PATH=%%p"
  )
  
  if !ERRORLEVEL! NEQ 0 (
    echo %RED%%BOLD%[ERROR] Command failed with error code !ERRORLEVEL!%RESET%
    del "%TEMP_FILE%" 2>nul
    pause
    exit /b 1
  )
  
  REM If no PDF_PATH was captured, determine it based on the image and custom filename
  if "!PDF_PATH!"=="" (
    if defined CUSTOM_FILENAME (
      set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!CUSTOM_FILENAME!.pdf"
    ) else (
      for %%f in (%1) do set "BASE_NAME=%%~nf"
      set "PDF_PATH=%SCRIPT_DIR:~0,-1%\!BASE_NAME!.pdf"
    )
  )
)

echo.
echo %GREEN%%BOLD%[SUCCESS] All operations completed.%RESET%
echo %CYAN%%BOLD%[INFO] PDF file is saved at: !PDF_PATH!%RESET%

REM Wait to ensure the PDF is fully written to disk
echo %YELLOW%[WAIT] Waiting for PDF file to be ready...%RESET%
timeout /t 3 /nobreak > nul

REM Check if the PDF file exists and open it
if exist "!PDF_PATH!" (
  echo %GREEN%[CHECK] PDF file found.%RESET%
  
  REM Launch a separate command window to handle PDF opening and deletion prompt
  REM This ensures the terminal stays open for user interaction
  start cmd /c "title PDF Viewer && ^
  echo %BRIGHT_GREEN%Image to PDF Conversion Complete!%RESET% && ^
  echo %BRIGHT_CYAN%PDF file saved at: !PDF_PATH!%RESET% && ^
  echo. && ^
  echo %BRIGHT_GREEN%Opening PDF file...%RESET% && ^
  start """" "!PDF_PATH!" && ^
  timeout /t 2 /nobreak > nul && ^
  echo. && ^
  echo %BRIGHT_YELLOW%Would you like to delete the original image files? (Y/N)%RESET% && ^
  choice /c YN /m "Delete original images" && ^
  if !ERRORLEVEL! EQU 1 ( ^
    echo %BRIGHT_GREEN%Deleting original image files...%RESET% && ^
    for /f "usebackq delims=" %%f in ("%TEMP_FILE%") do ( ^
      echo %BRIGHT_CYAN%Deleting: %%f%RESET% && ^
      del "%%f" ^
    ) && ^
    echo %BRIGHT_GREEN%Original image files have been deleted.%RESET% ^
  ) else ( ^
    echo %BRIGHT_YELLOW%Original image files have been kept.%RESET% ^
  ) && ^
  del "%TEMP_FILE%" 2>nul && ^
  echo. && ^
  echo %BRIGHT_GREEN%Press any key to exit...%RESET% && ^
  pause > nul"
  
  echo %BRIGHT_GREEN%PDF viewer window has been opened.%RESET%
  echo %BRIGHT_YELLOW%Please respond to the prompt in the new window to delete or keep original files.%RESET%
) else (
  echo %BRIGHT_RED%Warning: PDF file not found at expected location: !PDF_PATH!%RESET%
  del "%TEMP_FILE%" 2>nul
)

echo.
echo %BRIGHT_GREEN%This window will close automatically.%RESET%
timeout /t 5 /nobreak > nul
