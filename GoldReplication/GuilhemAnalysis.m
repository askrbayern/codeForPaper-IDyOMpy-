%% Correlations between models

load('all_vals.mat');
[r_ic, p_ic] = corr(all_vals{:,[1:2:end]});
[r_ent, p_ent] = corr(all_vals{:,[2:2:end]});

adata = zeros(size(r_ic)); adata(find(tril(r_ic,-1)))=1;

figure; set(gcf,'color','w');
ax1=subplot(121); imagesc(r_ic,'AlphaData',adata,[-.7,1]); colormap(jet); set(gca,'xtick',1:6); set(gca,'ytick',1:6); box off;
set(gca,'xticklabel',{'Approx','IDyOM lisp','Merging','Music Rex','True Entropies','BG'}); xtickangle(45); set(gca,'yticklabel',{'Approx','IDyOM lisp','Merging','Music Rex','True Entropies','BG'}); 
for i=1:6
    for j=1:6
        if i>j
            if p_ic(i,j) < 0.001; text(j,i,'****','HorizontalAlignment','center','VerticalAlignment','middle');
            elseif p_ic(i,j) < 0.005; text(j,i,'***','HorizontalAlignment','center','VerticalAlignment','middle');
            elseif p_ic(i,j) < 0.01; text(j,i,'**','HorizontalAlignment','center','VerticalAlignment','middle');
            elseif p_ic(i,j) < 0.05; text(j,i,'*','HorizontalAlignment','center','VerticalAlignment','middle');
            end
        end
    end
end
title('mDW-IC values');


ax2=subplot(122); imagesc(r_ent,'AlphaData',adata,[-.7,1]); colormap(jet); set(gca,'xtick',1:6); set(gca,'ytick',1:6); box off;
set(gca,'xticklabel',{'Approx','IDyOM lisp','Merging','Music Rex','True Entropies','BG'}); xtickangle(45); set(gca,'yticklabel',{'Approx','IDyOM lisp','Merging','Music Rex','True Entropies','BG'}); 
for i=1:6
    for j=1:6
        if i>j
            if p_ent(i,j) < 0.001; text(j,i,'****','HorizontalAlignment','center','VerticalAlignment','middle');
            elseif p_ent(i,j) < 0.005; text(j,i,'***','HorizontalAlignment','center','VerticalAlignment','middle');
            elseif p_ent(i,j) < 0.01; text(j,i,'**','HorizontalAlignment','center','VerticalAlignment','middle');
            elseif p_ent(i,j) < 0.05; text(j,i,'*','HorizontalAlignment','center','VerticalAlignment','middle');
            end
        end
    end
end
title('mDW-Entropy values');

set(gcf,'position',[687,918,873,420]);
h1=colorbar('location','eastoutside'); title(h1,'Pearson''s {\itr}');
set(ax1,'position',[.13,.19,.3159,.7350]); set(ax2,'position',[.5703,.19,.3159,.7350]);

%% Analyzing each model

load('true_entropies.mat');
clear info;
varlist=who('song*');

varlist = varlist([11, 22, 33, 44, 53:57, 1:10, 12:21, 23:32, 34:43, 45:52]);

filename = 'BG_ioiratio_cpitch_summary.csv';
delimiter = ','; startRow = 2; formatSpec = '%f%f%s%f%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r'); 
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
fclose(fileID);
melodyid = dataArray{:, 1}; 
noteid = dataArray{:, 2}; 
melodyname = dataArray{:, 3}; 
dur = dataArray{:, 4}; 
onset = dataArray{:, 5}; 
informationcontent = dataArray{:, 11}; 
entropy1 = dataArray{:, 12};
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

