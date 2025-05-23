#!/bin/bash

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