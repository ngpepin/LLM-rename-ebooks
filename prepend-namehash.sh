#!/bin/bash
# prepend-namehash.sh
#
# This script renames all files in a given directory by prepending a hash (derived from the filename) to each filename.
#
# Steps:
# 1. For each file in the directory, if it does not already start with a hash, compute a simhash of the filename and prepend it.
# 2. After renaming, sorts the files and processes them to compute and print the decimal difference between the leading 6 hex digits of each file's hash and the previous file's hash.
#
# Usage:
#   ./prepend-namehash.sh /path/to/directory
#
# Requirements:
#   - Python3 with simhash module installed
#   - bc (for hex/decimal math)
#
# Notes:
#   - Only regular files are processed.
#   - Files already starting with a 24-character hex hash and double underscore are skipped.
#   - Hashes are computed using simhash on the filename.
#   - The script is safe for filenames with spaces.

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
    else

        FILENAME=$(basename "$FILE")
        hash_nils=""
        # hash_simh=""
        hash_simh=$(python3 -c "from simhash import Simhash; print(hex(Simhash('$FILENAME').value))" 2>/dev/null)
        # hash_nils=$(python3 -c "import nilsimsa; print(nilsimsa.Nilsimsa('$FILENAME').hexdigest())" 2>/dev/null)
        # full_hash="${hash_simh:2:14}${hash_nils:0:10}"

        if [[ -z "$hash_simh" ]]; then
            echo "Failed to compute hash for $FILENAME"
            continue
        else
            full_hash="${hash_simh:2:16}00000000"
        fi
        NEW_NAME="$DIRECTORY/${full_hash}__${FILENAME}"
        echo "Renaming $FILENAME to $NEW_NAME"
        mv "$FILE" "$NEW_NAME"

    fi
done
previous_hash=""
previous_name=""
# fill array with files in DIRECTORY making sure to handle ones swith spaces properly
IFS=$'\n' read -d '' -r -a FILE_ARRAY < <(find "$DIRECTORY" -maxdepth 1 -type f -print0 | xargs -0 -n1 echo)
IFS=$'\n' sorted_files=($(sort <<<"${FILE_ARRAY[*]}"))
for FILE in "${sorted_files[@]}"; do
    # FILE="$DIRECTORY/$FILE"
    FILENAME=$(basename "$FILE")
    # extract the hash
    hash_part="${FILENAME:0:26}"
    file_part="${FILENAME:26}"
    if [[ "$hash_part" =~ ^([0-9a-fA-F]{24})__(.*) ]]; then
        hash="${BASH_REMATCH[1]}"
        # only consider leading 6 characters of the hash
        hash="${hash:0:6}"
        # echo "Processing file: $FILE with hash: $hash"
        # hex subtract hash from previous_hash
        if [[ -n "$previous_hash" ]]; then
            decimal_diff=$(echo "ibase=16; obase=10; $((0x$hash - 0x$previous_hash))" | bc)
            # divide by 100000 and take integer part
            decimal_diff=$((decimal_diff / 100000))
       echo "Decimal difference: $decimal_diff"
            # decimal_diff=$(printf "%06d" "$decimal_diff")
            # # mv "$DIRECTORY/$FILE" "$DIRECTORY/${decimal_diff}__${FILENAME}"
            # shorter_hash="${hash:0:6}"
            # echo "Renaming $FILE to ${DIRECTORY}/${shorter_hash}__${decimal_diff}__${file_part}"
            # mv "$FILE" "${DIRECTORY}/${shorter_hash}__${decimal_diff}__${file_part}"
        fi
        previous_hash="$hash"
        previous_name="$FILENAME"
    else
        echo "Skipping file: $FILE as it does not match the expected pattern"
    fi
done
