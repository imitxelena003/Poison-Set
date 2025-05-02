#!/bin/bash

# Directory containing the .inp files
DIRECTORY="./"  # Change this to the desired directory if needed

# Loop through all .inp files in the directory
for file in "$DIRECTORY"/*.inp; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Use sed to replace "IPNOF=8" with "IPNOF=7" in the file
    sed -i 's/IPNOF=8/IPNOF=7/g' "$file"
    echo "Updated $file"
  else
    echo "No .inp files found in the directory."
  fi
done
