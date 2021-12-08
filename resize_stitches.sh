#!/bin/bash

for dir in results/*; do
    pushd $dir/stitches
    mkdir orig_quality
    cp *.jpg orig_quality/
    mogrify -resize 800 *.jpg
    popd
done
