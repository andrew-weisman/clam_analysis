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
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv                   # segmentation only using specific parameters
python create_patches_fp.py --source DATA_DIRECTORY --save_dir RESULTS_DIRECTORY --patch_size 256 --seg --process_list process_list_edited.csv --patch --stitch  # subsequent entire workflow, i.e., segmentation, patching, and stitching; same set of commands as I ran above
```

I should note that Pinyi's segmentation parameters in his original `process_list_edited_slides_1-16.csv` file were based on downsampled `.ome.tif` files, so they may not apply as neatly to the `.mrxs` files; this is something to test.

For testing with and without MRXS data directories:

```bash
python $CLAM/create_patches_fp.py --source $working_dir/data-with_data_dirs    --save_dir $working_dir/results/with_data_dirs    --patch_size 256 --process_list $working_dir/inputs/first_five.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-with_data_dirs.log
python $CLAM/create_patches_fp.py --source $working_dir/data-without_data_dirs --save_dir $working_dir/results/without_data_dirs --patch_size 256 --process_list $working_dir/inputs/first_five.csv --seg --patch --stitch 2>&1 | tee $working_dir/logs/preprocessing-without_data_dirs.log
```

The testing results seem to show that without the data directories, segmentation may be performed on some sort of thumbnail present in the `.mrxs` file itself and that while CLAM seems to work on `.mrxs` files, the associated data directories must be present.

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

## Pinyi's Snakemake pipeline through `patch_stitch`

Steps to generate the following output per Pinyi's instructions [here](https://nih.sharepoint.com/:w:/r/sites/NCI-CBIITEndometrialCancer/_layouts/15/doc2.aspx?sourcedoc=%7BE6012ABD-E2DA-4E28-AF59-178775C13F1A%7D&file=Summary_CLAM_PL.docx&action=edit&mobileredirect=true&wdPreviousSession=fc4d0688-aa3b-4835-9f14-67fb74b93b95&wdOrigin=TEAMS-ELECTRON.teams.undefined&cid=76417f26-9758-4371-b2a2-ff4687c2b666):

```bash
source /data/BIDS-HPC/public/software/conda/etc/profile.d/conda.sh
conda activate /data/BIDS-HPC/public/software/conda/envs/snakemake
nnd; mkcd testing_pinyi_segmentation_pipeline
cp /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/configfile/CLAM.yaml .
snakemake -p -s /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/snakemake/Snakefile_CLAM3 --cores 1 --until patch_stitch -n
```

Unmodified steps for a single sample:

```bash
/data/BIDS-HPC/public/software/QuPath-0.2.3/bin/QuPath-0.2.3 convert-ome --overwrite -d 30 -c UNCOMPRESSED /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined/0042034876.mrxs ome-tiff/0042034876/0042034876.ome.tif
module load openslide
/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/bin/python /data/BIDS-HPC/public/software/CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --preset /data/BIDS-HPC/public/software/CLAM/presets/bwh_biopsy.csv --patch_size 256 --seg
module load openslide
/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/bin/python /data/BIDS-HPC/public/software/CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --process_list process_list_edited.csv --patch_size 256 --seg
module load openslide
/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/bin/python /data/BIDS-HPC/public/software/CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --process_list process_list_edited.csv --patch_size 256 --seg --patch --stitch
```

Modified steps to generate the stitches:

```bash
/data/BIDS-HPC/public/software/QuPath-0.2.3/bin/QuPath-0.2.3 convert-ome --overwrite -d 30 -c UNCOMPRESSED /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/data/wsi/MRXScombined/0042034876.mrxs ome-tiff/0042034876/0042034876.ome.tif
module load openslide
cp /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/process_list_edited_slides_1-16.csv RESULTS_DIRECTORY/0042034876
/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/bin/python /data/BIDS-HPC/public/software/CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --process_list ./process_list_edited_slides_1-16.csv --patch_size 256 --seg --patch --stitch
```

This last line fails with:

```
(snakemake) weismanal@cn4235:~/notebook/2021-12-07/testing_pinyi_segmentation_pipeline $ /gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/bin/python /data/BIDS-HPC/public/software/CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --process_list ./process_list_edited_slides_1-16.csv --patch_size 256 --seg --patch --stitch
source:  ome-tiff/0042034876
patch_save_dir:  RESULTS_DIRECTORY/0042034876/patches
mask_save_dir:  RESULTS_DIRECTORY/0042034876/masks
stitch_save_dir:  RESULTS_DIRECTORY/0042034876/stitches
source : ome-tiff/0042034876
save_dir : RESULTS_DIRECTORY/0042034876
patch_save_dir : RESULTS_DIRECTORY/0042034876/patches
mask_save_dir : RESULTS_DIRECTORY/0042034876/masks
stitch_save_dir : RESULTS_DIRECTORY/0042034876/stitches
{'seg_params': {'seg_level': -1, 'sthresh': 8, 'mthresh': 7, 'close': 4, 'use_otsu': False, 'keep_ids': 'none', 'exclude_ids': 'none'}, 'filter_params': {'a_t': 100, 'a_h': 16, 'max_n_holes': 8}, 'patch_params': {'use_padding': True, 'contour_fn': 'four_pt'}, 'vis_params': {'vis_level': -1, 'line_thickness': 250}}


