#!/bin/bash
#
# PURPOSE:
#
# Used in conjuntion with / is called by rename-ebooks.sh 
#
# - Fixes an issue with ebook-tools where the script creates a directory 
#   for a matching book instead of properly renaming the source file.
#   It will move the files to the root destination directory and rename them
#   based on the directory name from which they were moved. Since the ebook-tools bug
#   results in the extension being lost, this script determines the file type based on
#   the actual structure of the file, and, failing that, the mimetype. If the file type
#   cannot be determined, it will get an .unknown extension.
#
#   Initial state due to bug:
#
#   X : the new book filename determined by ebook-tools
#   Y : the original book filename
#
#   < root destination directory >
#   └── <directory named X>
#   |   └── input
#   |       ├── <file named Y>                          # extension is lost
#   |       └── <file named Y>.meta
#   └── <directory named ...
#
#   Corrected final state:
#
#   < root destination directory >
#   └── <file named X >.pdf | .epub | .mobi | .txt      # extension is determined or defaults to 'unknown'
#   └── <file named X >.meta
#   └── <file named ...
#

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
    # shellcheck disable=SC2034
    dir_name="$(dirname "$file")"
    base_name="$(basename "$file")"
    
    # Strip any existing extension
    stripped_name="${base_name%.*}"
    
    # Determine correct file extension
    file_extension=$(determine_extension "$file")
    
    # Get a unique filename in case of conflict
    new_filename=$(get_unique_filename "$stripped_name" "$file_extension")
    
    # Move and rename the file to the root directory
    mv "$file" "$target_dir/$new_filename"

done
