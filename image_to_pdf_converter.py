import os
import sys
import argparse
import subprocess

# Function to check and install required packages
def check_and_install_packages():
    required_packages = ['Pillow', 'reportlab']
    missing_packages = []
    
    # Check for each package
    for package in required_packages:
        try:
            __import__(package.lower() if package != 'Pillow' else 'PIL')
        except ImportError:
            missing_packages.append(package)
    
    # If there are missing packages, install them
    if missing_packages:
        print(f"Installing missing packages: {', '.join(missing_packages)}")
        try:
            subprocess.check_call([sys.executable, "-m", "pip", "install"] + missing_packages)
            print("Package installation completed successfully!")
            return True
        except subprocess.CalledProcessError as e:
            print(f"Error installing packages: {str(e)}")
            print("Please install the required packages manually using:")
            print("pip install Pillow reportlab")
            return False
    
    return True

# Check and install packages before importing them
packages_installed = check_and_install_packages()

# Now try to import the required packages
try:
    from PIL import Image
    from reportlab.lib.pagesizes import letter
    from reportlab.pdfgen import canvas
except ImportError:
    if packages_installed:
        print("Error: Failed to import required packages even after installation.")
        print("Please try installing the packages manually using:")
        print("pip install Pillow reportlab")
    sys.exit(1)

# ANSI color codes
GREEN = "\033[32m"
BRIGHT_GREEN = "\033[92m"
YELLOW = "\033[33m"
BRIGHT_YELLOW = "\033[93m"
CYAN = "\033[36m"
BRIGHT_CYAN = "\033[96m"
RED = "\033[31m"
BRIGHT_RED = "\033[91m"
MAGENTA = "\033[35m"
BOLD = "\033[1m"
RESET = "\033[0m"

def print_color(text, color=RESET, bold=False):
    """Print colored text to the console."""
    if bold:
        print(f"{color}{BOLD}{text}{RESET}")
    else:
        print(f"{color}{text}{RESET}")

def convert_image_to_pdf(image_path, output_path=None, output_dir=None, output_name=None):
    """
    Convert a single image to PDF.
    
    Args:
        image_path (str): Path to the image file
        output_path (str, optional): Full path for the output PDF
        output_dir (str, optional): Directory to save the PDF
        output_name (str, optional): Name for the output PDF file (without extension)
        
    Returns:
        str: Path to the created PDF file
    """
    try:
        # Get the base name of the image (without extension)
        base_name = os.path.splitext(os.path.basename(image_path))[0]
        
        # Determine the output path
        if output_path:
            pdf_path = output_path
        else:
            # If output_dir is not provided, use the same directory as the image
            if not output_dir:
                output_dir = os.path.dirname(image_path)
            
            # If output_name is not provided, use the image base name
            if not output_name:
                output_name = base_name
            
            pdf_path = os.path.join(output_dir, f"{output_name}.pdf")
        
        # Open the image
        print_color(f"[INFO] Opening image: {image_path}", CYAN)
        img = Image.open(image_path)
        
        # Get image dimensions
        width, height = img.size
        
        # Create a PDF with the same dimensions as the image
        c = canvas.Canvas(pdf_path, pagesize=(width, height))
        
        # Draw the image on the PDF
        print_color(f"[INFO] Converting image to PDF...", YELLOW)
        c.drawImage(image_path, 0, 0, width, height)
        
        # Save the PDF
        c.save()
        
        # Check if the PDF was created
        if os.path.exists(pdf_path):
            print_color(f"[SUCCESS] PDF created: {pdf_path}", GREEN, bold=True)
            return pdf_path
        else:
            print_color(f"[ERROR] Failed to create PDF: {pdf_path}", RED, bold=True)
            return None
    
    except Exception as e:
        print_color(f"[ERROR] Error converting image to PDF: {str(e)}", RED, bold=True)
        return None

def create_multipage_pdf(image_paths, output_path=None, output_dir=None, output_name=None):
    """
    Create a multi-page PDF from multiple images.
    
    Args:
        image_paths (list): List of paths to image files
        output_path (str, optional): Full path for the output PDF
        output_dir (str, optional): Directory to save the PDF
        output_name (str, optional): Name for the output PDF file (without extension)
        
    Returns:
        str: Path to the created PDF file
    """
    try:
        # Get the base name of the first image (without extension)
        base_name = os.path.splitext(os.path.basename(image_paths[0]))[0]
        
        # Determine the output path
        if output_path:
            pdf_path = output_path
        else:
            # If output_dir is not provided, use the same directory as the first image
            if not output_dir:
                output_dir = os.path.dirname(image_paths[0])
            
            # If output_name is not provided, use the first image base name + _multipage
            if not output_name:
                output_name = f"{base_name}_multipage"
            
            pdf_path = os.path.join(output_dir, f"{output_name}.pdf")
        
        # Create a PDF with the dimensions of the first image
        print_color(f"[INFO] Creating multi-page PDF...", CYAN)
        
        # Process each image
        c = None
        for i, img_path in enumerate(image_paths):
            print_color(f"[PAGE {i+1}] Processing: {img_path}", CYAN)
            
            # Open the image
            img = Image.open(img_path)
            
            # Get image dimensions
            width, height = img.size
            
            # For the first page, create the canvas
            if i == 0:
                c = canvas.Canvas(pdf_path, pagesize=(width, height))
            else:
                # For subsequent pages, add a new page with the dimensions of the current image
                c.setPageSize((width, height))
            
            # Draw the image on the PDF
            c.drawImage(img_path, 0, 0, width, height)
            
            # If not the last page, add a new page
            if i < len(image_paths) - 1:
                c.showPage()
        
        # Save the PDF
        if c:
            c.save()
            
            # Check if the PDF was created
            if os.path.exists(pdf_path):
                print_color(f"[SUCCESS] Multi-page PDF created: {pdf_path}", GREEN, bold=True)
                return pdf_path
            else:
                print_color(f"[ERROR] Failed to create multi-page PDF: {pdf_path}", RED, bold=True)
                return None
        else:
            print_color(f"[ERROR] No images were processed", RED, bold=True)
            return None
    
    except Exception as e:
        print_color(f"[ERROR] Error creating multi-page PDF: {str(e)}", RED, bold=True)
        return None

def main():
    parser = argparse.ArgumentParser(description="Convert images to PDF")
    parser.add_argument("image_paths", nargs="+", help="Path(s) to image file(s)")
    parser.add_argument("--multi", action="store_true", help="Create a multi-page PDF from multiple images")
    parser.add_argument("--output-path", help="Full path for the output PDF")
    parser.add_argument("--output-dir", help="Directory to save the PDF")
    parser.add_argument("--output-name", help="Name for the output PDF file (without extension)")
    parser.add_argument("--return-path", action="store_true", help="Return the PDF path to stdout for batch file capture")
    
    args = parser.parse_args()
    
    pdf_path = None
    
    if args.multi:
        pdf_path = create_multipage_pdf(args.image_paths, args.output_path, args.output_dir, args.output_name)
    else:
        pdf_path = convert_image_to_pdf(args.image_paths[0], args.output_path, args.output_dir, args.output_name)
    
    if pdf_path:
        if args.return_path:
            # Print only the path for batch file capture
            print(pdf_path)
        print_color("[SUCCESS] Conversion completed successfully!", GREEN, bold=True)
        return 0
    else:
        print_color("[ERROR] Conversion failed!", RED, bold=True)
        return 1

if __name__ == "__main__":
    sys.exit(main())
