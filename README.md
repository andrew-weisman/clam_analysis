# Notes on CLAM

Note the following is based on going through the [CLAM GitHub page](https://github.com/mahmoodlab/CLAM) using the datafiles that Pinyi transferred to Biowulf at `/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined`.

## Compute node allocation

Commands that I have run to get an interactive compute node include:

```bash
sinteractive --mem=20g --cpus-per-task=12                   # for jobs not requiring a GPU, e.g., preprocessing
sinteractive --mem=20g --gres=gpu:k80:1 --cpus-per-task=12  # for jobs requiring a GPU, e.g., feature extraction
```

## Installation

I installed CLAM in `/home/weismanal/notebook/2021-11-10/testing_clam`.

The environment file I created to install and run CLAM is `/home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh` (note this sets the `$CLAM` environment variable), and I should source this file to get CLAM working. Further notes are contained in that file.

I.e., I need to run:

```bash
. /home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh
```

## Testing setup

I am testing execution of CLAM in `/home/weismanal/notebook/2021-11-11/testing_clam`. I have version-controlled this directory [here](https://github.com/andrew-weisman/clam_analysis) and I can start by opening the file you are reading, e.g., `/home/weismanal/notebook/2021-11-11/testing_clam/README.md`.

I.e., I need to run:

```bash
working_dir="/home/weismanal/notebook/2021-11-11/testing_clam"
```

## Preprocessing (i.e., patching)

While preprocessing includes the segmentation, patching, and stiching steps, the main point of preprocessing is to produce the patches.

Commands that I have run to generate files in the working directory include:

```bash
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/default       --patch_size 256                                                                         --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-default.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_biopsy    --patch_size 256 --preset       $CLAM/presets/bwh_biopsy.csv                             --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_biopsy.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_resection --patch_size 256 --preset       $CLAM/presets/bwh_resection.csv                          --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_resection.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/tcga          --patch_size 256 --preset       $CLAM/presets/tcga.csv                                   --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-tcga.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/pinyi         --patch_size 256 --process_list $working_dir/inputs/process_list-preprocessing-pinyi.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-pinyi.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/pinyi-median  --patch_size 256 --preset       $working_dir/inputs/preprocessing-pinyi-median.csv       --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-pinyi-median.log
```

Note I have concluded that for the default and preset values (i.e., the first four calls to `create_patches_fp.py` above), the settings for each processed image in the columns of the produced `process_list_autogen.csv` files all have unique values. For all three sets of presets, the input `.csv` files have the extra fields `white_thresh` and `black_thresh`, which have values of 5 and 50. Finally, for the fields `seg_level` and `vis_level` for these three sets of presets, input values are always -1 and the output values are always 6. The inputs and outputs of all other fields are the same (and are of course generally different for each of the three sets).

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
python $CLAM/extract_features_fp.py --data_h5_dir $working_dir/results/pinyi --data_slide_dir $working_dir/data --csv_path $working_dir/inputs/process_list-feature_extraction-pinyi.csv --feat_dir $working_dir/results/pinyi/features --batch_size 512 --slide_ext .mrxs 2>&1 | tee $working_dir/logs/feature_extraction-pinyi.log
```

This used 9275MiB out of 16280MiB of GPU memory on a P100 GPU, so I can probably try increasing the batch size from 512 to 899 (exactly) or 880 (to be safe). I can also try using multiple GPUs simply by allocating more from SLURM; this should automatically work per the CLAM codebase.

## Assumed directory structure

```bash
pinyi_data_dir=$working_dir/results/pinyi/features  # called something like $DATASET_3_DATA_DIR in the CLAM GH README, which contains the directories h5_files and pt_files generated by the feature extraction step
```

Note that the directory one level up (e.g., `$working_dir/results/pinyi`) is what the CLAM README calls `$DATA_ROOT_DIR`. So going forward I may want to set up symbolic links to adhere to this structure.

## Creation of labels file

Run this:

```bash
bash $working_dir/create_data_labels_for_clam.sh $working_dir
```

Note that this overwrites the current data labels file, e.g., `$working_dir/data_labels.csv`.

## CLAM codebase modification

The next steps in the CLAM procedure require modification to the CLAM codebase.

Note that the `task` argument to `$CLAM/main.py` corresponds to `idibell` and add the following block after the `elif args.task == 'task_2_tumor_subtyping':` block:

```python
elif args.task == 'idibell':
    args.n_classes=4
    working_dir = '/home/weismanal/notebook/2021-11-11/testing_clam'
    dataset_name = 'pinyi'
    dataset = Generic_MIL_Dataset(csv_path = os.path.join(working_dir, 'data_labels.csv'),
                            data_dir= os.path.join(working_dir, 'results', dataset_name, 'features'),
                            shuffle = False, 
                            seed = args.seed, 
                            print_info = True,
                            label_dict = {'pole': 0, 'msi': 1, 'lcn': 2, 'p53': 3},
                            label_col = 'label',
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

```python
elif args.task == 'idibell':
    args.n_classes=4
    working_dir = '/home/weismanal/notebook/2021-11-11/testing_clam'
    dataset = Generic_WSI_Classification_Dataset(csv_path = os.path.join(working_dir, 'data_labels.csv'),
                            shuffle = False, 
                            seed = args.seed, 
                            print_info = True,
                            label_dict = {'pole': 0, 'msi': 1, 'lcn': 2, 'p53': 3},
                            label_col = 'label',
                            patient_strat= True,
                            patient_voting='maj',
                            ignore=[])
```

and the modify the line

```python
parser.add_argument('--task', type=str, choices=['task_1_tumor_vs_normal', 'task_2_tumor_subtyping', 'idibell'])
```

## Data splitting

Run e.g.:

```bash
# In general
python $CLAM/create_splits_seq.py --task idibell --seed 1 --label_frac 1 --k 5 --val_frac 0.33 --test_frac 0.33 2>&1 | tee $working_dir/logs/data_splitting-label_frac1-k5-val_frac0.33-test_frac0.33.log

# My short test
python $CLAM/create_splits_seq.py --task idibell --seed 1 --label_frac 1 --k 2 --val_frac 0.33 --test_frac 0.33 2>&1 | tee $working_dir/logs/data_splitting-label_frac1-k2-val_frac0.33-test_frac0.33.log
```

## Training

Run e.g.:

```bash
# In general
python $CLAM/main.py --drop_out --early_stopping --lr 2e-4 --k 5 --label_frac 1 --exp_code idibell_CLAM_100 --weighted_sample --bag_loss ce --inst_loss svm --task idibell --model_type clam_sb --log_data --subtyping --data_root_dir $working_dir/results/pinyi --results_dir $working_dir/results/pinyi/training 2>&1 | tee $working_dir/logs/training-pinyi-100.log

# My short test
python $CLAM/main.py --max_epochs 3 --drop_out --early_stopping --lr 2e-4 --k 2 --label_frac 1 --exp_code idibell_CLAM_100_max_epochs_3_k_2 --weighted_sample --bag_loss ce --inst_loss svm --task idibell --model_type clam_sb --log_data --subtyping --data_root_dir $working_dir/results/pinyi --results_dir $working_dir/results/pinyi/training 2>&1 | tee $working_dir/logs/training-pinyi-100_max_epochs_3_k_2.log
```

## Other notes

### To mount the Box drive in Windows somewhere accessible to WSL

```bash
sudo mount -t drvfs 'C:\Users\weismanal\Box' /mnt/box
```

### To transfer data from Box to Biowulf

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
```

**Ensure for each script I look at the arguments that I can modify using the `-h` option.**
