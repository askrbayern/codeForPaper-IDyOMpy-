% Cognition and Natural Sensory Processing (CNSP) Workshop
% Example 1
%
% CNSP-Workshop 2021
% https://cnsp-workshop.github.io/website/index.html
% Author: Giovanni M. Di Liberto
% Copyright 2021 - Giovanni Di Liberto
%                  Nathaniel Zuk
%                  Michael Crosse
%                  Aaron Nidiffer
%                  (see license file for details)
% Last update: 24 July 2021

clear all
close all

addpath ../libs/cnsp_utils
addpath ../libs/cnsp_utils/cnd
addpath ../libs/mTRF-Toolbox_v2/mtrf
addpath ../libs/NoiseTools
addpath ../libs/eeglab
eeglab


%% Parameters - Natural speech listening experiment
dataMainFolder = '../datasets/diliBach/';
% dataCNDSubfolder = 'dataCND/old/';
dataCNDSubfolder = 'dataCND/';

reRefType = 'Mastoids'; % or 'Avg'
bandpassFilterRange = [1,8]; % Hz (indicate 0 to avoid running the low-pass
                          % or high-pass filters or both)
                          % e.g., [0,8] will apply only a low-pass filter
                          % at 8 Hz
downFs = 64; % Hz. *** fs/downFs must be an integer value ***

eegFilenames = dir([dataMainFolder,dataCNDSubfolder,'dataSub*.mat']);
nSubs = length(eegFilenames);

%% Preprocess EEG - Natural speech listening experiment
for sub = 1:nSubs
    % Loading EEG data
    eegFilename = [dataMainFolder,dataCNDSubfolder,eegFilenames(sub).name];
    disp(['Loading EEG data: ',eegFilenames(sub).name])
    load(eegFilename,'eeg')
    eeg = cndNewOp(eeg,'Load'); % Saving the processing pipeline in the eeg struct

    % Filtering - LPF (low-pass filter)
    if bandpassFilterRange(2) > 0
        hd = getLPFilt(eeg.fs,bandpassFilterRange(2));
        
        % Filtering each trial/run with a cellfun statement
        eeg.data = cellfun(@(x) filtfilthd(hd,x),eeg.data,'UniformOutput',false);
        
        % Filtering external channels
        if isfield(eeg,'extChan')
            for extIdx = 1:length(eeg.extChan)
                eeg.extChan{extIdx}.data = cellfun(@(x) filtfilthd(hd,x),eeg.extChan{extIdx}.data,'UniformOutput',false);
            end
        end
        
        eeg = cndNewOp(eeg,'LPF');
    end
    
    % Downsampling EEG and external channels
    eeg = cndDownsample(eeg,downFs);
    
    % Filtering - HPF (high-pass filter)
    if bandpassFilterRange(1) > 0 
        hd = getHPFilt(eeg.fs,bandpassFilterRange(1));
        
        % Filtering EEG data
        eeg.data = cellfun(@(x) filtfilthd(hd,x),eeg.data,'UniformOutput',false);
        
        % Filtering external channels
        if isfield(eeg,'extChan')
            for extIdx = 1:length(eeg.extChan)
                eeg.extChan{extIdx}.data = cellfun(@(x) filtfilthd(hd,x),eeg.extChan{extIdx}.data,'UniformOutput',false);
            end  
        end
        
        eeg = cndNewOp(eeg,'HPF');
    end
    
    % Removing initial padding (specific to this dataset)
    if isfield(eeg,'paddingStartSample')
        for tr = 1:length(eeg.data)
            eeg.data{tr} = eeg.data{tr}((1+eeg.paddingStartSample):end,:);
            for extIdx = 1:length(eeg.extChan)
                eeg.extChan{extIdx}.data{tr} = eeg.extChan{extIdx}.data{tr}((1+eeg.paddingStartSample):end,:);
            end
        end
        eeg = cndNewOp(eeg,'EEGPaddingRemoval');
    end
    
    % Replacing bad channels
    if isfield(eeg,'chanlocs')
        for tr = 1:length(eeg.data)
            eeg.data{tr} = removeBadChannels(eeg.data{tr}, eeg.chanlocs, [], 3, 3);
        end
        eeg = cndNewOp(eeg,'BadChannelInterp');
    end

    % Saving preprocessed data
    eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
    disp(['Saving preprocessed EEG data: pre_',eegFilenames(sub).name])
    save(eegPreFilename,'eeg')
    clear eeg
end


