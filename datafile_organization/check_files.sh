#!/bin/bash

# Run from /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined

manifest_file_local="/home/weismanal/notebook/2021-11-11/testing_clam/parameter_comparison_and_manifest_creation_on_laptop/manifest-local.csv"

IFS_old=$IFS
IFS=$'\n'

for line in $(tail -n +1 $manifest_file_local); do
    file=$(echo "$line" | awk -v FS="," '{print $1}')
    ls "$file"
done

IFS=$IFS_old
