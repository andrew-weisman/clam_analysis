#!/bin/bash

# This implements basically what Pinyi said to do for this project including the stitching step, but using my installation of CLAM, which seemed to work. I needed to use my version of CLAM; without it (using his), I got the same error he got. This uses the default parameters as opposed to the ones he determined were best for the images that were converted to TIF.

for image_basename in $(ls $private_project_dir/data/wsi/MRXScombined/*.mrxs | awk -v FS="/" '{print $NF}' | awk -v FS=".mrxs" '{print $1}'); do
    echo mkdir -p RESULTS_DIRECTORY/$image_basename
    echo python $CLAM/create_patches_fp.py --source /home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/ome-tiff/$image_basename --save_dir RESULTS_DIRECTORY/$image_basename --patch_size 256 --seg --patch --stitch
done