progress: 0.00, 0/16
processing 0042034876.ome.tif
Creating patches for:  0042034876.ome ...
Total number of contours to process:  3
Bounding Box: 2031 6383 1065 912
Contour Area: 532886.0
multiprocessing.pool.RemoteTraceback:
"""
Traceback (most recent call last):
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/lib/python3.6/multiprocessing/pool.py", line 119, in worker
    result = (True, func(*args, **kwds))
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/lib/python3.6/multiprocessing/pool.py", line 47, in starmapstar
    return list(itertools.starmap(args[0], args[1]))
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/wsi_core/WholeSlideImage.py", line 481, in process_coord_candidate
    if WholeSlideImage.isInContours(cont_check_fn, coord, contour_holes, ref_patch_size):
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/wsi_core/WholeSlideImage.py", line 345, in isInContours
    if cont_check_fn(pt):
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/wsi_core/util_classes.py", line 86, in __call__
    if cv2.pointPolygonTest(self.cont, points, False) >= 0:
cv2.error: OpenCV(4.5.3) :-1: error: (-5:Bad argument) in function 'pointPolygonTest'
> Overload resolution failed:
>  - Can't parse 'pt'. Sequence item with index 0 has a wrong type
>  - Can't parse 'pt'. Sequence item with index 0 has a wrong type

"""

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "/data/BIDS-HPC/public/software/CLAM/create_patches_fp.py", line 307, in <module>
    process_list = process_list, auto_skip=args.no_auto_skip)
  File "/data/BIDS-HPC/public/software/CLAM/create_patches_fp.py", line 196, in seg_and_patch
    file_path, patch_time_elapsed = patching(WSI_object = WSI_object,  **current_patch_params,)
  File "/data/BIDS-HPC/public/software/CLAM/create_patches_fp.py", line 36, in patching
    file_path = WSI_object.process_contours(**kwargs)
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/wsi_core/WholeSlideImage.py", line 382, in process_contours
    asset_dict, attr_dict = self.process_contour(cont, self.holes_tissue[idx], patch_level, save_path, patch_size, step_size, **kwargs)
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/wsi_core/WholeSlideImage.py", line 456, in process_contour
    results = pool.starmap(WholeSlideImage.process_coord_candidate, iterable)
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/lib/python3.6/multiprocessing/pool.py", line 274, in starmap
    return self._map_async(func, iterable, starmapstar, chunksize).get()
  File "/gpfs/gsfs9/users/BIDS-HPC/public/software/CLAM/.snakemake/conda/c172b0386cd740f8f988ccd70d23890b/lib/python3.6/multiprocessing/pool.py", line 644, in get
    raise self._value