stimuli=unique(melodyid);
for i=1:numel(varlist)
    
    if strfind(varlist{i},'AloneTogether') | strfind(varlist{i},'ConAlma') | strfind(varlist{i},'Syrinx_excerpt2')
        bpm=144; % Sets the bpm for the stimuli, to determine the time axes of the figures.
    elseif strfind(varlist{i},'MaidenVoyage')
        bpm=120;
    else
        bpm=96; % Sets the bpm for the stimuli, to determine the time axes of the figures.
    end
    btu=(60/24)/bpm; % Based on 24=quarter note, 12=eighth note, etc.

    idx = find(strcmp(varlist{i}(6:end),melodyname));
    
    ons=onset(idx);
    durations=dur(idx);
    if strfind(varlist{i},'FantasiasNo5') % For this piece we only used the first 39 notes in the experiment!
        ons=ons(1:39);
        durations=durations(1:39);
    end
    ttot(i)=(durations(end)+ons(end))*btu;
    tdurs{i}=durations*btu;
    
%     ic{i}=informationcontent(idx);
    eval(['ic{i} = ',varlist{i},'(1,:)'';']);

    if strfind(varlist{i},'FantasiasNo5') % For this piece we only used the first 39 notes in the experiment!
        ic{i}=ic{i}(1:39);
    end
    mDW_IC(i)=sum(ic{i}.*tdurs{i})/ttot(i); % Weighted Mean IC = (IC_1*Dur_1 + IC_2*Dur_2 + ...)/(Dur_Total)
    
%     ent{i}=entropy1(idx);
    eval(['ent{i} = ',varlist{i},'(2,:)'';']);

    if strfind(varlist{i},'FantasiasNo5') % For this piece we only used the first 39 notes in the experiment!
        ent{i}=ent{i}(1:39);
    end
    mDW_Entropy(i)=sum(ent{i}.*tdurs{i})/ttot(i);
        
    clear ons durations idx btu 
end

clearvars -except mDW_IC mDW_Entropy



load('liking_ratings.mat');

%% % OR, if using bg_vals, skip the above and go straight here:
load('bg_vals.mat'); mDW_IC = bg_vals(1,:); mDW_Entropy = bg_vals(2,:);

subs=[];
for i=1:size(liking,2)
    subs = [subs; repmat(i, 57, 1)];
end

t = table(subs, repmat(mDW_IC', 44, 1), repmat(mDW_Entropy', 44, 1), liking(:), 'VariableNames',{'Subject','mDW_IC','mDW_Entropy','LikingRatings'});

%% Mixed-effects analyses

% % IC LME:

% Start with the full, "beyond optimal" model (per Diggle et al., 2002), using REML to compare nested random-effects structures:
% Try different random-effects structures:
dwIClme1a=fitlme(t,'LikingRatings ~ (mDW_IC^2) + (1 | Subject)','FitMethod','REML');
dwIClme1b=fitlme(t,'LikingRatings ~ (mDW_IC^2) + (1 + mDW_IC^2 | Subject)','FitMethod','REML');
dwIClme1c=fitlme(t,'LikingRatings ~ (mDW_IC^2) + (1 + mDW_IC:mDW_IC | Subject)','FitMethod','REML');
dwIClme1d=fitlme(t,'LikingRatings ~ (mDW_IC^2) + (1 + mDW_IC | Subject)','FitMethod','REML');
compare(dwIClme1a,dwIClme1b)
compare(dwIClme1a,dwIClme1c)
compare(dwIClme1a,dwIClme1d)
compare(dwIClme1c,dwIClme1b)
compare(dwIClme1d,dwIClme1b)
% dwIClme1d wins for approx and bg_vals and mergingapproach and true_entropies
% dwIClme1a wins for IDyOM_lisp and MusicRex

rfx = '(1 + mDW_IC | Subject)'; % 1d
% rfx = '(1 | Subject)'; % 1a

