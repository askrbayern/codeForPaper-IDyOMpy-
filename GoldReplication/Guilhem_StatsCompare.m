clear all; 
load('liking_ratings.mat');
liking_save = liking; 
load('all_vals.mat')

model_name = 'bg';
model_name = 'MusicRex';
model_name = 'approx';

model_names = {'bg', 'MusicRex', 'approx'};
N = 30; 
coef = 0.8;

% Bootstraping
corr = [];

rfx = '(1 | Subject)'; % 1a
    
for i=1:N
    disp(i);
    subs=[];
    for j=1:size(liking_save,2)
        subs = [subs; repmat(j, 57, 1)];
    end
    random_indexes = randsample(length(subs), round(coef*length(subs)));

    for model_name = model_names
         subs=[];
        for j=1:size(liking_save,2)
            subs = [subs; repmat(j, 57, 1)];
        end
        % remove NaNs
        I = all_vals.(model_name+"_mDW_IC"); 
        E = all_vals.(model_name+"_mDW_Entropy");
        L = liking_save; 
        
%         I = [I(1:29); I(33:end)]; 
%         E = [E(1:29); E(33:end)]; 
%         L = [L(1:29) L(33:end)]; 
        
        IC = repmat(I, 44, 1);
        ENT = repmat(E, 44, 1); 
        liking = L(:); 
        
                
        subs = subs(random_indexes); 
        IC = IC(random_indexes); 
        ENT = ENT(random_indexes); 
        liking = liking(random_indexes); 
        
        t = table(subs, IC, ENT, liking, 'VariableNames',{'Subject','mDW_IC','mDW_Entropy','LikingRatings'});
        lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy^2) + ',rfx],'fitmethod','reml'); % 2a with reml
        corr.(model_name{1})(i) = lmedwEnt2.Rsquared.Adjusted;    
    end
end

%%
k = 1;
figure; 
for model_name = model_names
    subplot(3, 1, k)
    histfit(corr.(model_name{1})); 
    title(model_name); 
    xlim([-0.1 0.3])
    k = k +1; 
end

%%
figure; 
subplot(3, 1, 1)
histfit(corr.bg); 
title("IDyOM Lisp"); 
xlim([0.15 0.27])

subplot(3, 1, 2)
histfit(corr.approx); 
title("IDyOMpy"); 
xlim([0.15 0.25])

subplot(3, 1, 3)
histfit(corr.MusicRex); 
title("MusiREX"); 
xlim([0.15 0.27])


%%

figure; 
subplot(3, 1, 1)
histfit(corr.approx - corr.bg); 
title("IDyOM Lisp - IDyOMpy"); 
xlim([-0.05 0.05])

subplot(3, 1, 2)
histfit(corr.MusicRex - corr.bg); 
title("MusiRex - IDyOM Lisp"); 
xlim([-0.05 0.05])

subplot(3, 1, 3)
histfit(corr.MusicRex - corr.approx); 
title("MusiRex - IDyOMpy"); 
xlim([-0.05 0.05])


disp("Lisp v.s. IDyOMpy: p-value="+num2str(mean((corr.approx - corr.bg) < 0)));
disp("Lisp v.s. MusiREX: p-value="+num2str(mean((corr.bg - corr.MusicRex) < 0)));
disp("Approx v.s. MusiREX: p-value="+num2str(mean((corr.approx - corr.MusicRex) < 0)));

