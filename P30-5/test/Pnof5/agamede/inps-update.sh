#!/bin/bash

# Directory containing the .inp files
DIRECTORY="./"  # Change this to the desired directory if needed

# String to append at the end of the file
APPEND_STRING="&NOFINP IORBOPT=4 IPNOF=5 RHF=F ICOEF=1 NTHRESHL=4 NTHRESHE=7 RESTART=F NCWO=-1 HFID=T MAXITID=30 /"

# Loop through all .inp files in the directory
for file in "$DIRECTORY"/*.inp; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Remove the last line of the file
    sed -i '$d' "$file"
    # Append the new line at the end of the file
    echo "$APPEND_STRING" >> "$file"
    echo "Updated $file"
  else
    echo "No .inp files found in the directory."
  fi
done