% Having settled on the optimal random-effects structure, now optimize the fixed effects with ML estimation and LR tests:
clearvars dwIClme*
dwIClme2a=fitlme(t,['LikingRatings ~ (mDW_IC + mDW_IC:mDW_IC) + ',rfx]);
dwIClme2b=fitlme(t,['LikingRatings ~ (mDW_IC:mDW_IC) + ',rfx]);
dwIClme2c=fitlme(t,['LikingRatings ~ mDW_IC + ',rfx]);
compare(dwIClme2b,dwIClme2a) % lqm vs. qm
compare(dwIClme2c,dwIClme2a) % lqm vs. lm
compare(dwIClme2c,dwIClme2b) % qm vs. lm (for AIC comparison)
% dwIClme2c wins for approx and mergingapproach and true_entropies
% dwIClme2a wins for bg_vals and MusicRex
% dwIClme2b wins for IDyOM_lisp


lmedwIC2=fitlme(t,['LikingRatings ~ mDW_IC + ',rfx],'fitmethod','reml'); % 2c with reml for approx
% lmedwIC2=fitlme(t,['LikingRatings ~ (mDW_IC + mDW_IC:mDW_IC) + ',rfx],'fitmethod','reml'); % 2a with reml for bg_vals
% lmedwIC2=fitlme(t,['LikingRatings ~ (mDW_IC:mDW_IC) + ',rfx],'fitmethod','reml'); % 2b with reml for IDyOM_lisp
clearvars dwIClme*

figure; set(gcf,'color','w'); plot(t.mDW_IC,lmedwIC2.fitted,'.'); box off; xlabel('Mean duration-weighted IC'); ylabel('Fitted liking rating'); hold on; xs=get(gca,'xlim');

% mdl = 'approx';
% mdl = 'IDyOM lisp';
% mdl = 'Merging Approach';
% mdl = 'Music Rex';
% mdl = 'True Entropies';
mdl = 'IDyOM (BG)';

if length(num2str(round(lmedwIC2.Rsquared.Adjusted,2)))==3; rtxt = [num2str(round(lmedwIC2.Rsquared.Adjusted,2)),'0']; else rtxt = num2str(round(lmedwIC2.Rsquared.Adjusted,2)); end
if lmedwIC2.coefTest < .001; ptxt = '< 0.001'; else ptxt = ['= ',num2str(round(lmedwIC2.coefTest,3))]; end
title({['Model = ',mdl],strrep(char(lmedwIC2.Formula),'_','-'),['Adj. R^2 = ',rtxt,', {\itp} ',ptxt]});

yfit = lmedwIC2.Coefficients.Estimate(1) + lmedwIC2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)]; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2c: Liking ~ 1 + IC
% yfit = lmedwIC2.Coefficients.Estimate(1) + lmedwIC2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)] + lmedwIC2.Coefficients.Estimate(3).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2a: Liking ~ 1 + IC^2
% yfit = lmedwIC2.Coefficients.Estimate(1) + lmedwIC2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2b: Liking ~ 1 + IC^2

% Compare nested models only with ML estimation (not REML):
lmedwIC=fitlme(t,['LikingRatings ~ (mDW_IC) + ',rfx]);
lmedwIC2only=fitlme(t,['LikingRatings ~ (mDW_IC:mDW_IC) + ',rfx]);
lmedwIC2=fitlme(t,['LikingRatings ~ (mDW_IC + mDW_IC:mDW_IC) + ',rfx]);
compare(lmedwIC,lmedwIC2)
compare(lmedwIC2only,lmedwIC2)

saveas(gcf,[mdl,'_LikingByIC.png']);


%%

meanL = nanmean(liking, 2); 
entr = mDW_IC'; 

a = [meanL(1:29); meanL(33:end)]; 
b = [entr(1:29); entr(33:end)]; 

figure; plot(a); hold on; plot(b); 
figure; scatter(a, b);
corr(a, b)

all_corr = []; 
for n=1:1000
    all_corr = [all_corr corr(a, shuffle(b))]; 
end

figure; histfit(all_corr)


%% mDW_Entropy

% Start with the full, "beyond optimal" model (per Diggle et al., 2002), using REML to compare nested random-effects structures:

