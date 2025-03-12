@echo off
setlocal enabledelayedexpansion

REM Define color codes
set "GREEN=[32m"
set "BRIGHT_GREEN=[92m"
set "YELLOW=[33m"
set "BRIGHT_YELLOW=[93m"
set "CYAN=[36m"
set "BRIGHT_CYAN=[96m"
set "RED=[31m"
set "BRIGHT_RED=[91m"
set "RESET=[0m"

REM Get the PDF path from the first argument
set "PDF_PATH=%~1"

echo %BRIGHT_GREEN%Image to PDF Conversion Complete!%RESET%
echo %BRIGHT_CYAN%PDF file saved at: %PDF_PATH%%RESET%
echo.

REM Open the PDF file with retries
if exist "%PDF_PATH%" (
    echo %BRIGHT_GREEN%Opening PDF file...%RESET%
    
    REM Try to open the PDF up to 3 times
    set /a retry=0
    :RETRY_OPEN
    start "" "%PDF_PATH%"
    timeout /t 2 /nobreak > nul
    
    REM Check if the PDF viewer is running (this is a basic check)
    tasklist /FI "IMAGENAME eq AcroRd32.exe" /FI "IMAGENAME eq msedge.exe" /FI "IMAGENAME eq chrome.exe" 2>nul | find /i "exe" >nul
    if !ERRORLEVEL! NEQ 0 (
        set /a retry+=1
        if !retry! LSS 3 (
            echo %YELLOW%Retrying to open PDF (!retry!/3)...%RESET%
            goto RETRY_OPEN
        ) else (
            echo %BRIGHT_RED%Could not open PDF automatically. Please open it manually:%RESET%
            echo %BRIGHT_CYAN%"%PDF_PATH%"%RESET%
        )
    ) else (
        echo %BRIGHT_GREEN%PDF viewer launched successfully.%RESET%
    )
    
    REM Get the list of image files from a temporary file
    set "IMAGE_LIST=%~2"
    
    if exist "%IMAGE_LIST%" (
        REM Wait a bit longer for the PDF to open
        timeout /t 4 /nobreak > nul
        
        echo.
        echo %BRIGHT_YELLOW%Would you like to delete the original image files? (Y/N)%RESET%
        echo %CYAN%Please check the PDF before deciding.%RESET%
        
        REM Use choice with a default timeout of 300 seconds (5 minutes)
        choice /c YN /t 300 /d N /m "Delete original images (Y=Yes, N=No, Default=No in 5 minutes)"
        
        if !ERRORLEVEL! EQU 1 (
            echo.
            echo %BRIGHT_GREEN%Deleting original image files...%RESET%
            set "DELETE_ERROR="
            for /f "usebackq delims=" %%f in ("%IMAGE_LIST%") do (
                echo %BRIGHT_CYAN%Deleting: "%%f"%RESET%
                del "%%f" 2>nul || set "DELETE_ERROR=1"
            )
            if defined DELETE_ERROR (
                echo %BRIGHT_RED%Some files could not be deleted. They may be in use.%RESET%
            ) else (
                echo %BRIGHT_GREEN%Original image files have been deleted.%RESET%
            )
        ) else (
            echo.
            echo %BRIGHT_YELLOW%Original image files have been kept.%RESET%
        )
        
        REM Delete the temporary file
        del "%IMAGE_LIST%" 2>nul
    ) else (
        echo %BRIGHT_RED%Warning: Image list not found.%RESET%
    )
) else (
    echo %BRIGHT_RED%Error: PDF file not found at: %PDF_PATH%%RESET%
)

echo.
echo %BRIGHT_GREEN%Press any key to exit...%RESET%
pause > nul
