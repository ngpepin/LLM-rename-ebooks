#!/bin/bash

# This script identifies and removes duplicate files in a specified directory based on the first 24 characters of their filenames.
# It retains the file with the longest filename in each group of duplicates and moves the others to a "Duplicates" subdirectory.

# Usage:
#   ./remove-duplicates-based-on-hash.sh directory_path
# Arguments:
#   directory_path - The path to the directory where duplicate detection will be performed.

# Functionality:
# 1. Validates that a directory argument is provided.
# 2. Creates a "Duplicates" subdirectory within the target directory if it doesn't already exist.
# 3. Groups files in the target directory by the first 24 characters of their filenames.
# 4. For each group of files with matching prefixes:
#    - Identifies the file with the longest filename.
#    - Moves all other files in the group to the "Duplicates" subdirectory.
# 5. Outputs the progress of moving duplicate files and completes with a summary message.

# Notes:
# - Only files in the top level of the specified directory are considered (maxdepth 1).
# - Filenames shorter than 24 characters are ignored.
# - The script uses an associative array to group files and a unit separator (ASCII 31) to handle filenames with spaces.
# Check if directory argument is provided

if [ $# -eq 0 ]; then
    echo "Error: No directory provided"
    echo "Usage: $0 directory_path"
    exit 1
fi

target_dir="$1"
duplicate_dir="$target_dir/Duplicates"

# Create Duplicate directory if it doesn't exist
mkdir -p "$duplicate_dir"

# Associative array to store hash groups
declare -A hash_groups

# First pass: group files by their first 24 characters
while IFS= read -r -d '' file; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        hash_prefix="${filename:0:24}"
        
        # Skip if filename is shorter than 24 characters
        if [ ${#filename} -ge 24 ]; then
            # Properly handle spaces by quoting and using a delimiter
            if [ -z "${hash_groups[$hash_prefix]}" ]; then
                hash_groups["$hash_prefix"]="$file"
            else
                hash_groups["$hash_prefix"]+=$'\x1F'"$file"  # Using unit separator as delimiter
            fi
        fi
    fi
done < <(find "$target_dir" -maxdepth 1 -type f -print0)

# Process each hash group
for hash_prefix in "${!hash_groups[@]}"; do
    # Split the group using the unit separator
    IFS=$'\x1F' read -ra files <<< "${hash_groups[$hash_prefix]}"
    
    # Only proceed if there are duplicates
    if [ ${#files[@]} -gt 1 ]; then
        # Find the file with the LONGEST filename
        longest_file="${files[0]}"
        longest_length=$(basename "$longest_file" | wc -m)
        
        for file in "${files[@]}"; do
            filename_length=$(basename "$file" | wc -m)
            if [ $filename_length -gt $longest_length ]; then
                longest_file="$file"
                longest_length=$filename_length
            fi
        done
        
        # Move all other files to Duplicate directory
        for file in "${files[@]}"; do
            if [ "$file" != "$longest_file" ]; then
                echo "Moving duplicate '$file' to '$duplicate_dir'"
                mv -- "$file" "$duplicate_dir/"
            fi
        done
    fi
done

echo "Duplicate file processing complete"