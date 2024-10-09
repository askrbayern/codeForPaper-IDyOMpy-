%% Code to add dDW_ppm into existing all_vals.mat
clear; clc;
% this script should be placed inside forBenchmark_idyompy_ppm
% together with the Gold_mDW_IC_Entropy.mat file
new_ppm_file = 'Gold_mDW_IC_Entropy.mat';
% load all vals
folder_gold = "../../GoldReplication/";
all_vals_file = 'all_vals.mat';
output_file = folder_gold+'all_vals_w_ppm.mat';

%% make sure you are in forlder codeForPaper-IDyOMpy/mainAnalysis/forBenchmark_idyompy_ppm NOW
new_ppm_data = load(new_ppm_file);
all_vals_data = load(folder_gold+all_vals_file);

%%
ppm_ic = new_ppm_data.ppm_mDW_IC;
ppm_entropy = new_ppm_data.ppm_mDW_Entropy;

all_vals_data.all_vals.ppm_mDW_IC = ppm_ic;
all_vals_data.all_vals.ppm_mDW_Entropy = ppm_entropy;

% save all_vals as a table directly
all_vals = all_vals_data.all_vals;

%%
save(output_file, 'all_vals');
disp('Finished processing.')