% % Try different random-effects structures:
% dwEntlme1a=fitlme(t,'LikingRatings ~ (mDW_Entropy^2) + (1 | Subject)','FitMethod','REML');
% dwEntlme1b=fitlme(t,'LikingRatings ~ (mDW_Entropy^2) + (1 + mDW_Entropy^2 | Subject)','FitMethod','REML');
% dwEntlme1c=fitlme(t,'LikingRatings ~ (mDW_Entropy^2) + (1 + mDW_Entropy:mDW_Entropy | Subject)','FitMethod','REML');
% dwEntlme1d=fitlme(t,'LikingRatings ~ (mDW_Entropy^2) + (1 + mDW_Entropy | Subject)','FitMethod','REML');
% compare(dwEntlme1a,dwEntlme1b)
% compare(dwEntlme1a,dwEntlme1c)
% compare(dwEntlme1a,dwEntlme1d)
% dwEntlme1a wins for approx and bg_vals and IDyOM_lisp and mergingapproach and MusicRex and true_entropies

rfx = '(1 | Subject)'; % 1a

% Having settled on the optimal random-effects structure, now optimize the fixed effects with ML estimation and LR tests:
clearvars dwEntlme*
% dwEntlme2a=fitlme(t,['LikingRatings ~ (mDW_Entropy^2) + ',rfx]);
% dwEntlme2b=fitlme(t,['LikingRatings ~ (mDW_Entropy:mDW_Entropy) + ',rfx]);
% dwEntlme2c=fitlme(t,['LikingRatings ~ mDW_Entropy + ',rfx]);
% compare(dwEntlme2b,dwEntlme2a) % lqm vs. qm
% compare(dwEntlme2c,dwEntlme2a) % lqm vs. lm
% compare(dwEntlme2c,dwEntlme2b) % qm vs. lm
% dwEntlme2a wins for approx and bg_vals and mergingapproach and true_entropies
% dwEntlme2b wins for IDyOM_lisp and MusicRex

lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy^2) + ',rfx],'fitmethod','reml'); % 2a with reml
%lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy:mDW_Entropy) + ',rfx],'fitmethod','reml'); % 2b with reml

clearvars dwEntlme*

figure; set(gcf,'color','w'); plot(t.mDW_Entropy, lmedwEnt2.fitted,'.'); box off; 
xlabel('Mean duration-weighted Entropy'); 
ylabel('Fitted liking rating'); hold on; 
xs=get(gca,'xlim');


% mdl = 'approx';
% mdl = 'IDyOM lisp';
% mdl = 'Merging Approach';
% mdl = 'Music Rex';
% mdl = 'True Entropies';
mdl = 'IDyOM (BG)';

if length(num2str(round(lmedwEnt2.Rsquared.Adjusted,2)))==3; rtxt = [num2str(round(lmedwEnt2.Rsquared.Adjusted,2)),'0']; else rtxt = num2str(round(lmedwEnt2.Rsquared.Adjusted,2)); end
if lmedwEnt2.coefTest < .001; ptxt = '< 0.001'; else ptxt = ['= ',num2str(round(lmedwEnt2.coefTest,3))]; end
title({['Model = ',mdl],strrep(char(lmedwEnt2.Formula),'_','-'),['Adj. R^2 = ',rtxt,', {\itp} ',ptxt]});

yfit = lmedwEnt2.Coefficients.Estimate(1) + lmedwEnt2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)] + lmedwEnt2.Coefficients.Estimate(3).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2a: Liking ~ 1 + Entropy + Entropy^2
% yfit = lmedwEnt2.Coefficients.Estimate(1) + lmedwEnt2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2b: Liking ~ 1 + Entropy^2


% % Compare nested models only with ML estimation (not REML):
% lmedwEnt=fitlme(t,['LikingRatings ~ (mDW_Entropy) + ',rfx]);
% lmedwEnt2only=fitlme(t,['LikingRatings ~ (mDW_Entropy:mDW_Entropy) + ',rfx]);
% lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy + mDW_Entropy:mDW_Entropy) + ',rfx]);
% compare(lmedwEnt,lmedwEnt2)
% compare(lmedwEnt2only,lmedwEnt2)
% compare(lmedwEnt2only,lmedwEnt)

