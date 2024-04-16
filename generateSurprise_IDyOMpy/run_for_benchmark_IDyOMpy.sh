#!/usr/bin/env bash

if [[ $# -eq 0 ]] ; then
    echo 'Give me a folder name!!!'
    exit 1
fi



python3 App.py -t ../dataset/Chinese_train/ -s ../dataset/bach_Pearce/ &

python3 App.py -c ../dataset/bach_Pearce/ &

python3 App.py -c ../dataset/Chinese_train/ &

python3 App.py -t ../dataset/bach_Pearce/ -s ../dataset/Chinese_train/ &

python3 App.py -t ../dataset/mixed2/ -s ../stimuli/GregoireMcGill/ &

python3 App.py -t ../dataset/mixed2/ -s ../stimuli/giovanni/ &

python3 App.py -t ../dataset/mixed2/ -s ../stimuli/Gold/ &

python3 App.py -c ../dataset/mixed2/ &

python3 App.py -t ../dataset/bach_Pearce/ -s ../stimuli/GregoireMcGill/ &

python3 App.py -t ../dataset/bach_Pearce/ -s ../stimuli/giovanni/ &

python3 App.py -e ../dataset/bach_Pearce/ &

wait 

echo 'Computations done, we move the files...'

mkdir -p $1

rm -rf $1/*

cp out/bach_Pearce/surprises/Chinese_train/data/Chinese_train_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Bach_Pearce_trained_on_Chinese_train.mat

cp out/bach_Pearce/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Bach_Pearce_cross_eval.mat

cp out/Chinese_train/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Chinese_train_cross_val.mat

cp out/Chinese_train/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Chinese_train_trained_on_Bach_Pearce.mat

cp out/GregoireMcGill/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Jneurosci_trained_on_mixed2.mat

cp out/giovanni/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/eLife_trained_on_mixed2.mat

cp out/Gold/surprises/mixed2/data/mixed2_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Gold_trained_on_mixed2.mat
    
cp out/mixed2/eval/data/likelihoods_cross-eval_k_fold_5_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Mixed2_cross_eval.mat

cp out/GregoireMcGill/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/Jneurosci_trained_on_bach_Pearce.mat

cp out/giovanni/surprises/bach_Pearce/data/bach_Pearce_quantization_24_maxOrder_20_viewpoints_pitch_length.mat $1/eLife_trained_on_bach_Pearce.mat

cp out/bach_Pearce/evolution/bach_Pearce.mat $1/evolution_Bach_Pearce.mat