%% mTRFtrain and mTRFcrossval
% 
% clear resR
% stims = [10,2];
% for iiStim = 1:2
% % TRF hyperparameters
% tmin = 0;
% tmax = 350;
% lambdas = [1e-9,1e-7,1e-6,1e-4,1e-2,1e0,1e2,1e4,1e6,1e8,1e10];
% % lambdas = [1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8];
% dirTRF = 1; % Forward TRF model
% stimIdx = stims(iiStim);  % 1: envelope; 2: onset vector; 3: pitch; 4: surprise/entropy
% 
% % Loading Stim data
% % stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim.mat'];
% % stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_DREX.mat'];
% stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_LISP.mat'];
% % stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_LISPpy.mat'];
% % stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_Nate.mat'];
% 
% disp(['Loading stimulus data: ','dataStim.mat'])
% load(stimFilename,'stim')
% 
% stim.names{10} = 'Combined';
% for ii = 1:size(stim.data,2)
% %     stim.data{10,ii} = [stim.data{2,ii},stim.data{4,ii},stim.data{5,ii}];
%     stim.data{10,ii} = [stim.data{2,ii},stim.data{4,ii}];
% end
% 
% % TRF
% clear rAll
% clear modelAll rAllElec
% figure;
% for sub = 1:5 %nSubs
%     % Loading preprocessed EEG
%     eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
%     disp(['Loading preprocessed EEG data: pre_',eegFilenames(sub).name])
%     load(eegPreFilename,'eeg')
%     
%     % Re-referencing EEG data
%     eeg = cndReref(eeg,reRefType);
%     
%     % Selecting stimulus feature
%     stimFeature = stim;%{stimIdx};
%     stimFeature.data = stimFeature.data(stimIdx,:);
%     
%     if eeg.fs ~= stimFeature.fs
%         disp('Error: EEG and STIM have different sampling frequency')
%         return
%     end
%     if length(eeg.data) ~= length(stimFeature.data)
%         disp('Error: EEG.data and STIM.data have different number of trials')
%         return
%     end
%     % Making sure that stim and neural data have the same length
%     for tr = 1:length(stimFeature.data)
%         envLen = size(stimFeature.data{tr},1);
%         eegLen = size(eeg.data{tr},1);
%         minLen = min(envLen,eegLen);
%         stimFeature.data{tr} = double(stimFeature.data{tr}(1:minLen,:));
%         eeg.data{tr} = double(eeg.data{tr}(1:minLen,:));
%     end
%     
%     % Normalising EEG data
% %     clear tmpEnv tmpEeg
% %     tmpEnv = stimFeature.data{1};
% %     tmpEeg = eeg.data{1};
% %     for tr = 2:length(stimFeature.data) % getting all values
% %         tmpEnv = cat(1,tmpEnv,stimFeature.data{tr});
% %         tmpEeg = cat(1,tmpEeg,eeg.data{tr});
% %     end
% %     normFactorEnv = std(tmpEnv(:)); clear tmpEnv;
% %     normFactorEeg = std(tmpEeg(:)); clear tmpEeg;
% %     for tr = 1:length(stimFeature.data) % normalisation
% %         stimFeature.data{tr} = stimFeature.data{tr}/normFactorEnv;
% %         eeg.data{tr} = eeg.data{tr}/normFactorEeg;
% %     end
%     
%     % TRF - Compute model weights
%     disp('Running mTRFcrossval')
%     [stats,t] = mTRFcrossval(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas,'verbose',0);
% %     [stats,t] = mTRFcrossval(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas,'method','Tikhonov','verbose',0);
%     [maxR,bestLambda] = max(squeeze(mean(mean(stats.r,1),3)));
%     disp(['r = ',num2str(maxR)])
%     rAll(sub) = maxR;
%     rAllElec(sub,:) = squeeze(mean(stats.r(:,bestLambda,:),3));
%     
%     disp('Running mTRFtrain')
%     model = mTRFtrain(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas(bestLambda),'method','Tikhonov','verbose',0);
%     
%     modelAll(sub) = model;
%     
%     % Plot average TRF
% %     normFlag = 0;
% % %     el = 1;
% %     avgModel = mTRFmodelAvg(modelAll,normFlag);
% %     % Plot avg TRF model
% %     subplot(1,2,1)
% %     % mTRFplot(model,'trf',[],el);
% %     plot(avgModel.t,squeeze(avgModel.w))
% %     title('Envelope avgTRF')
% %     ylabel('Magnitude (a.u.)')
% %     xlim([tmin+50,tmax-50])
% %     if normFlag
% %         ylim([-3,3])
% %     end
% %     axis square
% %     run prepExport.m
% % 
% %     % Plot GFP
% %     subplot(1,2,2)
% %     mTRFplot(avgModel,'gfp',[],'all');
% %     title('Global Field Power')
% %     run prepExport.m
% 
%     disp(['Mean r = ',num2str(mean(rAll))])
%     
%     drawnow;
% end
% resR(:,:,iiStim) = rAllElec;
% end
% 
% % Plot effect of surprise
% surpriseEffect = resR(:,:,1)-resR(:,:,2);
% 
% sortTrialsELIFEpaper = [7,9,3,4,5,10,2,1,8,6];
% rDiffplot=(mean(surpriseEffect(:,1:10),1)+mean(surpriseEffect(:,11:20),1)+mean(surpriseEffect(:,21:30),1))/3;
% r1plot=(mean(resR(:,1:10,1),1)+mean(resR(:,11:20,1),1)+mean(resR(:,21:30,1),1))/3;
% r2plot=(mean(resR(:,1:10,2),1)+mean(resR(:,11:20,2),1)+mean(resR(:,21:30,2),1))/3;
% figure;
% subplot(1,2,1);plot(rDiffplot(sortTrialsELIFEpaper))
% subplot(1,2,2);plot(r1plot(sortTrialsELIFEpaper));hold on;plot(r2plot(sortTrialsELIFEpaper));


