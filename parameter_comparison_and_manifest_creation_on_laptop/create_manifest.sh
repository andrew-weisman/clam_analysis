# Note: Must first run "sudo mount -t drvfs 'C:\Users\weismanal\Box' /mnt/box" on work laptop

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
# Number of images: 56
# Unique labels: LCN, MSI, POLE, p53

# Helpful for determining that adjacent to each .mrxs file is a single .qpdata file:
# for filename in $(cat manifest.csv | tail -n +2 | awk -v FS="," '{print $1}'); do find "/mnt/box/$(dirname $filename)" -maxdepth 1 -name "*.qpdata" | wc -l; done

# Output as of 2/14/22:
# weismanal@NCI-02196596-L:~/notebook/2022-02-14/idibell_manifest_creation/repo/parameter_comparison_and_manifest_creation_on_laptop$ bash create_manifest.sh
# Note: Reorder entries in manifest.csv manually into the appropriate batch order
# Number of images: 73
# Unique labels: LCN, MSI, POLE, p53