saveas(gcf,[mdl,'_LikingByEntropy.png']);



%% My Entropy

mdl = 'IDyOM (BG)';

rfx = '(1 | Subject)'; % 1a
lmedwEnt2=fitlme(t,['LikingRatings ~ (mDW_Entropy^2) + ',rfx],'fitmethod','reml'); % 2a with reml

figure; set(gcf,'color','w'); plot(t.mDW_Entropy, lmedwEnt2.fitted,'.'); box off; 
xlabel('Mean duration-weighted Entropy'); 
ylabel('Fitted liking rating'); hold on; 
xs=get(gca,'xlim');

if length(num2str(round(lmedwEnt2.Rsquared.Adjusted,2)))==3; rtxt = [num2str(round(lmedwEnt2.Rsquared.Adjusted,2)),'0']; else rtxt = num2str(round(lmedwEnt2.Rsquared.Adjusted,2)); end
if lmedwEnt2.coefTest < .001; ptxt = '< 0.001'; else ptxt = ['= ',num2str(round(lmedwEnt2.coefTest,3))]; end
title({['Model = ',mdl],strrep(char(lmedwEnt2.Formula),'_','-'),['Adj. R^2 = ',rtxt,', {\itp} ',ptxt]});

yfit = lmedwEnt2.Coefficients.Estimate(1) + lmedwEnt2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)] + lmedwEnt2.Coefficients.Estimate(3).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2a: Liking ~ 1 + Entropy + Entropy^2


saveas(gcf,[mdl,'_LikingByEntropy.png']);

%% mDW-IC X mDW-Entropy

% First z-score the IC and Entropy values for comparison:
zmDW_ICs = zscore(mDW_IC); t.zmDW_IC = repmat(zmDW_ICs', 44, 1);
zmDW_Entropies = zscore(mDW_Entropy); t.zmDW_Entropy = repmat(zmDW_Entropies', 44, 1);

% Try different random-effects structures:
dwALLlme1a=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 | Subject)','FitMethod','REML');
dwALLlme1b=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy^2)*(zmDW_IC^2) | Subject)','FitMethod','REML');
dwALLlme1c=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy^2)*(zmDW_IC:zmDW_IC) | Subject)','FitMethod','REML');
dwALLlme1d=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy^2)*zmDW_IC | Subject)','FitMethod','REML');
dwALLlme1e=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy^2) | Subject)','FitMethod','REML');
dwALLlme1f=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy:zmDW_Entropy)*(zmDW_IC^2) | Subject)','FitMethod','REML');
dwALLlme1g=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy:zmDW_Entropy)*(zmDW_IC:zmDW_IC) | Subject)','FitMethod','REML');
dwALLlme1h=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy:zmDW_Entropy)*zmDW_IC | Subject)','FitMethod','REML');
dwALLlme1i=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + (zmDW_Entropy:zmDW_Entropy) | Subject)','FitMethod','REML');
dwALLlme1j=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + zmDW_Entropy*(zmDW_IC^2) | Subject)','FitMethod','REML');
dwALLlme1k=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + zmDW_Entropy*(zmDW_IC:zmDW_IC) | Subject)','FitMethod','REML');
dwALLlme1l=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + zmDW_Entropy*zmDW_IC | Subject)','FitMethod','REML');
dwALLlme1m=fitlme(t,'LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + (1 + zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme1n=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC^2)*(zmDW_Entropy^2) | Subject)','FitMethod','REML');
dwALLlme1o=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC^2)*(zmDW_Entropy:zmDW_Entropy) | Subject)','FitMethod','REML');
dwALLlme1p=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC^2)*zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme1q=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC^2) | Subject)','FitMethod','REML');
dwALLlme1r=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC:zmDW_IC)*(zmDW_Entropy^2) | Subject)','FitMethod','REML');
dwALLlme1s=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC:zmDW_IC)*(zmDW_Entropy:zmDW_Entropy) | Subject)','FitMethod','REML');
dwALLlme1t=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC:zmDW_IC)*zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme1u=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + (zmDW_IC:zmDW_IC) | Subject)','FitMethod','REML');
dwALLlme1v=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC*(zmDW_Entropy^2) | Subject)','FitMethod','REML');
dwALLlme1w=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC*(zmDW_Entropy:zmDW_Entropy) | Subject)','FitMethod','REML');
dwALLlme1x=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC*zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme1y=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC | Subject)','FitMethod','REML');
vars = who;
mdl_idx=find(~cellfun(@isempty,regexp(vars,'dwALLlme1')));
for i=1:numel(mdl_idx)
    eval(cell2mat(strcat('mdlAICs(i)=',vars(mdl_idx(i)),'.ModelCriterion.AIC;')));
