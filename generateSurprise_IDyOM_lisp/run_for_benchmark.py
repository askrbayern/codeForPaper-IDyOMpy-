print("""
╔════════════════════════ IDyOM Lisp Benchmark ══════════════════════╗
║                                                                    ║
║  Please ensure:                                                    ║
║  1. py2lispIDyOM is cloned under codeForPaper-IDyOMpy/             ║
║  2. This file and parser.py are placed under py2lispIDyOM/         ║
║  3. lisp and piy2lispIDyOM are installed                           ║
║  4. Correct environment is activated                               ║
║  5. The current experiment_history folder under py2lispIDyOM       ║
║     will be deleted if it exists                                   ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
""")

import py2lispIDyOM as py2lispIDyOM
from py2lispIDyOM.run import IDyOMExperiment
import parser
import glob
import sys
import os
import shutil

def cross_val(folder, outName=""):
    my_experiment = IDyOMExperiment(test_dataset_path=folder)

    my_experiment.set_parameters(target_viewpoints=['cpitch', 'onset'],
                                 source_viewpoints=['cpitch', 'onset'],
                                 models=':both',
                                 k=5,
                                 detail=3, 
                                 ltmo_order_bound=20, 
                                 stmo_order_bound=20)
    ret = my_experiment.run()
    # where_is_the_file = ret+"/experiment_output_data_folder/"


    where_is_the_file = "experiment_history/"
    file_names = glob.glob(os.path.join(where_is_the_file, "**", "*.dat"), recursive=True)

    # file_names = glob.glob(where_is_the_file+"*.dat")

    if len(file_names) != 1:
        print("It's strange, there is "+str(len(file_names)) + " in the out folder.. I cant do anything...")
    else:
        file_name = file_names[0]


    parser.save_IC_Entropy(file_name, file_out=outName)
    print(f"Finished processing. Output saved to: {outName}")
    # remove the whole experiment history folder
    shutil.rmtree(where_is_the_file)

def train_eval(trainFolder, testFolder, outName=""):
    # print(trainFolder)
    # print(testFolder)
    my_experiment = IDyOMExperiment(test_dataset_path=testFolder,
                                    pretrain_dataset_path=trainFolder)

    my_experiment.set_parameters(target_viewpoints=['cpitch', 'onset'],
                                 source_viewpoints=['cpitch', 'onset'],
                                 models=':stm',
                                 k=1,
                                 detail=3, 
                                 ltmo_order_bound=20, 
                                 stmo_order_bound=20)
    ret = my_experiment.run()
    # print(ret) # archived code? it returns a zero
 
    # where_is_the_file = ret+"experiment_output_data_folder/"
    # file_names = glob.glob(where_is_the_file+"*.dat")

    where_is_the_file = "experiment_history/"
    file_names = glob.glob(os.path.join(where_is_the_file, "**", "*.dat"), recursive=True)

    if len(file_names) != 1:
        print("It's strange, there is "+str(len(file_names)) + " in the out folder.. I cant do anything...")
    else:
        file_name = file_names[0]

    print(file_name)


    parser.save_IC_Entropy(file_name, file_out=outName)

    print(ret)
    print(f"Finished processing. Output saved to: {outName}")
    # remove the whole experiment history folder
    shutil.rmtree(where_is_the_file)





# Main code
continue_run = input("Are you ready to proceed? (Y/N): ").lower().strip()
if continue_run != 'y':
    print("Execution cancelled.")
    sys.exit(0)

if not os.path.exists("../benchmark_results/lisp"):
    os.makedirs("../benchmark_results/lisp")
else:
    shutil.rmtree("../benchmark_results/lisp")
    os.makedirs("../benchmark_results/lisp")

print("Starting the benchmark...")

if os.path.exists("experiment_history"):
    shutil.rmtree("experiment_history")
    print("Deleted existing experiment_history folder.")


train_eval("../dataset/train_shanxi/", "../dataset/bach_Pearce/", outName="../benchmark_results/lisp/Bach_Pearce_trained_on_Chinese_train.mat")

cross_val("../dataset/bach_Pearce/", outName="../benchmark_results/lisp/Bach_Pearce_cross_eval.mat")

cross_val("../dataset/train_shanxi/", outName="../benchmark_results/lisp/Chinese_train_cross_val.mat")

train_eval("../dataset/bach_Pearce/", "../dataset/train_shanxi/", outName="../benchmark_results/lisp/Chinese_train_trained_on_Bach_Pearce.mat")

train_eval("../dataset/mixed2_for_lisp/", "../stimuli/GregoireMcGill/midis/", outName="../benchmark_results/lisp/Jneurosci_trained_on_mixed2.mat")

train_eval("../dataset/mixed2_for_lisp/", "../stimuli/giovanni/", outName="../benchmark_results/lisp/eLife_trained_on_mixed2.mat")

train_eval("../dataset/mixed2_for_lisp/", "../stimuli/Gold/", outName="../benchmark_results/lisp/Gold_trained_on_mixed2.mat")

cross_val("../dataset/mixed2_for_lisp/", outName="../benchmark_results/lisp/Mixed2_cross_eval.mat")

train_eval("../dataset/bach_Pearce/", "../stimuli/GregoireMcGill/midis/", outName="../benchmark_results/lisp/Jneurosci_trained_on_Bach_Pearce.mat")

train_eval("../dataset/bach_Pearce/", "../stimuli/giovanni/", outName="../benchmark_results/lisp/eLife_trained_on_Bach_Pearce.mat")

print("Benchmark completed. Results are saved in ../benchmark_results/lisp")