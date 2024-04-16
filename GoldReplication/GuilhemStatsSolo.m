clear all; 
load('liking_ratings.mat');
load('all_vals.mat')

model_name = 'bg';
model_name = 'MusicRex';
model_name = 'approx';

model_names = {'bg', 'MusicRex', 'approx'};
N = 2500; 

real_corr = [];
for model_name = model_names
    
    subs=[];
    for i=1:size(liking,2)
        subs = [subs; repmat(i, 57, 1)];
    end

    t = table(subs, repmat(all_vals.(model_name+"_mDW_IC"), 44, 1), repmat(all_vals.(model_name+"_mDW_Entropy"), 44, 1), liking(:), 'VariableNames',{'Subject','mDW_IC','mDW_Entropy','LikingRatings'});

    % Entropy
    rfx = '(1 | Subject)'; % 1a
    lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy^2) + ',rfx],'fitmethod','reml'); % 2a with reml

    real_corr.(model_name{1}) = lmedwEnt2.Rsquared.Adjusted;
end

%% Null Models

null_corr = [];
for model_name = model_names
    
    subs=[];
    for i=1:size(liking,2)
        subs = [subs; repmat(i, 57, 1)];
    end

    % Entropy
    rfx = '(1 | Subject)'; % 1a
    
    for i=1:N
        t = table(subs, repmat(shuffle(all_vals.(model_name+"_mDW_IC")), 44, 1), repmat(shuffle(all_vals.(model_name+"_mDW_Entropy")), 44, 1), liking(:), 'VariableNames',{'Subject','mDW_IC','mDW_Entropy','LikingRatings'});
        lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy^2) + ',rfx],'fitmethod','reml'); % 2a with reml
        null_corr.(model_name{1})(i) = lmedwEnt2.Rsquared.Adjusted;    
    end
end

for model_name = model_names
    figure; 
    histfit(null_corr.(model_name{1})); 
    xline(real_corr.(model_name{1})); 
    title(model_name)
    disp(model_name+" p-value="+num2str(sum(null_corr.(model_name{1}) > real_corr.(model_name{1}))/N)) 
end
