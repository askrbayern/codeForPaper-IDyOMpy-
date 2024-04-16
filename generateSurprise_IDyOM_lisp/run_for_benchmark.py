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
    where_is_the_file = ret+"/experiment_output_data_folder/"
    file_names = glob.glob(where_is_the_file+"*.dat")

    if len(file_names) != 1:
        print("It's strange, there is "+str(len(file_names)) + " in the out folder.. I cant do anything...")
    else:
        file_name = file_names[0]


    parser.save_IC_Entropy(file_name, file_out=outName)

def train_eval(trainFolder, testFolder, outName=""):
    print(trainFolder)
    print(testFolder)
    my_experiment = IDyOMExperiment(test_dataset_path=testFolder,
                                    pretrain_dataset_path=trainFolder)

    my_experiment.set_parameters(target_viewpoints=['cpitch', 'onset'],
                                 source_viewpoints=['cpitch', 'onset'],
                                 models=':both',
                                 detail=3, 
                                 ltmo_order_bound=20, 
                                 stmo_order_bound=20)
    ret = my_experiment.run()
    print(ret)
    where_is_the_file = ret+"experiment_output_data_folder/"
    file_names = glob.glob(where_is_the_file+"*.dat")

    if len(file_names) != 1:
        print("It's strange, there is "+str(len(file_names)) + " in the out folder.. I cant do anything...")
    else:
        file_name = file_names[0]

    print(file_name)


    parser.save_IC_Entropy(file_name, file_out=outName)

    print(ret)

if len(sys.argv) == 1:
    print("Give me a folder name!")
    quit()

folderName = sys.argv[1]


if not os.path.exists(folderName):
    os.makedirs(folderName)
else:
    shutil.rmtree(folderName)
    os.makedirs(folderName)


train_eval("../dataset/train_shanxi/", "../dataset/bach_Pearce/", outName=folderName+"/Bach_Pearce_trained_on_Chinese_train.mat")

cross_val("../dataset/bach_Pearce/", outName=folderName+"/Bach_Pearce_cross_eval.mat")

cross_val("../dataset/train_shanxi/", outName=folderName+"/Chinese_train_cross_val.mat")

train_eval("../dataset/bach_Pearce/", "../dataset/train_shanxi/", outName=folderName+"/Chinese_train_trained_on_Bach_Pearce.mat")

train_eval("../dataset/mixed2_for_lisp/", "../stimuli/GregoireMcGill/midis/", outName=folderName+"/Jneurosci_trained_on_mixed2.mat")

train_eval("../dataset/mixed2_for_lisp/", "../stimuli/giovanni/", outName=folderName+"/eLife_trained_on_mixed2.mat")

train_eval("../dataset/mixed2_for_lisp/", "../stimuli/Gold/", outName=folderName+"/Gold_trained_on_mixed2.mat")

cross_val("../dataset/mixed2_for_lisp/", outName=folderName+"/Mixed2_cross_eval.mat")

train_eval("../dataset/bach_Pearce/", "../stimuli/GregoireMcGill/midis/", outName=folderName+"/Jneurosci_trained_on_Bach_Pearce.mat")

train_eval("../dataset/bach_Pearce/", "../stimuli/giovanni/", outName=folderName+"/eLife_trained_on_Bach_Pearce.mat")



