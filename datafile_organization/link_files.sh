#!/bin/bash

# This script should be run after transferring files to Biowulf from Box using rclone, creating symbolic links in the main data directory from thoes in the individual batch folders

# Run from /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined like `bash /home/weismanal/projects/idibell/repo/datafile_organization/link_files.sh`

IFS_old=$IFS
IFS=$'\n'

for line in $(find . -iname "*.mrxs"); do
    file="$line"
    dir="$(echo $file | awk -v FS=".mrxs" '{print $1}')"
    ln -s "$file"
    ln -s "$dir"
done

IFS=$IFS_old
