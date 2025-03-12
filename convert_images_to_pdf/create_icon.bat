@echo off
setlocal enabledelayedexpansion

REM Get the directory where this batch file is located
set "SCRIPT_DIR=%~dp0"

echo ================================
echo     CREATE CUSTOM ICON FILE     
echo ================================
echo.

REM Set color for info messages (Cyan)
color 0b

echo This script will help you create a custom icon file for your PDF converter shortcut.
echo You'll need to provide an image file (PNG, JPG, etc.) to convert to an .ico file.
echo.

REM Check if Python is installed
where python >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    color 0c
    echo [ERROR] Python is not installed or not in PATH.
    echo.
    echo Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)

REM Check if Pillow is installed
python -c "import PIL" >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    color 0e
    echo [INFO] Installing required Python package (Pillow)...
    python -m pip install Pillow
    
    if %ERRORLEVEL% NEQ 0 (
        color 0c
        echo [ERROR] Failed to install Pillow.
        echo Please install it manually: python -m pip install Pillow
        pause
        exit /b 1
    )
)

REM Ask for image file
color 0e
echo.
echo [INPUT] Enter the path to the image file you want to convert to an icon:
echo (You can drag and drop the file here)
set /p "IMAGE_PATH="

if "!IMAGE_PATH!"=="" (
    color 0c
    echo [ERROR] No image file provided.
    pause
    exit /b 1
)

REM Remove quotes if present
set "IMAGE_PATH=!IMAGE_PATH:"=!"

REM Check if the file exists
if not exist "!IMAGE_PATH!" (
    color 0c
    echo [ERROR] The specified image file does not exist: !IMAGE_PATH!
    pause
    exit /b 1
)

REM Create a Python script to convert the image to an icon
set "PY_SCRIPT=%TEMP%\create_icon_%RANDOM%.py"

echo from PIL import Image > "!PY_SCRIPT!"
echo import os >> "!PY_SCRIPT!"
echo. >> "!PY_SCRIPT!"
echo # Path to the input image >> "!PY_SCRIPT!"
echo image_path = r'!IMAGE_PATH!' >> "!PY_SCRIPT!"
echo. >> "!PY_SCRIPT!"
echo # Path to the output icon >> "!PY_SCRIPT!"
echo icon_path = r'%SCRIPT_DIR%pdf_converter_icon.ico' >> "!PY_SCRIPT!"
echo. >> "!PY_SCRIPT!"
echo try: >> "!PY_SCRIPT!"
echo     # Open the image >> "!PY_SCRIPT!"
echo     img = Image.open(image_path) >> "!PY_SCRIPT!"
echo. >> "!PY_SCRIPT!"
echo     # Convert to RGBA if not already >> "!PY_SCRIPT!"
echo     if img.mode != 'RGBA': >> "!PY_SCRIPT!"
echo         img = img.convert('RGBA') >> "!PY_SCRIPT!"
echo. >> "!PY_SCRIPT!"
echo     # Create icon sizes >> "!PY_SCRIPT!"
echo     sizes = [(16, 16), (32, 32), (48, 48), (64, 64), (128, 128)] >> "!PY_SCRIPT!"
echo     img.save(icon_path, format='ICO', sizes=sizes) >> "!PY_SCRIPT!"
echo. >> "!PY_SCRIPT!"
echo     print(f"Icon created successfully at: {icon_path}") >> "!PY_SCRIPT!"
echo except Exception as e: >> "!PY_SCRIPT!"
echo     print(f"Error creating icon: {str(e)}") >> "!PY_SCRIPT!"

REM Execute the Python script
color 0b
echo [INFO] Converting image to icon...
python "!PY_SCRIPT!"

REM Check if the icon was created
if exist "%SCRIPT_DIR%pdf_converter_icon.ico" (
    color 0a
    echo [SUCCESS] Icon created successfully at:
    echo %SCRIPT_DIR%pdf_converter_icon.ico
    
    echo.
    echo [INFO] You can now run create_shortcut.bat to create a shortcut
    echo with your custom icon.
) else (
    color 0c
    echo [ERROR] Failed to create icon.
)

REM Delete the temporary Python script
del "!PY_SCRIPT!" 2>nul

echo.
echo Press any key to exit...
pause > nul 