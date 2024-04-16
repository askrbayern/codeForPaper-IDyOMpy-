clear all; 
load('liking_ratings.mat');
load('all_vals.mat')

model_name = 'bg';
model_name = 'MusicRex';
model_name = 'approx';

model_names = {'bg', 'MusicRex', 'approx'};

for model_name = model_names
    
    subs=[];
    for i=1:size(liking,2)
        subs = [subs; repmat(i, 57, 1)];
    end

    t_bg_nis = table(subs, repmat(all_vals.(model_name+"_mDW_IC"), 44, 1), repmat(all_vals.(model_name+"_mDW_Entropy"), 44, 1), liking(:), 'VariableNames',{'Subject','mDW_IC','mDW_Entropy','LikingRatings'});

    % Entropy
    rfx = '(1 | Subject)'; % 1a
    lmedwEnt2=fitlme(t_bg_nis,['LikingRatings ~ mDW_Entropy^2 + ',rfx],'fitmethod','reml'); % 2a with reml

    figure; set(gcf,'color','w'); plot(t_bg_nis.mDW_Entropy, lmedwEnt2.fitted,'.'); box off; 
    xlabel('Mean duration-weighted Entropy'); 
    ylabel('Fitted liking rating'); hold on; 
    xs=get(gca,'xlim');

    if length(num2str(round(lmedwEnt2.Rsquared.Adjusted,2)))==3; rtxt = [num2str(round(lmedwEnt2.Rsquared.Adjusted,2)),'0']; else rtxt = num2str(round(lmedwEnt2.Rsquared.Adjusted,2)); end
    if lmedwEnt2.coefTest < .001; ptxt = '< 0.001'; else ptxt = ['= ',num2str(round(lmedwEnt2.coefTest,3))]; end
    title({['Model = ',model_name{1}],strrep(char(lmedwEnt2.Formula),'_','-'),['Adj. R^2 = ',rtxt,', {\itp} ',ptxt]});

    yfit = lmedwEnt2.Coefficients.Estimate(1) + lmedwEnt2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)] + lmedwEnt2.Coefficients.Estimate(3).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2a: Liking ~ 1 + Entropy + Entropy^2
end