end
[~,idx]=min(mdlAICs); disp(['winning model is ',cell2mat(vars(mdl_idx(idx)))]); clear vars mdl_idx idx mdlAICs
% dwALLlme1y wins for approx and bg_vals and mergingapproach and true_entropies
% dwALLlme1a wins for IDyOM_lisp and MusicRex


dwALLlme2a=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC + zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme2b=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC + zmDW_Entropy:zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme2c=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC + zmDW_Entropy^2 | Subject)','FitMethod','REML');
dwALLlme2d=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC:zmDW_IC + zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme2e=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC:zmDW_IC + zmDW_Entropy:zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme2f=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC:zmDW_IC + zmDW_Entropy^2 | Subject)','FitMethod','REML');
dwALLlme2g=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC^2 + zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme2h=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC^2 + zmDW_Entropy:zmDW_Entropy | Subject)','FitMethod','REML');
dwALLlme2i=fitlme(t,'LikingRatings ~ (zmDW_IC^2)*(zmDW_Entropy^2) + (1 + zmDW_IC^2 + zmDW_Entropy^2 | Subject)','FitMethod','REML');
vars = who;
mdl_idx=find(~cellfun(@isempty,regexp(vars,'dwALLlme2')));
for i=1:numel(mdl_idx)
    eval(cell2mat(strcat('mdlAICs(i)=',vars(mdl_idx(i)),'.ModelCriterion.AIC;')));
end
[~,idx]=min(mdlAICs); disp(['winning model is ',cell2mat(vars(mdl_idx(idx)))]); clear vars mdl_idx idx mdlAICs
% dwALLlme2a wins for approx and bg_vals and mergingapproach and true_entropies
% dwALLlme2b wins for IDyOM_lisp
% dwALLlme2e wins for MusicRex


compare(dwALLlme1a,dwALLlme2b)
compare(dwALLlme1a,dwALLlme2e)
compare(dwALLlme1y,dwALLlme2a)
% dwALLlme1y wins for approx and bg_vals and mergingapproach and true_entropies
% dwALLlme1a wins for IDyOM_lisp and MusicRex

rfx = '(1 + zmDW_IC | Subject)'; % 1y
rfx = '(1 | Subject)'; % 1a

