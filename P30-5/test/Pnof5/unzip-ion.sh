#!/bin/bash

# Find all zip files recursively and unzip them
find . -type f -name "*.zip" -exec sh -c 'unzip -o -d "$(dirname "{}")" "{}"' \;

echo "All zip files have been extracted to their respective directories"
