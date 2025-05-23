#!/bin/bash

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No directory provided"
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

target_dir="$1"
converted_dir="$target_dir/Converted"

# Check if directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

# Create Converted directory if it doesn't exist
mkdir -p "$converted_dir"

# Check if ebook-convert (calibre) is installed
if ! command -v ebook-convert &> /dev/null; then
    echo "Error: ebook-convert (from calibre) is not installed."
    echo "Please install calibre first: sudo apt install calibre"
    exit 1
fi

# Process each chm file
find "$target_dir" -maxdepth 1 -type f -name "*.chm" -print0 | while IFS= read -r -d '' file; do
    # Get filename without extension
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"

    # Set output PDF path
    pdf_path="$target_dir/$filename_noext.pdf"

    echo "Converting: $filename to PDF..."
    
    # Convert chm to pdf
    ebook-convert "$file" "$pdf_path"
    
    if [ $? -eq 0 ]; then
        # Move original chm to Converted directory
        mv "$file" "$converted_dir/"
        echo "Successfully converted and moved original"
    else
        echo "Error converting $filename"
    fi
done

echo "Conversion process completed"