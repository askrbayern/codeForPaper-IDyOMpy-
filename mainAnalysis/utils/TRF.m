function [kernels_real, r_real, bestLamb] = TRF(eeg, onsets)

    for i=1:length(eeg)
        min_size = min(size(onsets{i}, 1), size(eeg{i}, 1));
        eeg{i} = eeg{i}(1:min_size,:);
        onsets{i} = onsets{i}(1:min_size,:);
    end

    downFs = 64;
    map = 1;
    tmin = -200;
    tmax = 600;
    lambdas = [1e-6, 1e-5, 1e-4, 1e-3, 0.01, 0.1, 1, 10, 100];
    %lambdas = [0.1];
    clear rAll modelsReal

    [rAll(:,:,:),~,~,~,modelsReal] = ...
        mTRFcrossval(onsets, eeg, downFs,map,tmin,tmax,lambdas); % nonSilentSamp

    [~,bestLambda] = max(mean(mean(rAll(:,:,:),3),1));
    r_real = squeeze(rAll(:,bestLambda,:));
    kernels_real = squeeze(mean(modelsReal(:,bestLambda,:,:),1));
    kernels_real = reshape(kernels_real, size(onsets{i}, 2), size(kernels_real, 1)/size(onsets{i}, 2), 64);
    kernels_real = kernels_real(:,2:end,:);
    bestLamb = lambdas(bestLambda); 
    
end


