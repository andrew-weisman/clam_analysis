#!/bin/bash

# Make sure that every file in the manifest is present in the data directory. Actually, not every file may be, e.g., one in the directory "not_reading_by_openslide". This was probably an old sanity-check script that I probably shouldn't make part of the regular workflow; so, don't run this file regularly!

# Run from /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined

# manifest_file_local="/home/weismanal/notebook/2021-11-11/testing_clam/parameter_comparison_and_manifest_creation_on_laptop/manifest-local.csv"
manifest_file="/home/weismanal/projects/idibell/repo/parameter_comparison_and_manifest_creation_on_laptop/manifest.csv"

IFS_old=$IFS
IFS=$'\n'

for line in $(tail -n +2 $manifest_file); do
    # file=$(echo "$line" | awk -v FS="," '{print $1}')
    file=$(basename "$(echo "$line" | awk -v FS="," '{print $1}')")
    # echo $file
    ls "$file"
done

IFS=$IFS_old
