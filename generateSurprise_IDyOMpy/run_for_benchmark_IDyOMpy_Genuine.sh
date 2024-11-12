#!/usr/bin/env bash

# confirmations
echo "
╔════════════════════════ IMPORTANT ════════════════════════╗
║                                                           ║
║  PLEASE ENSURE THE FOLLOWING BEFORE PROCEEDING:           ║
║                                                           ║
║  1. This is a test code for Genuine Entropy               ║
║  2. IDyOMpy is cloned under codeForPaper-IDyOMpy-/        ║
║  3. This script is in the IDyOMpy directory and           ║
║     running under the IDyOMpy environment                 ║
║  4. The results will be renamed and copied to folder      ║
║     'forBenchmark_idyompy_genuine' under                  ║
║     'codeForPaper-IDyOMpy/benchmark_results/'             ║
║                                                           ║
║  NOTE: Interrupting the process may lead to errors in     ║
║        some operating systems. If errors occur when you   ║
║        run the code again (especially directory issues    ║
║        for 'models'), try rebooting your system or        ║
║        delete all partial results and restart the         ║
║        entire process.                                    ║
║                                                           ║
╚═══════════════════════ READ CAREFULLY ════════════════════╝
"

read -p "Do you want to proceed? (Y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "Checking the models directory..."
elif [[ $confirm =~ ^[Nn]$ ]]; then
    echo "Execution cancelled."
    exit 0
else
    echo "Unknown response. Execution cancelled."
    exit 0
fi

# remove related models if they exist
# modify if new data are added to the benchmark
models_dir="models"
model_files=(
    "bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.model"
    "mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.model"
    "train_shanxi_quantization_24_maxOrder_20_viewpoints_pitch_length.model"
)

found_models=false
for file in "${model_files[@]}"; do
    if [ -f "$models_dir/$file" ]; then
        found_models=true
        break
    fi
done

if $found_models; then
    echo "Found trained models in the 'models' directory."
    read -p "Do you want to delete these models? (Y/N): " clean_confirm
    if [[ $clean_confirm =~ ^[Yy]$ ]]; then
        echo "Deleting existing model files for benchmark..."
        for file in "${model_files[@]}"; do
            if [ -f "$models_dir/$file" ]; then
                rm "$models_dir/$file"
                echo "Deleted: $file"
            fi
        done
        echo "Deletion complete."
    else
        echo "Models were not deleted. Exiting the script."
        exit 0
    fi
else
    echo "No trained models found in the 'models' directory."
fi


# avoid reporting error due to parallel processes
if [[ -n "$WSL_DISTRO_NAME" ]]; then
    mkdir -p .TEMP
    echo "WSL detected, creating .TEMP folder in the current directory"
fi

mkdir -p out # avoid reporting error due to parallel processes

python3 App.py -t ../dataset/train_shanxi/ -s ../dataset/bach_Pearce/ -g 1 &

python3 App.py -t ../dataset/mixed2/ -s ../stimuli/GregoireMcGill/ -g 1 &

python3 App.py -t ../dataset/bach_Pearce/ -s ../dataset/train_shanxi/ -g 1 &

wait


python3 App.py -c ../dataset/bach_Pearce/ -g 1 &

python3 App.py -c ../dataset/train_shanxi/ -g 1 & 

python3 App.py -c ../dataset/mixed2/ -g 1 &

yes N | python3 App.py -t ../dataset/mixed2/ -s ../stimuli/giovanni/ -g 1 &

yes N | python3 App.py -t ../dataset/mixed2/ -s ../stimuli/Gold/ -g 1 &

yes N | python3 App.py -t ../dataset/bach_Pearce/ -s ../stimuli/GregoireMcGill/ -g 1 &

yes N | python3 App.py -t ../dataset/bach_Pearce/ -s ../stimuli/giovanni/ -g 1 &

wait 

echo "Computations done, we move the files..."

mkdir -p "../benchmark_results/forBenchmark_idyompy_genuine"

cp out/bach_Pearce/surprises/train_shanxi/data/train_shanxi_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Bach_Pearce_trained_on_Chinese_train.mat

cp out/bach_Pearce/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Bach_Pearce_cross_eval.mat

cp out/train_shanxi/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Chinese_train_cross_val.mat

cp out/train_shanxi/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Chinese_train_trained_on_Bach_Pearce.mat

cp out/GregoireMcGill/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Jneurosci_trained_on_mixed2.mat

cp out/giovanni/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/eLife_trained_on_mixed2.mat

cp out/Gold/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Gold_trained_on_mixed2.mat

cp out/mixed2/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Mixed2_cross_eval.mat

cp out/GregoireMcGill/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/Jneurosci_trained_on_bach_Pearce.mat

cp out/giovanni/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.mat ../benchmark_results/forBenchmark_idyompy_genuine/eLife_trained_on_bach_Pearce.mat

echo "Benchmark completed. Results are saved under benchmark_results/forBenchmark_idyompy_genuine/"
