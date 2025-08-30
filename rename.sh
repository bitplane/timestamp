#!/bin/bash

# Check if a path was provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path>"
    exit 1
fi

TARGET_PATH="$1"

# Check if the path exists
if [ ! -e "$TARGET_PATH" ]; then
    echo "Error: Path '$TARGET_PATH' does not exist"
    exit 1
fi

#MV="echo mv"
MV="mv"

# Process each item in the directory (non-recursive)
for item in "$TARGET_PATH"/*; do
    # Skip if no files match (glob didn't expand)
    [ ! -e "$item" ] && continue
    
    # Get just the filename without path
    basename_item=$(basename "$item")
    dirname_item=$(dirname "$item")
    
    # Check if the name already starts with a number
    if [[ ! "$basename_item" =~ ^[0-9] ]]; then
        # Get the modification time in YYYY-MM-DD format
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            mtime=$(stat -f "%Sm" -t "%Y-%m-%d" "$item")
        else
            # Linux
            mtime=$(stat -c "%y" "$item" | cut -d' ' -f1)
        fi
        
        # Create the new name
        new_name="${mtime}_${basename_item}"
        new_path="${dirname_item}/${new_name}"
        
        # Rename the file/directory
        $MV "$item" "$new_path"
        echo "Renamed: $basename_item -> $new_name"
    else
        echo "Skipped: $basename_item (already starts with a number)"
    fi
done

echo "Done!"
