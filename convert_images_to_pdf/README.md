# Image to PDF Converter

A portable tool to convert images to PDF files. The tool can convert single images or create multi-page PDFs from multiple images.

## ✓ Features

- ✓ Convert single images to PDF
- ✓ Create multi-page PDFs from multiple images
- ✓ Automatically install required Python packages
- ✓ Save PDFs in the same directory as the input images
- ✓ Create portable shortcuts that can be placed anywhere
- ✓ Colorful and informative console output
- ✓ Option to delete original images after conversion
- ✓ Custom icon support for shortcuts

## ✓ Requirements

- Windows 10 or later
- Python 3.6 or later (will be checked and notified if missing)
- Required Python packages (will be automatically installed):
  - Pillow
  - ReportLab

## ✓ How to Use

### Direct Method

1. Drag and drop image file(s) onto `Droplet_to_Convert_Image_to_PDF.bat`
2. Enter a custom name for the PDF or press Enter to use the default name
3. The PDF will be created in the same directory as the input image(s)
4. The PDF will automatically open when conversion is complete
5. You'll be asked if you want to delete the original image files

### Creating a Portable Shortcut

1. Run `create_shortcut.bat`
2. Enter a name for the shortcut or press Enter to use the default name
3. Choose where to save the shortcut (Desktop, current directory, or custom location)
4. The shortcut will be created and can be placed anywhere
5. Drag and drop image file(s) onto the shortcut to convert them to PDF
6. The PDF will be saved in the same directory as the input image(s)

### Creating a Custom Icon

1. Find or create an image you want to use as your shortcut icon
2. Run `create_icon.bat`
3. When prompted, enter the path to your image file (or drag and drop it)
4. The script will convert your image to an .ico file
5. Run `create_shortcut.bat` to create a shortcut with your custom icon

> **Note:** If you have an existing shortcut that doesn't work with drag-and-drop, please recreate it using the `create_shortcut.bat` script.

## ✓ Supported Image Formats

- PNG
- JPEG/JPG
- BMP
- GIF
- TIFF
- And more (any format supported by Pillow)

## ✓ Troubleshooting

### Missing Python

If you see an error about Python not being installed:
1. Download and install Python from [python.org](https://www.python.org/downloads/)
2. Make sure to check "Add Python to PATH" during installation
3. Restart your computer after installation

### Package Installation Issues

If the automatic package installation fails:
1. Open Command Prompt as Administrator
2. Run: `python -m pip install Pillow reportlab`
3. Try running the script again

## ✓ File Descriptions

- `Droplet_to_Convert_Image_to_PDF.bat` - Main script for converting images to PDF
- `image_to_pdf_converter.py` - Python script that handles the actual conversion
- `pdf_launcher.bat` - Helper script for opening PDFs and handling post-conversion options
- `create_shortcut.bat` - Script for creating portable shortcuts
- `shortcut_wrapper.bat` - Helper script that ensures shortcuts work with drag-and-drop
- `create_icon.bat` - Script for creating a custom icon from an image
- `pdf_converter_icon.ico` - Icon file for the shortcuts (created by create_icon.bat)

## ✓ License

This tool is free to use for personal and commercial purposes. 