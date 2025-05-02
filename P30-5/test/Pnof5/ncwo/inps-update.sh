#!/bin/bash

# Directory containing the .inp files
DIRECTORY="./"  # Change this to the desired directory if needed

# Loop through all .inp files in the directory
for file in "$DIRECTORY"/*.inp; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Use sed to replace "IPNOF=5" with "IPNOF=5" in the file
    sed -i 's/IPNOF=5/IPNOF=5/g' "$file"
    echo "Updated $file"
  else
    echo "No .inp files found in the directory."
  fi
done
