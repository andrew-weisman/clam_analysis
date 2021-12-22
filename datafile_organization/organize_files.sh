#!/bin/bash

# Run from /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined

manifest_file="/home/weismanal/notebook/2021-11-11/testing_clam/parameter_comparison_and_manifest_creation_on_laptop/manifest.csv"

IFS_old=$IFS
IFS=$'\n'

for line in $(tail -n +2 $manifest_file | grep "Second Batch"); do
    parent_dir=$(echo "$line" | awk -v FS="," '{print $1}' | awk -v FS="/" '{print $(NF-1)}')
    basename=$(basename "$(echo "$line" | awk -v FS="," '{print $1}' | awk -v FS="/" '{print $(NF)}')" ".mrxs")
    mkdir "batch_002/$parent_dir"
    mv "$basename" "$basename.mrxs" "batch_002/$parent_dir"
done

IFS=$IFS_old
