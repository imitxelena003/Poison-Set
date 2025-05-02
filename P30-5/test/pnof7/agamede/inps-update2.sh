#!/bin/bash

# Directory containing the files (change as needed)
DIRECTORY="./"

# Find all files in the directory and replace IPNOF=7 with IPNOF=7
find "$DIRECTORY" -type f -exec sed -i 's/IPNOF=7/IPNOF=7/g' {} +

echo "Replaced all instances of 'IPNOF=7' with 'IPNOF=7' in files under $DIRECTORY"
