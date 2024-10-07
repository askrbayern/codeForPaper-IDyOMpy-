#!/usr/bin/env bash

# confirmations
echo "
╔════════════════════════ IMPORTANT ════════════════════════╗
║                                                           ║
║  PLEASE ENSURE THE FOLLOWING BEFORE PROCEEDING:           ║
║                                                           ║
║  1. This process takes about 10min                        ║
║  2. 'dataset' folder is replaced by the one from          ║
║     the codeForPaper-IDyOmpy- repository                  ║
║  3. 'stimuli' folder is copied from the                   ║
║     codeForPaper-IDyOmpy- repository                      ║
║  4. 'models' folder is empty                              ║
║  5. This script is in the IDyOMpy directory and           ║
║     running under the IDyOMpy environment                 ║ 
║  6. The results will be renamed and copied to             ║
║     'forBenchmark_idyompy_PPM'                            ║
║                                                           ║
╚═══════════════════════ READ CAREFULLY ════════════════════╝
"

read -p "Do you want to proceed? (Y/N): " confirm
if [[ $confirm =~ ^[Yy]$ ]]; then
    echo "Starting the benchmark..."
elif [[ $confirm =~ ^[Nn]$ ]]; then
    echo "Execution cancelled."
    exit 0
else
    echo "Unknown response. Execution cancelled."
    exit 0
fi

# avoid reporting error due to parallel processes 1
if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* || -n "$WSL_DISTRO_NAME" ]]; then
    mkdir -p .TEMP
    echo "Windows system or WSL detected, creating .TEMP folder in the parent directory"
    sleep 2
fi
# avoid reporting error due to parallel processes 2
mkdir -p out

python3 App.py -t dataset/shanxi/ -s dataset/bach_Pearce/ -o 1 &

python3 App.py -t dataset/mixed2/ -s stimuli/GregoireMcGill/ -o 1 &

python3 App.py -t dataset/bach_Pearce/ -s dataset/shanxi/ -o 1 &

wait

python3 App.py -c dataset/bach_Pearce/ -o 1 &

python3 App.py -c dataset/shanxi/ -o 1 & 

python3 App.py -c dataset/mixed2/ -o 1 &

yes Y | python3 App.py -t dataset/mixed2/ -s stimuli/giovanni/ -o 1 &

yes Y | python3 App.py -t dataset/mixed2/ -s stimuli/Gold/ -o 1 &

yes Y | python3 App.py -t dataset/bach_Pearce/ -s stimuli/GregoireMcGill/ -o 1 &

yes Y | python3 App.py -t dataset/bach_Pearce/ -s stimuli/giovanni/ -o 1 &

wait 

echo "Computations done, we move the files..."

mkdir -p "forBenchmark_idyompy_PPM"

cp out/bach_Pearce/surprises/shanxi/data/shanxi_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Bach_Pearce_trained_on_Chinese_train.mat

cp out/bach_Pearce/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Bach_Pearce_cross_eval.mat

cp out/shanxi/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Chinese_train_cross_val.mat

cp out/shanxi/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Chinese_train_trained_on_Bach_Pearce.mat

cp out/GregoireMcGill/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Jneurosci_trained_on_mixed2.mat

cp out/giovanni/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/eLife_trained_on_mixed2.mat

cp out/Gold/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Gold_trained_on_mixed2.mat

cp out/mixed2/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Mixed2_cross_eval.mat

cp out/GregoireMcGill/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/Jneurosci_trained_on_bach_Pearce.mat

cp out/giovanni/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length_originalPPM.mat forBenchmark_idyompy_PPM/eLife_trained_on_bach_Pearce.mat

echo "Benchmark completed. Results are saved in folder forBenchmark_idyompy_PPM."