%%

stimFiles = {[dataMainFolder,dataCNDSubfolder,'dataStim_DREX.mat'],...
    [dataMainFolder,dataCNDSubfolder,'dataStim_LISP.mat'],...
    [dataMainFolder,dataCNDSubfolder,'dataStim_LISPpy.mat'],...
    [dataMainFolder,dataCNDSubfolder,'dataStim_Nate.mat']};
clear resR
for iiStim = 1:4
% TRF hyperparameters
tmin = 0;
tmax = 350;
lambdas = [1e-9,1e-7,1e-6,1e-4,1e-2,1e0,1e2,1e4,1e6,1e8,1e10];
% lambdas = [1e0,1e1,1e2,1e3,1e4,1e5,1e6,1e7,1e8];
dirTRF = 1; % Forward TRF model
if iiStim <= 3
    stimIdx = 1;
else
    stimIdx = 4;
end

% Loading Stim data
% stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim.mat'];
% stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_DREX.mat'];
stimFilename = stimFiles{iiStim};%[dataMainFolder,dataCNDSubfolder,'dataStim_LISP.mat'];
% stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_LISPpy.mat'];
% stimFilename = [dataMainFolder,dataCNDSubfolder,'dataStim_Nate.mat'];

disp(['Loading stimulus data: ','dataStim.mat'])
load(stimFilename,'stim')

% stim.names{10} = 'Combined';
% for ii = 1:size(stim.data,2)
% %     stim.data{10,ii} = [stim.data{2,ii},stim.data{4,ii},stim.data{5,ii}];
%     stim.data{10,ii} = [stim.data{2,ii},stim.data{4,ii}];
% end

% TRF
clear rAll
clear modelAll rAllElec
figure;
for sub = 1:nSubs
    % Loading preprocessed EEG
    eegPreFilename = [dataMainFolder,dataCNDSubfolder,'pre_',eegFilenames(sub).name];
    disp(['Loading preprocessed EEG data: pre_',eegFilenames(sub).name])
    load(eegPreFilename,'eeg')
    
    % Re-referencing EEG data
    eeg = cndReref(eeg,reRefType);
    
    % Selecting stimulus feature
    stimFeature = stim;%{stimIdx};
    stimFeature.data = stimFeature.data(stimIdx,:);
    for jj = 1:30
        stimFeature.data{jj}(:,2) = stimFeature.data{jj};
        stimFeature.data{jj}(stimFeature.data{jj}(:,2)~=0,2) = 1; % note onset feature
%         stimFeature.data{jj}(stimFeature.data{jj}(:,1)~=0,1) = 1;
    end
    
    if eeg.fs ~= stimFeature.fs
        disp('Error: EEG and STIM have different sampling frequency')
        return
    end
    if length(eeg.data) ~= length(stimFeature.data)
        disp('Error: EEG.data and STIM.data have different number of trials')
        return
    end
    % Making sure that stim and neural data have the same length
    for tr = 1:length(stimFeature.data)
        envLen = size(stimFeature.data{tr},1);
        eegLen = size(eeg.data{tr},1);
        minLen = min(envLen,eegLen);
        stimFeature.data{tr} = double(stimFeature.data{tr}(1:minLen,:));
        eeg.data{tr} = double(eeg.data{tr}(1:minLen,:));
    end
    
    % Normalising EEG data
