#!/bin/bash
#
# prepend-hash.sh
#
# This script renames all regular files in a specified directory by prepending a 24-character SHA-256 hash and a double underscore to each filename.
#
# Usage:
#   ./prepend-hash.sh /path/to/directory
#
# For each file in the directory:
#   - If the filename already starts with a 24-character hex hash followed by '__', it is skipped.
#   - Otherwise, the script computes the SHA-256 hash of the file, takes the first 24 characters, and renames the file to '<hash>__<original_filename>'.
#
# Example:
#   original.txt -> 1a2b3c4d5e6f7g8h9i0j1k2l__original.txt

all_args="$*"
DIRECTORY="$all_args"

# Iterate over all files in the directory
for FILE in "$DIRECTORY"/*; do
  # Skip if it's not a regular file
  if [ ! -f "$FILE" ]; then
    continue
  fi

  if [[ "$FILE" =~ ^[0-9a-fA-F]{24}__.* ]]; then
    # echo "Skipping already hashed file: $FILE"
    continue
  fi

  # Calculate the 24-character hex hash of the file
  HASH=$(sha256sum "$FILE" | awk '{print $1}' | cut -c1-24)

  # Extract the filename without the directory path
  FILENAME=$(basename "$FILE")

  # Rename the file by prepending the hash and double underscore
  NEW_NAME="$DIRECTORY/${HASH}__${FILENAME}"

  # Perform the rename operation
  mv "$FILE" "$NEW_NAME"

  echo "Renamed: $FILE -> $NEW_NAME"
done