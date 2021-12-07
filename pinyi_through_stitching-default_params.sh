#!/bin/bash

for image_basename in $(ls $private_project_dir/data/wsi/MRXScombined/*.mrxs | awk -v FS="/" '{print $NF}' | awk -v FS=".mrxs" '{print $1}'); do
    echo mkdir -p RESULTS_DIRECTORY/$image_basename
    echo python $CLAM/create_patches_fp.py --source /home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/ome-tiff/$image_basename --save_dir RESULTS_DIRECTORY/$image_basename --patch_size 256 --seg --patch --stitch
done
