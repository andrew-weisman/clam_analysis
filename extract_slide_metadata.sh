#!/bin/bash

# Extract selected metadata from all images linked in the data directory
#
# Run like:
#
#   bash extract_slide_metadata.sh > slide_metadata-2022-03-23.csv
#

# Set up environment
source /data/weismanal/miniconda3/etc/profile.d/conda.sh
. /home/weismanal/projects/idibell/links/clam_installation/clam_env.sh
working_dir="/home/weismanal/projects/idibell/repo"

# Determine the keywords whose values we want to collect from each slide using openslide
keywords="mirax.GENERAL.ADAPTER_SIZE mirax.GENERAL.CAMERA_TYPE mirax.GENERAL.OBJECTIVE_MAGNIFICATION mirax.GENERAL.OBJECTIVE_NAME mirax.GENERAL.OUTPUT_RESOLUTION mirax.GENERAL.PROJECT_NAME mirax.GENERAL.SLIDE_CREATIONDATETIME mirax.GENERAL.SLIDE_TYPE mirax.LAYER_0_LEVEL_0_SECTION.MICROMETER_PER_PIXEL_X mirax.LAYER_0_LEVEL_0_SECTION.MICROMETER_PER_PIXEL_Y mirax.NONHIERLAYER_1_SECTION.SCANNER_CAMERA_TYPE mirax.NONHIERLAYER_1_SECTION.SCANNER_HARDWARE_VERSION openslide.bounds-height openslide.bounds-width openslide.mpp-x openslide.mpp-y openslide.objective-power openslide.vendor"

# Determine a good header line from the keywords; the grep method is dangerous because the keywords can switch orders; that's why I don't use it below anymore
# The following line is copied-pasted from:
#   bash extract_slide_metadata.sh | awk -v FS=": " '{print $1}' | awk -v FS=. -v ORS=, '{gsub("-", "_"); print tolower($NF)}'
# when the main contents were:
#   image_pathname="$working_dir/data/BB150007349-A-01-001.mrxs"
#   echo "image_pathname: '$image_pathname'"
#   openslide-show-properties $image_pathname 2> /dev/null | grep -E "^mirax.GENERAL.ADAPTER_SIZE:\ |^mirax.GENERAL.CAMERA_TYPE:\ |^mirax.GENERAL.OBJECTIVE_MAGNIFICATION:\ |^mirax.GENERAL.OBJECTIVE_NAME:\ |^mirax.GENERAL.OUTPUT_RESOLUTION:\ |^mirax.GENERAL.PROJECT_NAME:\ |^mirax.GENERAL.SLIDE_CREATIONDATETIME:\ |^mirax.GENERAL.SLIDE_TYPE:\ |^mirax.LAYER_0_LEVEL_0_SECTION.MICROMETER_PER_PIXEL_X:\ |^mirax.LAYER_0_LEVEL_0_SECTION.MICROMETER_PER_PIXEL_Y:\ |^mirax.NONHIERLAYER_1_SECTION.SCANNER_CAMERA_TYPE:\ |^mirax.NONHIERLAYER_1_SECTION.SCANNER_HARDWARE_VERSION:\ |^openslide.bounds-height:\ |^openslide.bounds-width:\ |^openslide.mpp-x:\ |^openslide.mpp-y:\ |^openslide.objective-power:\ |^openslide.vendor:\ "
header_line="image_pathname,adapter_size,camera_type,objective_magnification,objective_name,output_resolution,project_name,slide_creationdatetime,slide_type,micrometer_per_pixel_x,micrometer_per_pixel_y,scanner_camera_type,scanner_hardware_version,bounds_height,bounds_width,mpp_x,mpp_y,objective_power,vendor"

# Print out the header line
echo $header_line

# Enter the working directory
cd $working_dir || exit 1

# Loop through all the linked images
for filename in $(ls -l data/ | grep ^l | awk '{print $9}' | grep "\." | head -n 4); do

    # Obtain the full pathname
    # image_pathname="$working_dir/data/BB150007349-A-01-001.mrxs"
    # image_pathname="$working_dir/data/DigitalSlide_B1M_2S_1.mrxs"
    image_pathname="$working_dir/data/$filename"

    # Get properties of the image using openslide
    if openslide-show-properties "$image_pathname" 2> /dev/null > tmp.txt; then

        # Get the desired fields for the current image from its metadata
        data_line0="$image_pathname,"
        for keyword in $keywords; do
            if matching_line=$(grep -E "^${keyword}:\ " tmp.txt); then
                value=$(echo "$matching_line" | awk -v FS=": " '{gsub(/\047/, ""); print $2}')
            else
                value=  # account for the keyword not always existing
            fi
            data_line0="${data_line0}${value},"
        done
        data_line=${data_line0:0:${#data_line0}-1}

        # Print out the desired image data
        echo "$data_line"

    fi

done
