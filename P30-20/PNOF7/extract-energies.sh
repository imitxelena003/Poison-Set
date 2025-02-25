#!/bin/bash

output_file="energies.txt"
> "$output_file"

# Find all ".out" files
find . -type f -name "*.out" | while read file; do
    # Get the base filename without extension
    filename=$(basename "$file" .out)

    # Extract the key (substring between the second "_" and ".")
    key=$(echo "$filename" | awk -F'[_.]' '{print $3}')

    # Extract energy from the ".out" file
    energy=$(grep -i "final nof t" "$file" | awk '{print $6}')

    if [[ -n "$energy" ]]; then
        # Write the energy for the ".out" file to the output file
        echo "$filename $energy" >> "$output_file"

        # Find matching ".inp" files with the same key
        find . -type f -name "*.inp" | while read inp_file; do
            inp_filename=$(basename "$inp_file" .inp)
            inp_key=$(echo "$inp_filename" | awk -F'[_.]' '{print $3}')

            # If the key matches, write the ".inp" file and energy to the output
            if [[ "$key" == "$inp_key" ]]; then
                echo "$inp_filename $energy" >> "$output_file"
            fi
        done
    fi
done


