#!/bin/bash

# fix-extensions.sh
# This script processes files in a specified directory, determines their correct file extensions based on their content,
# and renames them accordingly. It ensures that files are uniquely named to avoid conflicts and moves them to the target directory.

# Usage:
#   ./fix-extensions.sh <directory_path>
#   - <directory_path>: The path to the directory containing the files to process.

# Features:
# 1. Validates the input directory:
#    - Ensures a directory path is provided as an argument.
#    - Verifies that the provided path is a valid directory.

# 2. Determines the correct file extension:
#    - Uses tools like `pdftotext`, `unzip`, `mobi_unpack`, and `file` to identify the file type.
#    - Falls back to MIME type detection if necessary.
#    - Supports the following file types:
#      - PDF (.pdf)
#      - EPUB (.epub)
#      - MOBI (.mobi)
#      - Plain text (.txt)
#      - Unknown files are labeled as "unknown".

# 3. Handles filename conflicts:
#    - Generates unique filenames by appending a counter (e.g., `file(1).ext`) if a file with the same name already exists.

# 4. Processes files recursively:
#    - Excludes files with extensions `.meta` and `.unknown`.
#    - Moves and renames files to the root of the target directory.

# Dependencies:
# - `pdftotext`: For detecting PDF files.
# - `unzip`: For detecting EPUB files.
# - `mobi_unpack`: For detecting MOBI files.
# - `file`: For MIME type detection.

# Notes:
# - Temporary directories are created and cleaned up during processing.
# - The script outputs detailed logs for each file, including its original name, detected type, and new name.
# Ensure a directory is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    exit 1
fi

target_dir="$1"

# Ensure the provided argument is a valid directory
if [ ! -d "$target_dir" ]; then
    echo "Error: '$target_dir' is not a valid directory."
    exit 1
fi

# Function to determine file type based on actual structure
determine_extension() {
    temp_dir=$(mktemp -d)

    if pdftotext "$1" - &>/dev/null 2>&1; then
        echo "pdf"
    elif unzip -tq "$1" 2>/dev/null | grep -q "mimetypeapplication/epub+zip"; then
        echo "epub"
    elif mobi_unpack "$1" "$temp_dir" &>/dev/null 2>&1; then
        echo "mobi"
    elif file "$1" 2>/dev/null | grep -q "ASCII text\|UTF-8 Unicode text"; then
        echo "txt"
    else      
    # Try to determine file type using MIME info
        mime_type=$(file --mime-type -b "$1" 2>/dev/null)
        case "$mime_type" in
            "application/pdf") echo "pdf";;
            "application/epub+zip") echo "epub";;
            "application/x-mobipocket-ebook"|"application/octet-stream") echo "mobi";;
            "text/plain") echo "txt";;
            *) echo "unknown";;
        esac    
        fi

    # Clean up temporary directory
    rm -rf "$temp_dir"
}

# Function to generate a unique filename if a conflict exists
get_unique_filename() {
    local base="$1"
    local ext="$2"
    local counter=1
    local new_name="$base.$ext"

     # Ensure the extension is correctly applied without duplicate dots
    if [[ "$base" == *"."* ]]; then
        base="${base%.*}"
    fi

    while [ -e "$target_dir/$new_name" ]; do
        new_name="${base}($counter).$ext"
        ((counter++))
    done

    echo "$new_name"
}

# Recursively find and process all files, excluding .meta and .unknown
find "$target_dir" -type f ! -name "*.meta" ! -name "*.unknown" | while read -r file; do
    echo "==============================================================================================================================================================================================="
    echo "Examining: $file"
    echo "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
    dir_name="$(dirname "$file")"
    base_name="$(basename "$file")"

    # Strip any existing extension
    stripped_name="${base_name%.*}"

    # Determine correct file extension
    file_extension=$(determine_extension "$file")
    if [ "$file_extension" == "unknown" ]; then
        echo "Unable to determine file type."
    else
        echo "Detected file of type $file_extension"
    fi

    # Get a unique filename in case of conflict
    new_filename=$(get_unique_filename "$stripped_name" "$file_extension")

    # Move and rename the file to the root directory
    mv "$file" "$target_dir/$new_filename"
    echo "Moved to: $target_dir/$new_filename"

done