cv2.error: OpenCV(4.5.3) :-1: error: (-5:Bad argument) in function 'pointPolygonTest'
> Overload resolution failed:
>  - Can't parse 'pt'. Sequence item with index 0 has a wrong type
>  - Can't parse 'pt'. Sequence item with index 0 has a wrong type
```

According to 33:35 of [this video](https://nih-my.sharepoint.com/personal/weismanal_nih_gov/_layouts/15/onedrive.aspx?id=%2Fpersonal%2Fweismanal%5Fnih%5Fgov%2FDocuments%2Fmicrosoft%2Dcreated%2FRecordings%2FCLAM%20Snakemake%20Pipeline%20Demo%2D20211021%5F110057%2DMeeting%20Recording%2Emp4&parent=%2Fpersonal%2Fweismanal%5Fnih%5Fgov%2FDocuments%2Fmicrosoft%2Dcreated%2FRecordings), this is the same error that Pinyi got for which he thinks "OpenCV in the [openslide] module needs to be downgraded to an old version, such as 4.5.1.48. Alternatively, the Biowulf team may create another version of openslide module with an old version of OpenCV."

Now trying to use my installation of CLAM:

```bash
conda deactivate
module purge
. /home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh
python $CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --process_list ./process_list_edited_slides_1-16.csv --patch_size 256 --seg --patch --stitch
```

This worked:

```
(clam) weismanal@cn4235:~/notebook/2021-12-07/testing_pinyi_segmentation_pipeline $ python $CLAM/create_patches_fp.py --source ome-tiff/0042034876 --save_dir RESULTS_DIRECTORY/0042034876 --process_list ./process_list_edited_slides_1-16.csv --patch_size 256 --seg --patch --stitch
source:  ome-tiff/0042034876
patch_save_dir:  RESULTS_DIRECTORY/0042034876/patches
mask_save_dir:  RESULTS_DIRECTORY/0042034876/masks
stitch_save_dir:  RESULTS_DIRECTORY/0042034876/stitches
source : ome-tiff/0042034876
save_dir : RESULTS_DIRECTORY/0042034876
patch_save_dir : RESULTS_DIRECTORY/0042034876/patches
mask_save_dir : RESULTS_DIRECTORY/0042034876/masks
stitch_save_dir : RESULTS_DIRECTORY/0042034876/stitches
{'seg_params': {'seg_level': -1, 'sthresh': 8, 'mthresh': 7, 'close': 4, 'use_otsu': False, 'keep_ids': 'none', 'exclude_ids': 'none'}, 'filter_params': {'a_t': 100, 'a_h': 16, 'max_n_holes': 8}, 'patch_params': {'use_padding': True, 'contour_fn': 'four_pt'}, 'vis_params': {'vis_level': -1, 'line_thickness': 250}}


