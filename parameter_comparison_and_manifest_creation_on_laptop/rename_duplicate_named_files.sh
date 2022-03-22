#!/bin/bash

# Run this after creating manifest.csv

grep -v "/Hysterectomy specimens/" manifest.csv > tmp.csv
grep "/Hysterectomy specimens/" manifest.csv | awk '{gsub(".mrxs", "-hysterectomy.mrxs"); print}' >> tmp.csv
mv tmp.csv manifest.csv
