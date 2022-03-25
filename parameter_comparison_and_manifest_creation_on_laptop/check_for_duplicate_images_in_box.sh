#!/bin/bash

# Set the field separator to take care of spaces in filenames
IFS_old=$IFS
IFS=$'\n'

# Local directory containing mount of the Box files
mrxs_files_dir="/mnt/box/Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/"

# Output the directories that have multiple .mrxs files in them
diff <(for file in $(find $mrxs_files_dir -iname "*.mrxs" | grep -v "/Hysterectomy specimens"); do dirname $file; done | sort) <(for file in $(find $mrxs_files_dir -iname "*.mrxs" | grep -v "/Hysterectomy specimens"); do dirname $file; done | sort -u)

# Print out what to do if any are found
echo "If there are any directories listed above, there are multiple .mrxs files in them. See what's going on, likely deleting the ones that are unreadable by openslide."
