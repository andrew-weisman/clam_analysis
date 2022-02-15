# Notes on CLAM

Note the following is based on going through the [CLAM GitHub page](https://github.com/mahmoodlab/CLAM).

## Transfer data from Box to Biowulf (on Helix)

After setting up `rclone` for use on Biowulf per [these instructions](https://hpc.nih.gov/docs/box_onedrive.html):

```bash
module load rclone
rclone config  # ONLY for rclone setup per above instructions
read -rs RCLONE_CONFIG_PASS
export RCLONE_CONFIG_PASS
cd /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined/
mkcd batch_003
rclone copy --progress box:"Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/Third Batch" .
mkcd ../batch_004
rclone copy --progress box:"Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/Fourth Batch" .
mkcd ../batch_005
rclone copy --progress box:"Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/Fifth Batch" .
mkcd ../batch_006
rclone copy --progress box:"Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/Sixth batch" .
mkcd ../batch_007
rclone copy --progress box:"Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/Seventh Batch" .
mkcd ../batch_008
rclone copy --progress box:"Research_collaboration-IDIBELL-NCI-FNL/MRXS Files/Eighth Batch" .
```

Note it appears that re-running these commands in e.g. a partially copied directory will not re-copy the files that are currently present, and `rclone` even seems to perform "Checks" on the existing files.

After performing the data copy, create links from the datafiles to the main data directory `/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined` by running from that directory:

```bash
bash /home/weismanal/projects/idibell/repo/datafile_organization/link_files.sh
```

Note this will re-create links to the files

```
DigitalSlide_B2M_1S_1
DigitalSlide_B2M_1S_1.mrxs
```

which I have moved to the directory `not_reading_by_openslide` because they do not appear to be readable by OpenSlide (I believe I am waiting on Eduard for help with this as well as other datafile issues; see my emails to him for details). So, I should delete these two files (the two links).

## Compute node allocation

Commands that I have run to get an interactive compute node include:

```bash
sinteractive --mem=5g --cpus-per-task=8                     # for jobs not requiring a GPU, e.g., preprocessing
sinteractive --mem=20g --gres=gpu:p100:1 --cpus-per-task=8  # for jobs requiring a GPU, e.g., feature extraction
sinteractive --mem=40g --gres=gpu:p100:1 --cpus-per-task=8  # heatmap generation requires at least 25g of memory, so choosing 40 to be safe
```

## Installation

I installed CLAM in `/home/weismanal/notebook/2021-11-10/testing_clam`.

The environment file I created to install and run CLAM is `/home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh` (note this sets the `$CLAM` environment variable), and I should source this file to get CLAM working. Further notes are contained in that file.

I.e., I need to run:

```bash
. /home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh
```

## Testing setup

I am testing execution of CLAM in `/home/weismanal/projects/idibell/repo`. I have version-controlled this directory [here](https://github.com/andrew-weisman/clam_analysis) and I can start by opening the file you are reading, e.g., `/home/weismanal/projects/idibell/repo/README.md`.

I.e., I need to run:

```bash
working_dir="/home/weismanal/projects/idibell/repo"
```

## Preprocessing (i.e., patching)

While preprocessing includes the segmentation, patching, and stiching steps, the main point of preprocessing is to produce the patches.

Commands that I have run to generate files in the working directory include:

```bash

# Latest command - this is the best preset Eduard currently suggests based on the first two batches of data
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_resection --patch_size 256 --preset       $CLAM/presets/bwh_resection.csv                          --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_resection-all_55_wsis.log

# Previous commands
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/default       --patch_size 256                                                                         --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-default.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_biopsy    --patch_size 256 --preset       $CLAM/presets/bwh_biopsy.csv                             --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_biopsy.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_resection --patch_size 256 --preset       $CLAM/presets/bwh_resection.csv                          --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_resection.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/tcga          --patch_size 256 --preset       $CLAM/presets/tcga.csv                                   --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-tcga.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/pinyi         --patch_size 256 --process_list $working_dir/inputs/process_list-preprocessing-pinyi.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-pinyi.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/pinyi-median  --patch_size 256 --preset       $working_dir/inputs/preprocessing-pinyi-median.csv       --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-pinyi-median.log
```

Note I have concluded (looking at the "Previous commands") that for the default and preset values (i.e., the first four calls to `create_patches_fp.py` above), the settings for each processed image in the columns of the produced `process_list_autogen.csv` files all have unique values. For all three sets of presets, the input `.csv` files have the extra fields `white_thresh` and `black_thresh`, which have values of 5 and 50. Finally, for the fields `seg_level` and `vis_level` for these three sets of presets, input values are always -1 and the output values are always 6. The inputs and outputs of all other fields are the same (and are of course generally different for each of the three sets).

Multiple-step process for preprocessing that I believe Pinyi basically ran, by example per the CLAM GitHub page:

```bash
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv --patch --stitch  # entire preprocessing workflow, i.e., segmentation, patching, and stitching; same set of commands as I ran above
```

This command is indeed what [Pinyi ultimately ran](./pinyis_snakemake_pipeline.md) using the Snakemake keyword `patch_stitch`.

I should note that Pinyi's segmentation parameters in his original `process_list_edited_slides_1-16.csv` file were based on downsampled `.ome.tif` files, so they may not apply as neatly to the `.mrxs` files; this is something I indeed confirmed below.

For testing with and without MRXS data directories:

```bash
python $CLAM/create_patches_fp.py --source $working_dir/data-with_data_dirs    --save_dir $working_dir/results/with_data_dirs    --patch_size 256 --process_list $working_dir/inputs/first_five.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-with_data_dirs.log
python $CLAM/create_patches_fp.py --source $working_dir/data-without_data_dirs --save_dir $working_dir/results/without_data_dirs --patch_size 256 --process_list $working_dir/inputs/first_five.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-without_data_dirs.log
```

The testing results seem to show that without the data directories, segmentation may be performed on some sort of thumbnail present in the `.mrxs` file itself and that while CLAM seems to work on `.mrxs` files, the associated data directories must be present.

## Stitching comparisons

Upon observing the results of the masks and stitches on the `.ome.tif` files, I see that unfortunately just as for the `.mrxs` files the JPEGs of the stiches looked reasonable but the masks looked bad (strange black grid on top of the images), for the `.ome.tif` files the JPEGs of the masks look reasonable but the stitches look bad in the same exact way, rendering impossible visual comparison between the stitches. However, I have pointed the stiches on the `.ome.tif`s to the corresponding masks and used those instead for comparison in the image gallery which I generated using

```bash
bash create_stitches_gallery.sh "pinyi-on-tif-files default bwh_biopsy  bwh_resection tcga  pinyi  pinyi-median"
```

after first backing up and resizing all stitches using

```bash
bash resize_stitches.sh
```

## Feature extraction

Here are the commands I'm running for feature extraction:

```bash

# Latest commands
cp $working_dir/results/bwh_resection/process_list_autogen.csv $working_dir/inputs/process_list-feature_extraction-bwh_resection.csv
emacs -nw $working_dir/inputs/process_list-feature_extraction-bwh_resection.csv  # then I replaced all occurrences of ".mrxs," with "," per the GH instructions
python $CLAM/extract_features_fp.py --data_h5_dir $working_dir/results/bwh_resection --data_slide_dir $working_dir/data --csv_path $working_dir/inputs/process_list-feature_extraction-bwh_resection.csv --feat_dir $working_dir/results/bwh_resection/features --batch_size 880 --slide_ext .mrxs 2>&1 | tee $working_dir/logs/feature_extraction-bwh_resection-all_55_wsis.log

# Previous command
python $CLAM/extract_features_fp.py --data_h5_dir $working_dir/results/pinyi --data_slide_dir $working_dir/data --csv_path $working_dir/inputs/process_list-feature_extraction-pinyi.csv --feat_dir $working_dir/results/pinyi/features --batch_size 512 --slide_ext .mrxs 2>&1 | tee $working_dir/logs/feature_extraction-pinyi.log
```

This used (for the "Previous command") 9275MiB out of 16280MiB of GPU memory on a P100 GPU, so I can probably try increasing the batch size from 512 to 899 (exactly) or 880 (to be safe). I can also try using multiple GPUs simply by allocating more from SLURM; this should automatically work per the CLAM codebase.

For the "Latest comands" step in which I increased the batch size to 880, now 15439MiB out of 16280MiB of GPU memory is being used on a P100 GPU (94.8% memory utilization), so indeed the increase of batch size seems to work as expected.

## Assumed directory structure

```bash
pinyi_data_dir=$working_dir/results/pinyi/features  # called something like $DATASET_3_DATA_DIR in the CLAM GH README, which contains the directories h5_files and pt_files generated by the feature extraction step
```

Note that the directory one level up (e.g., `$working_dir/results/pinyi`) is what the CLAM README calls `$DATA_ROOT_DIR`. So going forward I may want to set up symbolic links to adhere to this structure.

This variable is not actually needed anywhere in this document as of 12/28/21.

## Creation of labels file

First, mount the Box drive in Windows somewhere accessible to WSL:

```bash
sudo mount -t drvfs 'C:\Users\weismanal\Box' /mnt/box
```

Create the manifest file `$working_dir/parameter_comparison_and_manifest_creation_on_laptop/manifest.csv`, e.g., run on my laptop in the directory `parameter_comparison_and_manifest_creation_on_laptop`

```bash
bash create_manifest.sh
```

and move the created `manifest.csv` file to `$working_dir/parameter_comparison_and_manifest_creation_on_laptop` on Biowulf.

Run this:

```bash
bash $working_dir/create_data_labels_for_clam.sh $working_dir
```

This will create the data labels file `$working_dir/data_labels.csv` if it doesn't already exist (and won't overwrite an existing file).

**Don't forget to delete the lines in /home/weismanal/projects/idibell/repo/data_labels.csv whose corresponding .pt files do not exist at this point (if any, and they would only be in the 7th and 8th batches)!**

## CLAM codebase modification

The next steps in the CLAM procedure require modification to the CLAM codebase.

Note that the `task` argument to `$CLAM/main.py` corresponds to `idibell` and add the following block after the `elif args.task == 'task_2_tumor_subtyping':` block:

**UPDATE THE LINE BELOW!!!!**

```python
elif args.task == 'idibell':
    args.n_classes=4
    working_dir = '/home/weismanal/projects/idibell/repo'  # UPDATE THIS LINE!!!!
    dataset_name = 'bwh_resection'
    label_dict = {'pole': 0, 'msi': 1, 'lcn': 2, 'p53': 3}
    label_col = 'label'
    dataset = Generic_MIL_Dataset(csv_path = os.path.join(working_dir, 'data_labels.csv'),
                            data_dir= os.path.join(working_dir, 'results', dataset_name, 'features'),
                            shuffle = False, 
                            seed = args.seed, 
                            print_info = True,
                            label_dict = label_dict,
                            label_col = label_col,
                            patient_strat= False,
                            ignore=[])

    if args.model_type in ['clam_sb', 'clam_mb']:
        assert args.subtyping
```

Add this "task" to the arguments in `main.py` like:

```python
parser.add_argument('--task', type=str, choices=['task_1_tumor_vs_normal',  'task_2_tumor_subtyping', 'idibell'])
```

Likewise, to `$CLAM/create_splits_seq.py` add the block

**UPDATE THE LINE BELOW!!!!**

```python
elif args.task == 'idibell':
    args.n_classes=4
    working_dir = '/home/weismanal/projects/idibell/repo'  # UPDATE THIS LINE!!!!
    label_dict = {'pole': 0, 'msi': 1, 'lcn': 2, 'p53': 3}
    label_col = 'label'
    dataset = Generic_WSI_Classification_Dataset(csv_path = os.path.join(working_dir, 'data_labels.csv'),
                            shuffle = False, 
                            seed = args.seed, 
                            print_info = True,
                            label_dict = label_dict,
                            label_col = label_col,
                            patient_strat= True,
                            patient_voting='maj',
                            ignore=[])
```

and the modify the line

```python
parser.add_argument('--task', type=str, choices=['task_1_tumor_vs_normal', 'task_2_tumor_subtyping', 'idibell'])
```

Likewise, to `$CLAM/eval.py` add the block

**UPDATE THE LINE BELOW!!!!**

```python
elif args.task == 'idibell':
    args.n_classes = 4
    working_dir = '/home/weismanal/projects/idibell/repo'  # UPDATE THIS LINE!!!!
    dataset_name = 'bwh_resection'
    label_dict = {'pole': 0, 'msi': 1, 'lcn': 2, 'p53': 3}
    dataset = Generic_MIL_Dataset(csv_path = os.path.join(working_dir, 'data_labels.csv'),
                            data_dir= os.path.join(working_dir, 'results', dataset_name, 'features'),
                            shuffle = False, 
                            print_info = True,
                            label_dict = label_dict,
                            patient_strat= False,
                            ignore=[])
```

and modify the line

```python
parser.add_argument('--task', type=str, choices=['task_1_tumor_vs_normal',  'task_2_tumor_subtyping', 'idibell'])
```

## Data splitting

Run e.g.:

```bash
# In general
python $CLAM/create_splits_seq.py --task idibell --seed 1 --label_frac 1 --k 5 --val_frac 0.15 --test_frac 0.15 2>&1 | tee $working_dir/logs/data_splitting-label_frac1-k5-val_frac0.15-test_frac0.15.log

# My short test
python $CLAM/create_splits_seq.py --task idibell --seed 1 --label_frac 1 --k 2 --val_frac 0.33 --test_frac 0.33 2>&1 | tee $working_dir/logs/data_splitting-label_frac1-k2-val_frac0.33-test_frac0.33.log
```

## Training

Run e.g.:

```bash
# In general
python $CLAM/main.py --drop_out --early_stopping --lr 2e-4 --k 5 --label_frac 1 --exp_code idibell_CLAM_100 --weighted_sample --bag_loss ce --inst_loss svm --task idibell --model_type clam_sb --log_data --subtyping --data_root_dir $working_dir/results/bwh_resection --results_dir $working_dir/results/bwh_resection/training 2>&1 | tee $working_dir/logs/training-bwh_resection-100.log

# My short test
python $CLAM/main.py --max_epochs 3 --drop_out --early_stopping --lr 2e-4 --k 2 --label_frac 1 --exp_code idibell_CLAM_100_max_epochs_3_k_2 --weighted_sample --bag_loss ce --inst_loss svm --task idibell --model_type clam_sb --log_data --subtyping --data_root_dir $working_dir/results/pinyi --results_dir $working_dir/results/pinyi/training 2>&1 | tee $working_dir/logs/training-pinyi-100_max_epochs_3_k_2.log
```

## Evaluation

```bash
python $CLAM/eval.py --drop_out --k 5 --models_exp_code idibell_CLAM_100_s1 --save_exp_code idibell_CLAM_100_s1_cv --task idibell --model_type clam_sb --results_dir $working_dir/results/bwh_resection/training --data_root_dir $working_dir/results/bwh_resection 2>&1 | tee $working_dir/logs/evaluation-bwh_resection-100.log

# Since the current directory is hardcoded for storing the results:
mv $working_dir/eval_results $working_dir/results/bwh_resection
```

## Heatmap generation

Create the file `$working_dir/inputs/heatmap_settings.yaml` from the template `$CLAM/heatmaps/configs/config_template.yaml`.

Run

```bash
# Create the main heatmaps folder in the working directory specifically
mkdir $working_dir/heatmaps
cd !!:1

# Create the required three subfolders
mkdir configs demo process_lists

# Populate the configs subdirectory
ln -s $working_dir/inputs/heatmap_settings.yaml configs/

# Populate the demo subdirectory
cd demo
ln -s $working_dir/data slides
mkdir ckpts
ln -s $working_dir/results/bwh_resection/training/idibell_CLAM_100_s1/s_4_checkpoint.pt ckpts/s_4_checkpoint.pt

# Populate the process_lists subdirectory
cd ..
ln -s $working_dir/data_labels.csv process_lists/data_labels.csv

# Go back to the working directory
cd $working_dir
```

since using absolute paths in the heatmap settings YAML file with my own directory structure proved to have multiple issues due to how the CLAM codebase is set up.

Run:

```bash
python $CLAM/create_heatmaps.py --config $working_dir/heatmaps/configs/heatmap_settings.yaml 2>&1 | tee $working_dir/logs/heatmaps-bwh_resection-100.log
```

On a P100 GPU this uses 7127MiB / 16280MiB for a batch size (set in the YAML file) of 384, so I should increase the batch size to 868 for nearly 99% usage instead of 44%.
