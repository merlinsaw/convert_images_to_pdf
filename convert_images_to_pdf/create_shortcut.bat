@echo off
setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

echo ================================
echo    CREATE PORTABLE SHORTCUT     
echo ================================
echo.

REM Set color for info messages (Cyan)
color 0b

echo This script will create a shortcut (.lnk) file that can be placed anywhere
echo and will work with the scripts in the convert_images_to_pdf folder.
echo.
echo The shortcut will convert images to PDF and save them in the same directory
echo as the input image files.
echo.
echo NOTE: If you already have a shortcut that doesn't work with drag-and-drop,
echo please recreate it using this script.
echo.

REM Check if the icon file exists
if not exist "!SCRIPT_DIR!pdf_converter_icon.ico" (
    color 0e
    echo [INFO] Custom icon file not found.
    echo To use a custom icon, save an .ico file named "pdf_converter_icon.ico"
    echo in the same folder as this script.
    echo A default icon will be used for now.
    echo.
)

REM Ask for shortcut name
color 0e
echo [INPUT] Enter a name for the shortcut (without .lnk extension):
echo Press Enter to use default name "Convert Images to PDF"
set /p "SHORTCUT_NAME="

if "!SHORTCUT_NAME!"=="" (
    set "SHORTCUT_NAME=Convert Images to PDF"
)

REM Ask for shortcut location
color 0e
echo.
echo [INPUT] Where would you like to save the shortcut?
echo 1. Desktop
echo 2. Current directory
echo 3. Custom location
set /p "LOCATION_CHOICE=Enter your choice (1-3, default=1): "

if "!LOCATION_CHOICE!"=="" set "LOCATION_CHOICE=1"

if "!LOCATION_CHOICE!"=="1" (
    for /f "tokens=*" %%a in ('powershell -command "[Environment]::GetFolderPath('Desktop')"') do set "SHORTCUT_DIR=%%a"
) else if "!LOCATION_CHOICE!"=="2" (
    set "SHORTCUT_DIR=%CD%"
) else if "!LOCATION_CHOICE!"=="3" (
    echo.
    echo [INPUT] Enter the full path where you want to save the shortcut:
    set /p "SHORTCUT_DIR="
    
    REM Check if the directory exists
    if not exist "!SHORTCUT_DIR!" (
        color 0c
        echo [ERROR] The specified directory does not exist.
        echo Creating directory: !SHORTCUT_DIR!
        mkdir "!SHORTCUT_DIR!" 2>nul
        
        if !ERRORLEVEL! NEQ 0 (
            echo [ERROR] Failed to create directory.
            pause
            exit /b 1
        )
    )
) else (
    color 0c
    echo [ERROR] Invalid choice.
    pause
    exit /b 1
)

REM Full path to the shortcut
set "SHORTCUT_PATH=!SHORTCUT_DIR!\!SHORTCUT_NAME!.lnk"

REM Create the shortcut using PowerShell
color 0b
echo [INFO] Creating shortcut at: !SHORTCUT_PATH!

REM PowerShell script to create the shortcut
set "PS_SCRIPT=%TEMP%\create_shortcut_%RANDOM%.ps1"

echo $WshShell = New-Object -ComObject WScript.Shell > "!PS_SCRIPT!"
echo $Shortcut = $WshShell.CreateShortcut("!SHORTCUT_PATH!") >> "!PS_SCRIPT!"
echo $Shortcut.TargetPath = "!SCRIPT_DIR!shortcut_wrapper.bat" >> "!PS_SCRIPT!"
echo $Shortcut.WorkingDirectory = "!SCRIPT_DIR!" >> "!PS_SCRIPT!"
echo if (Test-Path "!SCRIPT_DIR!pdf_converter_icon.ico") { >> "!PS_SCRIPT!"
echo     $Shortcut.IconLocation = "!SCRIPT_DIR!pdf_converter_icon.ico" >> "!PS_SCRIPT!"
echo } else { >> "!PS_SCRIPT!"
echo     $Shortcut.IconLocation = "shell32.dll,277" >> "!PS_SCRIPT!"
echo } >> "!PS_SCRIPT!"
echo $Shortcut.Description = "Convert images to PDF and save in the same directory as the input images" >> "!PS_SCRIPT!"
echo $Shortcut.Save() >> "!PS_SCRIPT!"

REM Execute the PowerShell script
powershell -ExecutionPolicy Bypass -File "!PS_SCRIPT!"

REM Check if the shortcut was created
if exist "!SHORTCUT_PATH!" (
    color 0a
    echo [SUCCESS] Shortcut created successfully at:
    echo !SHORTCUT_PATH!
    
    REM Delete the temporary PowerShell script
    del "!PS_SCRIPT!" 2>nul
    
    echo.
    echo [INFO] You can now drag and drop image files onto this shortcut
    echo to convert them to PDF. The PDF will be saved in the same
    echo directory as the input image files.
) else (
    color 0c
    echo [ERROR] Failed to create shortcut.
    
    REM Delete the temporary PowerShell script
    del "!PS_SCRIPT!" 2>nul
)

echo.
echo Press any key to exit...
pause > nul 