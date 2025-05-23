#!/bin/bash

# This script removes a 26-character hash prefix from filenames in a specified directory.
# The hash prefix is expected to follow the pattern: 24 hexadecimal characters followed by "__".
# 
# Usage:
#   ./remove-hash.sh <directory_path>
#
# Parameters:
#   <directory_path> - The path to the directory containing the files to be renamed.
#
# Functionality:
#   1. Determines the terminal width to format output messages.
#   2. Iterates over all files in the specified directory.
#   3. Checks if the filename starts with a 26-character hash prefix.
#   4. If a hash prefix is found, renames the file by removing the prefix.
#   5. Prints the old and new filenames, truncating them if they exceed the terminal width.
#
# Notes:
#   - Only regular files are processed; directories and other file types are skipped.
#   - The script ensures that filenames are truncated with "..." in the output if they exceed the terminal width.
#   - Ensure the script has execute permissions before running: `chmod +x remove-hash.sh`.

all_args="$*"
DIRECTORY="$all_args"

# determine terminal width

TERMINAL_WIDTH=$(tput cols)
use_width=$((TERMINAL_WIDTH - 15))

# Iterate over all files in the directory
for FILE in "$DIRECTORY"/*; do
  # Skip if it's not a regular file
  if [ ! -f "$FILE" ]; then
    continue
  fi

  file_name=$(basename "$FILE")
  file_dir=$(dirname "$FILE")
  hash_part="${file_name:0:26}"
  if [[ "$hash_part" =~ ^([0-9a-fA-F]{24})__(.*) ]]; then

    old_name="$FILE"
    new_name="$file_dir/${file_name:26}"
    mv "$old_name" "$new_name"

    old_name_print="${old_name:0:use_width}"
    new_name_print="${new_name:0:use_width}"
    if [[ "${#old_name}" -gt $use_width ]]; then
      old_name_print+="..."
    fi
    if [[ "${#new_name}" -gt $use_width ]]; then
      new_name_print+="..."
    fi

    echo -e "Renamed: $old_name_print\n\t-> $new_name_print"
  fi

done