% Having settled on the optimal random-effects structure, now optimize the fixed effects with ML estimation and LR tests:
clearvars dwALLlme*
dwALLlme3a=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + ',rfx]);
dwALLlme3b=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC:zmDW_IC) + ',rfx]);
dwALLlme3c=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC) + ',rfx]);
dwALLlme3d=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy)*(zmDW_IC^2) + ',rfx]);
dwALLlme3e=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy)*(zmDW_IC:zmDW_IC) + ',rfx]);
dwALLlme3f=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy)*(zmDW_IC) + ',rfx]);
dwALLlme3g=fitlme(t,['LikingRatings ~ (zmDW_Entropy)*(zmDW_IC^2) + ',rfx]);
dwALLlme3h=fitlme(t,['LikingRatings ~ (zmDW_Entropy)*(zmDW_IC:zmDW_IC) + ',rfx]);
dwALLlme3i=fitlme(t,['LikingRatings ~ (zmDW_Entropy)*(zmDW_IC) + ',rfx]);
dwALLlme3j=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2) + (zmDW_IC^2) + ',rfx]);
dwALLlme3k=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2) + (zmDW_IC:zmDW_IC) + ',rfx]);
dwALLlme3l=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2) + (zmDW_IC) + ',rfx]);
dwALLlme3m=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy) + (zmDW_IC^2) + ',rfx]);
dwALLlme3n=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy) + (zmDW_IC:zmDW_IC) + ',rfx]);
dwALLlme3o=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy) + (zmDW_IC) + ',rfx]);
dwALLlme3p=fitlme(t,['LikingRatings ~ (zmDW_Entropy) + (zmDW_IC^2) + ',rfx]);
dwALLlme3q=fitlme(t,['LikingRatings ~ (zmDW_Entropy) + (zmDW_IC:zmDW_IC) + ',rfx]);
dwALLlme3r=fitlme(t,['LikingRatings ~ (zmDW_Entropy) + (zmDW_IC) + ',rfx]);
compare(dwALLlme3b,dwALLlme3a)
compare(dwALLlme3c,dwALLlme3a)
compare(dwALLlme3d,dwALLlme3c)
compare(dwALLlme3e,dwALLlme3c)
compare(dwALLlme3f,dwALLlme3e)
compare(dwALLlme3g,dwALLlme3e)
compare(dwALLlme3h,dwALLlme3e)
compare(dwALLlme3i,dwALLlme3h)
compare(dwALLlme3j,dwALLlme3i)
compare(dwALLlme3k,dwALLlme3j)
compare(dwALLlme3l,dwALLlme3j)
compare(dwALLlme3m,dwALLlme3j)
compare(dwALLlme3n,dwALLlme3j)
compare(dwALLlme3o,dwALLlme3j)
compare(dwALLlme3p,dwALLlme3j)
compare(dwALLlme3q,dwALLlme3p)
compare(dwALLlme3r,dwALLlme3p)
vars = who;
mdl_idx=find(~cellfun(@isempty,regexp(vars,'dwALLlme3')));
for i=1:numel(mdl_idx)
    eval(cell2mat(strcat('mdlAICs(i)=',vars(mdl_idx(i)),'.ModelCriterion.AIC;')));
end
[~,idx]=min(mdlAICs); disp(['winning model is ',cell2mat(vars(mdl_idx(idx)))]); clear vars mdl_idx idx mdlAICs

% dwALLlme3c wins for approx
% dwALLlme3d wins for bg_vals
% dwALLlme3a wins for IDyOM_lisp and mergingapproach and MusicRex and true_entropies


% lmeALL=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC) + ',rfx],'fitmethod','reml'); % 3c with reml
% lmeALL=fitlme(t,['LikingRatings ~ (zmDW_Entropy:zmDW_Entropy)*(zmDW_IC^2) + ',rfx],'fitmethod','reml'); % 3d with reml
lmeALL=fitlme(t,['LikingRatings ~ (zmDW_Entropy^2)*(zmDW_IC^2) + ',rfx],'fitmethod','reml'); % 3a with reml
clearvars dwALLlme*

lmeALL.coefTest
lmeALL.Rsquared

