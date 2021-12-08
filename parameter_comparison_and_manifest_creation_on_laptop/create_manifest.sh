IFS=$'\n'
ls -ltr $(find /mnt/box -iname "*.mrxs") | awk -v FS=" /mnt/box/Research_collaboration-IDIBELL" '{printf("./Research_collaboration-IDIBELL%s\n", $2)}' > filenames.txt
for file in $(cat filenames.txt); do echo $file | rev | awk -v FS="/" '{print $2}' | awk '{print $1}' | rev; done > labels.txt
echo "filename,label" > manifest.csv
paste -d, filenames.txt labels.txt >> manifest.csv
echo "Note: Reorder entries in manifest.csv manually into the appropriate batch order"
echo "Number of images: $(wc -l filenames.txt | awk '{print $1}')"
labels=$(cat labels.txt | sort -u | awk -v ORS=", " '{print}')
echo "Unique labels: ${labels:0:${#labels}-2}"

# Current output:
# Number of images: 40
# Unique labels: LCN, MSI, POLE, p53

# Helpful for determining that adjacent to each .mrxs file is a single .qpdata file:
# for filename in $(cat manifest.csv | tail -n +2 | awk -v FS="," '{print $1}'); do find "/mnt/box/$(dirname $filename)" -maxdepth 1 -name "*.qpdata" | wc -l; done