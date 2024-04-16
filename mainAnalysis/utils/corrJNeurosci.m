
function [r, r_null] = corrJNeurosci(surpriseFile, null_perm)
    JNeurosci = load("EEG_data/JNeurosci/ImageryData.mat");
    load(surpriseFile);

    if size(chor_019, 2) ~= 43 ||  size(chor_038, 2) ~= 39 || size(chor_096, 2) ~= 33 || size(chor_101, 2) ~= 50
        disp("Your surprise file do not contain the right number of notes or does not correspond to the mandatory structure. It should be (k, length) with k the features and the first one being the IC. Please check your surprise files and compare them to the midi files.")
    end

    % We open the midi files to replace the original surprise values
    % with any arbitrary surprise file. We then remove the metronome onsets.
    
    pad = 4.837;
    onsets_chor_019 = getOnsetfromMidi("utils/midi/JNeurosci/chor-019.mid", 64, pad);
    onsets_chor_038 = getOnsetfromMidi("utils/midi/JNeurosci/chor-038.mid", 64, pad);
    onsets_chor_096 = getOnsetfromMidi("utils/midi/JNeurosci/chor-096.mid", 64, pad);
    onsets_chor_101 = getOnsetfromMidi("utils/midi/JNeurosci/chor-101.mid", 64, pad);

    order_songs = [];
    for p=1:length(JNeurosci.stim) % for participants
        for c=1:2 % for conditions (listening/imagery)
            for i=1:44 % for trials
                if length(find(JNeurosci.stim{p}{c}{i})) == 27
                    %chor-096
                    order_songs(p, i) = 96;
                    tmp = onsets_chor_096(round(pad*64):round(pad*64+1803+100)); 
                    tmp(find(tmp)) = chor_096(1,:);
                    tmp(JNeurosci.stim{p}{c}{i}==0) = 0;
                    JNeurosci.stim{p}{c}{i} = tmp';

                    
                elseif length(find(JNeurosci.stim{p}{c}{i})) == 28
                    %chor-038
                    order_songs(p, i) = 38;
                    tmp = onsets_chor_038(round(pad*64):round(pad*64+1803+1));
                    tmp(find(tmp)) = chor_038(1,:);
                    tmp(JNeurosci.stim{p}{c}{i}==0) = 0;
                    JNeurosci.stim{p}{c}{i} = tmp';


                elseif length(find(JNeurosci.stim{p}{c}{i})) == 29
                    % chor-019
                    order_songs(p, i) = 19;
                    tmp = onsets_chor_019;
                    tmp(find(tmp)) = chor_019(1,:);
                    tmp = tmp(round(pad*64):round(pad*64+1803+1));
                    tmp(JNeurosci.stim{p}{c}{i}==0) = 0;
                    JNeurosci.stim{p}{c}{i} = tmp';


                elseif length(find(JNeurosci.stim{p}{c}{i})) == 38
                    % chor-101
                    order_songs(p, i) = 101;
                    tmp = onsets_chor_101(round(pad*64):round(pad*64+1803+1));
                    tmp(find(tmp)) = chor_101(1,:);
                    tmp(JNeurosci.stim{p}{c}{i}==0) = 0;
                    JNeurosci.stim{p}{c}{i} = tmp';

                else
                    disp("Big pb, we do not know this song!!");
                    length(find(JNeurosci.stim{p}{c}{i}))
                end
                JNeurosci.stim{p}{c}{i} = JNeurosci.stim{p}{c}{i}(1:1803);
                % We add the onsets
                onsets = JNeurosci.stim{p}{c}{i}; 
                onsets(onsets>0) = 1;
                JNeurosci.stim{p}{c}{i} = [JNeurosci.stim{p}{c}{i}, onsets];
            end
        end
    end
    
%     old = load("EEG_data/JNeurosci/ImageryData.mat");
%     for p=1:1 % for participants
%         for c=1:2 % for conditions (listening/imagery)
%             for i=1:3 % for trials
%                 figure; 
%                 subplot(2, 1, 1);
%                 plot(old.stim{p}{c}{i}); 
%                 title("Old");
%                 subplot(2, 1, 2); 
%                 plot(JNeurosci.stim{p}{c}{i}(:,1));
%                 title("New");
%             end
%         end
%     end
%     
    
    
%     ordering = [];
%     for p=1:21
%         [~, ordering] = sort(order_songs(p, :));
%         JNeurosci.eeg{p}{1} = JNeurosci.eeg{p}{1}(ordering); 
%         JNeurosci.stim{p}{2} = JNeurosci.stim{p}{2}(ordering); 
%     end


    % We trial-cross-eval the TRF to predict the EEG from the new surprise
    kernels = [];
    r = [];
    for p=1:length(JNeurosci.stim) % for participants
        disp(".")
        for c=1:1 % for conditions (listening/imagery)
            [kernels(p,:,:,:), r(p,:,:), ~] = TRF(JNeurosci.eeg{p}{c}, JNeurosci.stim{p}{c});
        end
    end
%     
    r_null = [];
    
%     % We average participants (makes it 20times faster...)
%     data_averaged = {};
%     for s=1:length(JNeurosci.eeg{p}{1}) % for stim
%         for p=1:length(JNeurosci.eeg) % for participants
%             data_averaged{s}(p,:,:) = JNeurosci.eeg{p}{1}{s};
%         end
%         data_averaged{s} = squeeze(mean(data_averaged{s}));
%     end
%     
%     new_data = data_averaged; 
%     new_stim = JNeurosci.stim{1}{c}; 
%       
%     kernels = [];
%     r = [];
%     [kernels(1,:,:,:), r(1,:,:), ~] = TRF(new_data, new_stim);
%             
%     r_null = [];
%     for i=1:null_perm
%         for s = 1:length(new_stim)
%            new_stim{s}(find(new_stim{s})) = shuffle(new_stim{s}(find(new_stim{s}))); 
%         end
%        [~, r_null(i,:,:), ~] = TRF(new_data, new_stim);
%     end
    
end

