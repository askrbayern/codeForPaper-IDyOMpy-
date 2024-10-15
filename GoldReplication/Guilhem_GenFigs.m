clear all; 
load('liking_ratings.mat');
% load('all_vals.mat')
load('all_vals_w_ppm.mat')

% model_names = {'bg', 'MusicRex', 'approx'};
model_names = {'bg', 'MusicRex', 'approx', 'ppm'};
display_names = containers.Map({'bg', 'MusicRex', 'approx', 'ppm'}, {'Lisp', 'MusicRex', 'IDyOMpy', 'IDyOMpy PPM'});
r_squared_values = table('Size', [0, 2], 'VariableTypes', {'string', 'double'}, 'VariableNames', {'Model', 'Adjusted_R_Squared'});


for model_name = model_names

    subs=[];
    for i=1:size(liking,2)
        subs = [subs; repmat(i, 57, 1)];
    end

    display_name = display_names(model_name{1});
    t_bg_nis = table(subs, repmat(all_vals.(model_name+"_mDW_IC"), 44, 1), repmat(all_vals.(model_name+"_mDW_Entropy"), 44, 1), liking(:), 'VariableNames',{'Subject','mDW_IC','mDW_Entropy','LikingRatings'});

    % Entropy
    rfx = '(1 | Subject)'; % 1a
    lmedwEnt2=fitlme(t_bg_nis,['LikingRatings ~ mDW_Entropy^2 + ',rfx],'fitmethod','reml'); % 2a with reml

    % Store R^2
    r_squared_values = [r_squared_values; {display_name, lmedwEnt2.Rsquared.Adjusted}];

    figure; set(gcf,'color','w'); plot(t_bg_nis.mDW_Entropy, lmedwEnt2.fitted,'.'); box off; 
    xlabel('Mean duration-weighted Entropy'); 
    ylabel('Fitted liking rating'); hold on; 
    xs=get(gca,'xlim');

    if length(num2str(round(lmedwEnt2.Rsquared.Adjusted,2)))==3; rtxt = [num2str(round(lmedwEnt2.Rsquared.Adjusted,2)),'0']; else rtxt = num2str(round(lmedwEnt2.Rsquared.Adjusted,2)); end
    if lmedwEnt2.coefTest < .001; ptxt = '< 0.001'; else ptxt = ['= ',num2str(round(lmedwEnt2.coefTest,3))]; end
    title({['Model = ',display_name],strrep(char(lmedwEnt2.Formula),'_','-'),['Adj. R^2 = ',rtxt,', {\itp} ',ptxt]});

    yfit = lmedwEnt2.Coefficients.Estimate(1) + lmedwEnt2.Coefficients.Estimate(2).*[xs(1):.01:xs(2)] + lmedwEnt2.Coefficients.Estimate(3).*[xs(1):.01:xs(2)].^2; plot([xs(1):.01:xs(2)], yfit, 'r', 'linewidth', 1.5); % Trend line for 2a: Liking ~ 1 + Entropy + Entropy^2
end

writetable(r_squared_values, 'r_squared_values.csv');