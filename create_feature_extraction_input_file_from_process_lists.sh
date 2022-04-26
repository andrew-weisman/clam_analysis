#!/bin/bash

# This script assumes files like filenames_of_*x.csv exist in the current directory as, say, inputs into the patching script create_patches_fp.py, concatenates them, and removes the image file extensions as needed by extract_features_fp.py

# Get the process lists that were likely inputs for the patching script
process_lists=$(ls filenames_of_*x.csv)
arr=($process_lists)  # get an array version of the process lists; note $process_lists should not be quoted

# Constant: this is the output of this script, which should be input into the feature extraction script of CLAM
output_file="feature_extraction_input.csv"

# Extract the header line, which should be the same in all process lists
head -n 1 "${arr[0]}" > "$output_file"

# For each process list, extract all but the header line, removing the image file extensions at the same time
for process_list in $process_lists; do
    tail -n +2 "$process_list" | awk '{gsub(".mrxs,", ","); print}'
done >> "$output_file"
