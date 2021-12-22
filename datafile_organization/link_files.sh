#!/bin/bash

# Run from /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined

IFS_old=$IFS
IFS=$'\n'

for line in $(find . -iname "*.mrxs"); do
    file="$line"
    dir="$(echo $file | awk -v FS=".mrxs" '{print $1}')"
    ln -s "$file"
    ln -s "$dir"
done

IFS=$IFS_old
