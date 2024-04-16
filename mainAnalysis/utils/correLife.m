function [r, r_null] = correLife(surpriseFile, null_perm)
    load(surpriseFile);
    % We open all participants
    data = {};
    for p=1:20
        data{p} = load("EEG_data/dataCND/dataSub"+num2str(p)+".mat");
        data{p} = data{p}.eeg.data;
    end

    % We load the stim 
    load("EEG_data/dataCND/dataStim.mat");
    stim = stim.data(2,:);
    
    %stim = getSurpriseStim(surpriseFile, "EEG_data/dataCND/dataStim.mat");
    
    % We trial-cross-eval the TRF to predict the EEG from the new surprise
    kernels = [];
    r = [];
    for p=1:length(data) % for participants
        disp(".")
        [kernels(p,:,:), r(p,:,:), ~] = TRF(data{p}, stim);
    end
    
    r_null = [];
    for p=1:length(data)
        for i=1:null_perm
            for s = 1:length(new_stim)
               new_stim{s}(find(new_stim{s})) = shuffle(new_stim{s}(find(new_stim{s}))); 
            end
           [~, r_null(p,i,:,:), ~] = TRF(data{p}, new_stim);
        end
    end

end
