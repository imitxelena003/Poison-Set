#!/bin/bash

# Define the input file (replace 'inputfile.txt' with the actual filename)
#input_file="*out"
# Use grep to find lines containing "energy", and awk to extract columns 1 and 7
#grep -i "final nof t" ./temps5/7*/$input_file | awk '{print $1, $7}' > temp.txt

output_file="energies.txt"
> energies.txt

# Find all .out files in subdirectories and process each file
find . -type f -name "*.out" | while read file; do
    # Extract the filename without the .out extension
    filename=$(basename "$file" .out)

    # Search for "energy" in the file (case-insensitive)
    # Extract the 7th column and write to temp.txt
    grep -i "final nof t" $file | awk -v fname="$filename" '{print fname, $6}' >> "$output_file"

    # Run grep on each .out file, extract the first and seventh columns, and append to temp.txt
    # grep -i "final nof t" $file | awk '{print $0, $6}' >> 5.txt
done