%     clear tmpEnv tmpEeg
%     tmpEnv = stimFeature.data{1};
%     tmpEeg = eeg.data{1};
%     for tr = 2:length(stimFeature.data) % getting all values
%         tmpEnv = cat(1,tmpEnv,stimFeature.data{tr});
%         tmpEeg = cat(1,tmpEeg,eeg.data{tr});
%     end
%     normFactorEnv = std(tmpEnv(:)); clear tmpEnv;
%     normFactorEeg = std(tmpEeg(:)); clear tmpEeg;
%     for tr = 1:length(stimFeature.data) % normalisation
%         stimFeature.data{tr} = stimFeature.data{tr}/normFactorEnv;
%         eeg.data{tr} = eeg.data{tr}/normFactorEeg;
%     end
    
    % TRF - Compute model weights
    disp('Running mTRFcrossval')
    [stats,t] = mTRFcrossval(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas,'verbose',0);
%     [stats,t] = mTRFcrossval(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas,'method','Tikhonov','verbose',0);
    [maxR,bestLambda] = max(squeeze(mean(mean(stats.r,1),3)));
    disp(['r = ',num2str(maxR)])
    rAll(sub) = maxR;
    rAllElec(sub,:) = squeeze(mean(stats.r(:,bestLambda,:),3));
    
    disp('Running mTRFtrain')
    model = mTRFtrain(stimFeature.data,eeg.data,eeg.fs,dirTRF,tmin,tmax,lambdas(bestLambda),'method','Tikhonov','verbose',0);
    
    modelAll(sub) = model;
    
    % Plot average TRF
%     normFlag = 0;
% %     el = 1;
%     avgModel = mTRFmodelAvg(modelAll,normFlag);
%     % Plot avg TRF model
%     subplot(1,2,1)
%     % mTRFplot(model,'trf',[],el);
%     plot(avgModel.t,squeeze(avgModel.w))
%     title('Envelope avgTRF')
%     ylabel('Magnitude (a.u.)')
%     xlim([tmin+50,tmax-50])
%     if normFlag
%         ylim([-3,3])
%     end
%     axis square
%     run prepExport.m
% 
%     % Plot GFP
%     subplot(1,2,2)
%     mTRFplot(avgModel,'gfp',[],'all');
%     title('Global Field Power')
%     run prepExport.m

    disp(['Mean r = ',num2str(mean(rAll))])
    
    drawnow;
end
resR(:,:,iiStim) = rAllElec;
end

% Plot effect of surprise

% stimFiles = {[dataMainFolder,dataCNDSubfolder,'dataStim_DREX.mat'],...
%     [dataMainFolder,dataCNDSubfolder,'dataStim_LISP.mat'],...
%     [dataMainFolder,dataCNDSubfolder,'dataStim_LISPpy.mat'],...
%     [dataMainFolder,dataCNDSubfolder,'dataStim_Nate.mat']};

%%
sortTrialsELIFEpaper = [7,9,3,4,5,10,2,1,8,6];
for ii = 1:4
    rrplot{ii}=(mean(resR(:,1:10,ii),1)+mean(resR(:,11:20,ii),1)+mean(resR(:,21:30,ii),1))/3;
end
yylim = [0,0.1];
figure;
subplot(1,3,1);bar(1,mean(rrplot{2}(sortTrialsELIFEpaper)));hold on;bar(2,mean(rrplot{3}(sortTrialsELIFEpaper)));ylim(yylim)
xticks(1:2);xticklabels({'Idyom','IdyomPy'});
subplot(1,3,2);bar(1,mean(rrplot{1}(sortTrialsELIFEpaper)));hold on;bar(2,mean(rrplot{3}(sortTrialsELIFEpaper)));ylim(yylim)
xticks(1:2);xticklabels({'Drex','IdyomPy'});
subplot(1,3,3);bar(1,mean(rrplot{4}(sortTrialsELIFEpaper)));hold on;bar(2,mean(rrplot{3}(sortTrialsELIFEpaper)));ylim(yylim)
xticks(1:2);xticklabels({'eLife','IdyomPy'});
% subplot(1,4,4);bar(1,mean(rrplot{1}(sortTrialsELIFEpaper)));hold on;bar(2,mean(rrplot{2}(sortTrialsELIFEpaper)));
% subplot(1,2,2);plot(r1plot(sortTrialsELIFEpaper));hold on;plot(r2plot(sortTrialsELIFEpaper));
