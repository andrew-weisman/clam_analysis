# Notes on CLAM

I installed CLAM in `/home/weismanal/notebook/2021-11-10/testing_clam`.

The environment file I created to install and run CLAM is `/home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh` (note this sets the `$CLAM` environment variable), and I should source this file to get CLAM working. Further notes are contained in that file.

I am testing execution of CLAM here: `working_dir="/home/weismanal/notebook/2021-11-11/testing_clam"`. Commands that I have run to generate files in this directory include (preprocessing):

```bash
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/default       --patch_size 256                                                                         --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-default.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_biopsy    --patch_size 256 --preset       $CLAM/presets/bwh_biopsy.csv                             --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_biopsy.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/bwh_resection --patch_size 256 --preset       $CLAM/presets/bwh_resection.csv                          --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-bwh_resection.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/tcga          --patch_size 256 --preset       $CLAM/presets/tcga.csv                                   --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-tcga.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/pinyi         --patch_size 256 --process_list $working_dir/inputs/process_list-preprocessing-pinyi.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-pinyi.log
python $CLAM/create_patches_fp.py --source $working_dir/data --save_dir $working_dir/results/pinyi-median  --patch_size 256 --preset       $working_dir/inputs/preprocessing-pinyi-median.csv       --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-pinyi-median.log
```

Testing with and without MRXS data directories:

```bash
python $CLAM/create_patches_fp.py --source $working_dir/data-with_data_dirs    --save_dir $working_dir/results/with_data_dirs    --patch_size 256 --process_list $working_dir/inputs/first_five.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-with_data_dirs.log
python $CLAM/create_patches_fp.py --source $working_dir/data-without_data_dirs --save_dir $working_dir/results/without_data_dirs --patch_size 256 --process_list $working_dir/inputs/first_five.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-without_data_dirs.log
```

The results seem to show that without the data directories, segmentation may be performed on some sort of thumbnail present in the `.mrxs` file itself and that while CLAM seems to work on `.mrxs` files, the associated data directories must be present.

Commands that I have run to get an interactive compute node include:

```bash
sinteractive --mem=20g --cpus-per-task=12
sinteractive --mem=20g --gres=gpu:k80:1 --cpus-per-task=12
```

To mount the Box drive in Windows somewhere accessible to WSL:

```bash
sudo mount -t drvfs 'C:\Users\weismanal\Box' /mnt/box
```

Note I have concluded that for the default and preset values (i.e., the first four calls to `create_patches_fp.py` above), the settings for each processed image in the columns of the produced `process_list_autogen.csv` files all have unique values. For all three sets of presets, the input `.csv` files have the extra fields `white_thresh` and `black_thresh`, which have values of 5 and 50. Finally, for the fields `seg_level` and `vis_level` for these three sets of presets, input values are always -1 and the output values are always 6. The inputs and outputs of all other fields are the same (and are of course generally different for each of the three sets).

Multiple-step process that I'd guess Pinyi is running, by example per the [CLAM GitHub page](https://github.com/mahmoodlab/CLAM):

```bash
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv                   # segmentation only using specific parameters
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv --patch --stitch  # subsequent entire workflow, i.e., segmentation, patching, and stitching; same set of commands as I ran above
```

Here are the commands I'm running for feature extraction:

```bash
python $CLAM/extract_features_fp.py --data_h5_dir $working_dir/results/pinyi --data_slide_dir $working_dir/data --csv_path $working_dir/inputs/process_list-feature_extraction-pinyi.csv --feat_dir $working_dir/results/pinyi/features --batch_size 512 --slide_ext .mrxs 2>&1 | tee $working_dir/logs/feature_extraction-pinyi.log
```

This used 9275MiB out of 16280MiB of GPU memory on a P100 GPU, so I can probably try increasing the batch size from 512 to 899 (exactly) or 880 (to be safe). I can also try using multiple GPUs simply by allocating more from SLURM; this should automatically work per the CLAM codebase.

I should note that Pinyi's segmentation parameters in his original `process_list_edited_slides_1-16.csv` file were based on downsampled `.ome.tif` files, so they may not apply as neatly to the `.mrxs` files; this is something to test.
