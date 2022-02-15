#!/bin/bash

# This implements basically what Pinyi said to do for this project including the stitching step, but using my installation of CLAM, which seemed to work. I needed to use my version of CLAM; without it (using his), I got the same error he got. This uses the parameters Pinyi determined were best for the images that were converted to TIF rather than the default parameters.

for image_basename in $(ls $private_project_dir/data/wsi/MRXScombined/*.mrxs | awk -v FS="/" '{print $NF}' | awk -v FS=".mrxs" '{print $1}'); do
    /data/BIDS-HPC/public/software/QuPath-0.2.3/bin/QuPath-0.2.3 convert-ome --overwrite -d 30 -c UNCOMPRESSED $private_project_dir/data/wsi/MRXScombined/$image_basename.mrxs ome-tiff/$image_basename/$image_basename.ome.tif
    mkdir -p RESULTS_DIRECTORY/$image_basename
    (head -n 1 $private_project_dir/process_list_edited_slides_1-16.csv; grep "^$image_basename.ome.tif" $private_project_dir/process_list_edited_slides_1-16.csv) > RESULTS_DIRECTORY/$image_basename/process_list_edited-$image_basename.csv
    python $CLAM/create_patches_fp.py --source ome-tiff/$image_basename --save_dir RESULTS_DIRECTORY/$image_basename --process_list process_list_edited-$image_basename.csv --patch_size 256 --seg --patch --stitch
done