[X,Y]=meshgrid(min(t.zmDW_IC)-.2:.01:max(t.zmDW_IC)+.2, linspace(min(t.zmDW_Entropy)-.2,max(t.zmDW_Entropy)+.2,numel(min(t.zmDW_IC)-.2:.01:max(t.zmDW_IC)-.2)));
redblue=[0,0,1; 1,1,1; 1,0,0]; rbmap=[[linspace(redblue(1,1),redblue(2,1),100)', linspace(redblue(1,2),redblue(2,2),100)', linspace(redblue(1,3),redblue(2,3),100)'];
    [linspace(redblue(2,1),redblue(3,1),100)', linspace(redblue(2,2),redblue(3,2),100)', linspace(redblue(2,3),redblue(3,3),100)']];

% 3c:
% Z_ALL = lmeALL.Coefficients{1,2} + lmeALL.Coefficients{2,2}.*X + lmeALL.Coefficients{3,2}.*Y + lmeALL.Coefficients{4,2}.*X.*Y + lmeALL.Coefficients{5,2}.*(Y.^2) + lmeALL.Coefficients{6,2}.*X.*(Y.^2);

% % 3d:
% Z_ALL = lmeALL.Coefficients{1,2} + lmeALL.Coefficients{2,2}.*X + lmeALL.Coefficients{3,2}.*(X.^2) + lmeALL.Coefficients{4,2}.*(Y.^2) + lmeALL.Coefficients{5,2}.*X.*(Y.^2) + lmeALL.Coefficients{6,2}.*(X.^2).*(Y.^2);

% % 3a:
Z_ALL = lmeALL.Coefficients{1,2} + lmeALL.Coefficients{2,2}.*X + lmeALL.Coefficients{3,2}.*Y + lmeALL.Coefficients{4,2}.*X.*Y + lmeALL.Coefficients{5,2}.*(X.^2) + lmeALL.Coefficients{6,2}.*(Y.^2) + ...
    lmeALL.Coefficients{7,2}.*(X.^2).*Y + lmeALL.Coefficients{8,2}.*X.*(Y.^2) + lmeALL.Coefficients{9,2}.*(X.^2).*(Y.^2);


figure; set(gcf,'color','w'); ax1=axes; s=surf(X,Y,Z_ALL,'EdgeAlpha',0); colormap(rbmap); h1=colorbar(ax1,'location','southoutside'); grid off;
xlabel('mDW-IC (z-scored)'); ylabel('mDW-Entropy (z-scored)'); view(90,-90); set(gca,'xlim',[min(min(X)),max(max(X))]); set(gca,'ylim',[min(min(Y)),max(max(Y))]);
set(ax1,'Position',[.13,.2644,.775,.5706]); set(h1,'Position',[0.2817    0.0644    0.4527    0.0383]);
text(-2.85,-.3081,'Fitted liking rating','HorizontalAlignment','center'); hold on; c=contour(X,Y,Z_ALL,6,'k');


% mdl = 'approx';
% mdl = 'IDyOM lisp';
% mdl = 'Merging Approach';
% mdl = 'Music Rex';
% mdl = 'True Entropies';
% mdl = 'IDyOM (BG)';

if length(num2str(round(lmeALL.Rsquared.Adjusted,2)))==3; rtxt = [num2str(round(lmeALL.Rsquared.Adjusted,2)),'0']; else rtxt = num2str(round(lmeALL.Rsquared.Adjusted,2)); end
if lmeALL.coefTest < .001; ptxt = '< 0.001'; else ptxt = ['= ',num2str(round(lmeALL.coefTest,3))]; end
title({['Model = ',mdl],strrep(strrep(char(lmeALL.Formula),'_','-'),':','*'),['Adj. R^2 = ',rtxt,', {\itp} ',ptxt]});
set(ax1,'Units','centimeters'); apos = get(ax1,'position'); set(ax1,'Units','normalized'); set(h1,'Units','centimeters'); bpos = get(h1,'position'); set(h1,'Units','normalized');



% Now adjust figure size to fit title, and then:
set(ax1,'Units','centimeters'); apos2 = get(ax1,'position'); set(h1,'Units','centimeters'); bpos2 = get(h1,'position'); 
apos3 = apos; apos3(1) = apos2(1) + apos2(3)./2 - apos(3)./2; set(ax1,'position',apos3);
bpos3 = bpos; bpos3(1) = bpos2(1) + bpos2(3)./2 - bpos(3)./2; set(h1,'position',bpos3);



saveas(gcf,[mdl,'_LikingByICxEntropy.png']);




