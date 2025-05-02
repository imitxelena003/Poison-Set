rectory containing the .inp files
DIRECTORY="./"  # Change this to the desired directory if needed

# Loop through all .inp files in the directory
for file in "$DIRECTORY"/*.inp; do
  # Check if the file exists
  if [[ -f "$file" ]]; then
    # Use sed to replace 'def2-svp' with 'def2-qzvp' only on the fourth line
    sed -i '4s/\bdef2-svp\b/def2-qzvp/' "$file"
    echo "Updated $file"
  else
    echo "No .inp files found in the directory."
  fi
done
