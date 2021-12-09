# Pinyi's Snakemake pipeline through `patch_stitch`

Steps to generate the following output per Pinyi's instructions [here](https://nih.sharepoint.com/:w:/r/sites/NCI-CBIITEndometrialCancer/_layouts/15/doc2.aspx?sourcedoc=%7BE6012ABD-E2DA-4E28-AF59-178775C13F1A%7D&file=Summary_CLAM_PL.docx&action=edit&mobileredirect=true&wdPreviousSession=fc4d0688-aa3b-4835-9f14-67fb74b93b95&wdOrigin=TEAMS-ELECTRON.teams.undefined&cid=76417f26-9758-4371-b2a2-ff4687c2b666):

```bash
source /data/BIDS-HPC/public/software/conda/etc/profile.d/conda.sh
conda activate /data/BIDS-HPC/public/software/conda/envs/snakemake
nnd; mkcd testing_pinyi_segmentation_pipeline
cp /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/configfile/CLAM.yaml .
snakemake -p -s /data/BIDS-HPC/private/projects/IDIBELL-NCI-FNL/snakemake/Snakefile_CLAM3 --cores 1 --until patch_stitch -n
```

Unmodified outputted steps for a single sample:

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

`process_list_autogen-composite.csv` makes it seem that the segmentation parameters were indeed honored.

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

being `True` (see `/home/weismanal/notebook/2021-12-07/testing_pinyi_segmentation_pipeline/full/scratch_on_2021-12-07.ipynb`), we know that the outputted segmentation parameters are the same as the inputted ones; we should indeed be segmenting the downsampled `.ome.tif` files using Pinyi's segmentation parameters and can now try [visually observing the stitching results](./README.md#stitching-comparisons).