progress: 0.00, 0/16
processing 0042034876.ome.tif
Creating patches for:  0042034876.ome ...
Total number of contours to process:  3
Bounding Box: 2031 6383 1065 912
Contour Area: 532886.0
Extracted 11 coordinates
Bounding Box: 1109 4252 2816 2537
Contour Area: 2497240.0
Extracted 48 coordinates
Bounding Box: 140 0 2492 3092
Contour Area: 3124765.5
Extracted 66 coordinates
start stitching 0042034876.ome
original size: 3925 x 7398
downscaled size for stiching: 3925 x 7398
number of patches: 125
patch size: 256x256 patch level: 0
ref patch size: (256, 256)x(256, 256)
downscaled patch size: 256x256
progress: 0/125 stitched
progress: 13/125 stitched
progress: 26/125 stitched
progress: 39/125 stitched
progress: 52/125 stitched
progress: 65/125 stitched
progress: 78/125 stitched
progress: 91/125 stitched
progress: 104/125 stitched
progress: 117/125 stitched
segmentation took 1.714134931564331 seconds
patching took 0.2665562629699707 seconds
stitching took 0.3072478771209717 seconds
```

Thus, the full set of steps for downsampling, converting, segmenting, patching, and stitching is:

```bash
. /home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh
private_project_dir="/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL"
for image_basename in $(ls $private_project_dir/data/wsi/MRXScombined/*.mrxs | awk -v FS="/" '{print $NF}' | awk -v FS=".mrxs" '{print $1}'); do
    /data/BIDS-HPC/public/software/QuPath-0.2.3/bin/QuPath-0.2.3 convert-ome --overwrite -d 30 -c UNCOMPRESSED $private_project_dir/data/wsi/MRXScombined/$image_basename.mrxs ome-tiff/$image_basename/$image_basename.ome.tif
    mkdir -p RESULTS_DIRECTORY/$image_basename
    (head -n 1 $private_project_dir/process_list_edited_slides_1-16.csv; grep "^$image_basename.ome.tif" $private_project_dir/process_list_edited_slides_1-16.csv) > RESULTS_DIRECTORY/$image_basename/process_list_edited-$image_basename.csv
    python $CLAM/create_patches_fp.py --source ome-tiff/$image_basename --save_dir RESULTS_DIRECTORY/$image_basename --process_list process_list_edited-$image_basename.csv --patch_size 256 --seg --patch --stitch
done
```

I have placed most of this into `/home/weismanal/notebook/2021-11-11/testing_clam/pinyi_through_stitching.sh` and am running it in the directory `/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full` using:

```bash
cd /home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full
. /home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh
export private_project_dir="/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL"
export CLAM=$CLAM
bash /home/weismanal/notebook/2021-11-11/testing_clam/pinyi_through_stitching.sh 2>&1 | tee ./pinyi_through_stitching.log
```

It appears from the output (`grep "^{'seg_params': {" pinyi_through_stitching.log`) that the segmentation parameters used aren't being honored, so I recompiled the process lists using:

```
(clam) weismanal@cn4235:~/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full $ (file_list=RESULTS_DIRECTORY/*/process_list_edited*; head -q -n 1 $file_list | head -n 1; tail -q -n 1 $file_list) > process_list_edited-composite.csv
(clam) weismanal@cn4235:~/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full $ (file_list=RESULTS_DIRECTORY/*/process_list_autogen*; head -q -n 1 $file_list | head -n 1; tail -q -n 1 $file_list) > process_list_autogen-composite.csv
```

`process_list_autogen-composite.csv` makes it seem that the segmentation parameters were indeed honored. **COMPARE TO 1-16 CSV FILE!!**

As a check, I am running:

```bash
cd /home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/default_params
. /home/weismanal/notebook/2021-11-10/testing_clam/clam_env.sh
export private_project_dir="/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL"
export CLAM=$CLAM
bash /home/weismanal/notebook/2021-11-11/testing_clam/pinyi_through_stitching-default_params.sh 2>&1 | tee ./pinyi_through_stitching-default_params.log
```

This very weirdly only seems to work for `DigitalSlide_E6M_15S_1` and it's probably not important enough to investigate as it's probably a bug in the end. Instead, I'll run my sanity check by comparing the composite CSV files in `/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full` to `/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/process_list_edited_slides_1-16.csv` and by visually observing the stitching results.

```bash
csv_orig="/data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/process_list_edited_slides_1-16.csv"
csv_autogen="/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/process_list_autogen-composite.csv"
csv_edited="/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/process_list_edited-composite.csv"
diff <(sort $csv_orig) <(sort $csv_edited)  # no difference
```

From the output of

```python
csv_autogen = '/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/process_list_autogen-composite.csv'
csv_edited = '/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/process_list_edited-composite.csv'
import pandas as pd
df_autogen = pd.read_csv(csv_autogen)
df_edited = pd.read_csv(csv_edited)
df_new = df_autogen.astype({'a_t': 'int64', 'a_h': 'int64'})
df_new[['vis_level', 'seg_level']] = -1  # both these columns were 0 previously, i.e., they were changed from -1 to 0
df_new['process'] = 1  # this column was 0 previously, i.e., they were changed from 1 to 0
df_edited.equals(df_new)
```

being `True` (see `/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/scratch_on_2021-12-07.ipynb`), we know that the outputted segmentation parameters are the same as the inputted ones; we should indeed be segmenting the downsampled `.ome.tif` files using Pinyi's segmentation parameters and can now try visually observing the stitching results.

**Ensure for each script I look at the arguments that I can modify using the `-h` option.**
