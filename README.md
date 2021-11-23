# Notes on CLAM

I installed it in the directory containing this README (`/home/weismanal/notebook/2021-11-10/testing_clam`).

The environment file I created to install and run CLAM is `/home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh`, and I should source this file to get CLAM working. Further notes are contained in this file.

I am testing execution of CLAM here: `working_dir="/home/weismanal/notebook/2021-11-11/testing_clam"`. Commands that I have run to generate files in this directory include (preprocessing):

```bash
python $CLAM/create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY-bwh_biopsy --patch_size 256 --preset $CLAM/presets/bwh_biopsy.csv --seg --patch --stitch 2>&1 | tee initial_processing_output-bwh_biopsy.txt
python $CLAM/create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY-bwh_resection --patch_size 256 --preset $CLAM/presets/bwh_resection.csv --seg --patch --stitch 2>&1 | tee initial_processing_output-bwh_resection.txt
python $CLAM/create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY-tcga --patch_size 256 --preset $CLAM/presets/tcga.csv --seg --patch --stitch 2>&1 | tee initial_processing_output-tcga.txt
python $CLAM/create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY-pinyi --patch_size 256 --process_list $working_dir/process_list_edited_slides_1-16.csv --seg --patch --stitch 2>&1 | tee initial_processing_output-pinyi.txt
python $CLAM/create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY-pinyi-median --patch_size 256 --preset $working_dir/pinyi-median.csv --seg --patch --stitch 2>&1 | tee initial_processing_output-pinyi-median.txt
```

Commands that I have run to get an interactive compute node include:

```bash
sinteractive --mem=20g --cpus-per-task=12
sinteractive --mem=20g --gres=gpu:k80:1 --cpus-per-task=12
```

The parameters file, `$working_dir/process_list_edited_slides_1-16.csv`, that I am using for generating the "pinyi" results is originally a copy from `/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/process_list_edited_slides_1-16.csv`. I am changing the files run from `*.ome.tif` to `*.mrxs`.

To mount the Box drive in Windows somewhere accessible to WSL:

```bash
sudo mount -t drvfs 'C:\Users\weismanal\Box' /mnt/box
```

Note I have concluded that for the default and preset values, the settings for each processed image in the columns of the produced `process_list_autogen.csv` files have unique values. For all three sets of presets, the input `.csv` files have the extra fields `white_thresh` and `black_thresh`, which have values of 5 and 50. Finally, for the fields `seg_level` and `vis_level` for these three sets of presets, input values are always -1 and the output values are always 6. The inputs and outputs of all other fields are the same (and are of course generally different for each of the three sets).

Multiple-step process that I'd guess Pinyi is running, by example per the [CLAM GitHub page](https://github.com/mahmoodlab/CLAM):

```bash
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv                   # segmentation only using specific parameters
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv --patch --stitch  # subsequent entire workflow, i.e., segmentation, patching, and stitching; same set of commands as I ran above
```

Here are the commands I'm running for feature extraction:

```bash
python $CLAM/extract_features_fp.py --data_h5_dir $working_dir/RESULTS_DIRECTORY-pinyi --data_slide_dir $working_dir/DATA_DIRECTORY --csv_path $working_dir/RESULTS_DIRECTORY-pinyi/process_list-feature_extraction.csv --feat_dir $working_dir/RESULTS_DIRECTORY-pinyi/features --batch_size 512 --slide_ext .mrxs 2>&1 | tee feature_extraction-pinyi.log
```

This is currently using 9275MiB out of 16280MiB of GPU memory on a P100 GPU, so I can probably try increasing the batch size from 512 to 899 (exactly) or 880 (to be safe). I can also try using multiple GPUs simply by allocating more from SLURM; this should automatically work.

**DON'T FORGET TO COPY THE OUTPUT OF THE CURRENT JOB TO feature_extraction-pinyi.log!!!!**
