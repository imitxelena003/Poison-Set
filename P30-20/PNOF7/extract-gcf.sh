#!/bin/bash

output_dir="./gcf"

# Find all .out files in subdirectories and process each file
find . -type f -name "*.gcf" | while read file; do

    # Search for "energy" in the file (case-insensitive). Extract the 7th column and write to temp.txt
    cp $file $output_dir

    # Run grep on each .out file, extract the first and seventh columns, and append to temp.txt
    # grep -i "final nof t" $file | awk '{print $0, $6}' >> 5.txt
done

