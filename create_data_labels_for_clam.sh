#!/bin/bash

# Run this like:
#   bash $working_dir/create_data_labels_for_clam.sh $working_dir

# Function to write the correctly formatted CSV file per https://github.com/mahmoodlab/CLAM
write_data_labels() {
    manifest_path="$1"
    echo "case_id,slide_id,label"
    tail -n +2 "$manifest_path" | awk -v FS="/" '{print $NF}' | awk -v FS="," '{split($1, arr, ".mrxs"); basename=arr[1]; label=tolower($2); printf("%s,%s,%s\n", basename, basename, label)}'
}

# Set the incoming parameters to variable names
#working_dir="/home/weismanal/notebook/2021-11-11/testing_clam"
working_dir="$1"

# Determine some pathnames
csv_path="$working_dir/data_labels.csv"  # CSV file to be created
manifest_path="$working_dir/parameter_comparison_and_manifest_creation_on_laptop/manifest.csv"  # note this was created on my laptop; see $working_dir/parameter_comparison_and_manifest_creation_on_laptop/create_manifest.sh

# Write the CSV file
if [ ! -f "$csv_path" ]; then
    write_data_labels "$manifest_path" > "$csv_path" && echo "Success! Don't forget to delete the lines in the produced $csv_path whose corresponding .pt files do not yet exist!" || echo "ERROR: $csv_path not created; see error(s) above"
else
    echo "ERROR: $csv_path already exists!"
fi
