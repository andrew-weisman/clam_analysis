#!/bin/bash

#SBATCH --cpus-per-task=8
#SBATCH --partition=gpu
#SBATCH --gres=gpu:p100:1
#SBATCH --mem=20G
#SBATCH --time=04:00:00
#SBATCH -o ./logs/training-2022-04-27-21x.log
#SBATCH -e ./logs/training-2022-04-27-21x.log

echo "Started: $(date)"

# Setup
source /data/weismanal/miniconda3/etc/profile.d/conda.sh
. /home/weismanal/projects/idibell/links/clam_installation/clam_env.sh
working_dir="/home/weismanal/projects/idibell/repo"

# Enter the appropriate directory
cd $working_dir

# Run the main script

mydate="2022-04-27"
target_resolution="21x"
preset="bwh_resection"

python $CLAM/main.py --drop_out --early_stopping --lr 2e-4 --k 10 --label_frac 1 --exp_code ${mydate}-${target_resolution} --weighted_sample --bag_loss ce --inst_loss svm --task idibell --model_type clam_sb --log_data --subtyping --data_root_dir $working_dir/results/${target_resolution}/${preset} --results_dir $working_dir/results/${target_resolution}/${preset}/training

echo "Completed: $(date)"
