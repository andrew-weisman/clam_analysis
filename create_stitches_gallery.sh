#!/bin/bash

# Call like, e.g.:
#   bash create_stitches_gallery.sh "bwh_biopsy bwh_resection tcga"

# Function for creating HTML code containing table comparing images in different datasets
function make_website() {

    # Function parameter
    datasets="$1"

    # Determine the number of datasets and the images from the dataset list
    ndatasets=$(echo "$datasets" | awk '{print NF}')
    images=$(ls "results/$(echo "$datasets" | awk '{print $1}')/stitches")

    # Create HTML code
    echo "<html><head><title>Comparison of datasets: $datasets</title></head><body>"
    echo "  <table border=1>"
    tarfile_contents="stitches_gallery.html"
    for image in $images; do
        # Image label row
        echo "    <tr><td colspan=\"$ndatasets\" align=\"center\">$image</td></tr>"

        # Dataset label row
        echo "    <tr>"
        for dataset in $datasets; do
            echo "      <td align=\"center\">$dataset</td>"
        done
        echo "    </tr>"

        # Actual image row
        echo "    <tr>"
        for dataset in $datasets; do
            echo "      <td><img src=\"results/$dataset/stitches/$image\" width=800></td>"
            tarfile_contents="$tarfile_contents results/$dataset/stitches/$image"
        done
        echo "    </tr>"
    done
    echo "  </table>"
    echo "</body></html>"
    echo "$tarfile_contents" > tarfile_contents.txt

}

# Script parameter
datasets="$1"

# Create the HTML code and send it to an HTML file
make_website "$datasets" > stitches_gallery.html

# Tar up the resulting website
#tar -czvf ~/transfer/website.tar.gz $(cat tarfile_contents.txt)
zip ~/transfer/website $(cat tarfile_contents.txt)

# Delete the temporary file
rm -f tarfile_contents.txt
