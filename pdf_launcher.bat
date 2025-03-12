@echo off
setlocal enabledelayedexpansion

REM Get the PDF path from the first argument
set "PDF_PATH=%~1"

echo [92mImage to PDF Conversion Complete![0m
echo [96mPDF file saved at: %PDF_PATH%[0m
echo.

REM Open the PDF file
if exist "%PDF_PATH%" (
    echo [92mOpening PDF file...[0m
    start "" "%PDF_PATH%"
    
    REM Get the list of image files from a temporary file
    set "IMAGE_LIST=%~2"
    
    if exist "%IMAGE_LIST%" (
        echo.
        echo [93mWould you like to delete the original image files? (Y/N)[0m
        choice /c YN /m "Delete original images"
        
        if !ERRORLEVEL! EQU 1 (
            echo [92mDeleting original image files...[0m
            for /f "usebackq delims=" %%f in ("%IMAGE_LIST%") do (
                echo [96mDeleting: "%%f"[0m
                del "%%f"
            )
            echo [92mOriginal image files have been deleted.[0m
        ) else (
            echo [93mOriginal image files have been kept.[0m
        )
        
        REM Delete the temporary file
        del "%IMAGE_LIST%"
    ) else (
        echo [91mWarning: Image list not found.[0m
    )
) else (
    echo [91mWarning: PDF file not found at expected location.[0m
)

echo.
echo [92mPress any key to exit...[0m
pause > nul
