clear all
load('../dataCND/eLife_LispForGio.mat')
save('../dataCND/dataStim_LISP.mat')

load('../dataCND/eLife_IDyOMpyForGio.mat')
save('../dataCND/dataStim_LISPpy.mat')

load('../dataCND/eLife_DrexForGio.mat')
save('../dataCND/dataStim_DREX.mat')

% %%
% clear all
% load('../dataCND/eLife_LispForGio.mat')
% stimGui = stim;
% 
% load('../dataCND/dataStim_Nate.mat')
% for ii = 1:30
% %     corr(stim.data{4,ii}(stim.data{5,ii}~=0),stimGui.data{1,ii}(stimGui.data{1,ii}~=0))
%     stim.data{4,ii}(stim.data{4,ii}~=0) = stimGui.data{1,ii}(stimGui.data{1,ii}~=0);
% end
% 
% save('../dataCND/dataStim_LISP.mat','stim')
% 
% 
% load('../dataCND/eLife_IDyOMpyForGio.mat')
% stimGui = stim;
% 
% load('../dataCND/dataStim_Nate.mat')
% for ii = 1:30
% %     corr(stim.data{4,ii}(stim.data{5,ii}~=0),stimGui.data{1,ii}(stimGui.data{1,ii}~=0))
%     stim.data{4,ii}(stim.data{4,ii}~=0) = stimGui.data{1,ii}(stimGui.data{1,ii}~=0);
% end
% 
% save('../dataCND/dataStim_LISPpy.mat','stim')
% 
% load('../dataCND/eLife_DrexForGio.mat')
% stimGui = stim;
% 
% load('../dataCND/dataStim_Nate.mat')
% for ii = 1:30
% %     corr(stim.data{4,ii}(stim.data{5,ii}~=0),stimGui.data{1,ii}(stimGui.data{1,ii}~=0))
%     stim.data{4,ii}(stim.data{4,ii}~=0) = stimGui.data{1,ii}(stimGui.data{1,ii}~=0);
% end
% 
% save('../dataCND/dataStim_DREX.mat','stim')
% 
% %%
% clear all
% load('../dataCND/eLife_LISP.mat')
% load('../dataCND/dataStim_Nate.mat')
% 
% aud = {audio1',audio2',audio3',audio4',audio5',audio6',audio7',audio8',audio9',audio10'};
% 
% for audIdx = 1:10
%     on = stim.data{2,audIdx};
%     env = stim.data{1,audIdx};
%     surGio = stim.data{5,audIdx};
%     
%     aud{audIdx} = aud{audIdx}(find(sum(abs(aud{audIdx}),2)),:);
%     disc = sum(on)-length(aud{audIdx});
%     disp("Trial "+audIdx+"; diff "+disc)
%     
%     % Fixing discrepancy
%     if disc > 0
%         sur = cat(1,aud{audIdx},0.000001*ones(disc,size(aud{audIdx},2)));
%     elseif disc < 0
%         sur = aud{audIdx}(1:end+disc,:);
%     else
%         sur = aud{audIdx};
%     end
%     
%     surVec = zeros(length(on),size(sur,2));
% %     sur = log(sur);
% %     sur(isnan(sur)) = 0;
% %     sur = sur-min(sur);
%     surVec(find(on),:) = sur;
% 
%     stim.data{4,audIdx} = surVec;
%     stim.data{4,audIdx+10} = surVec;
%     stim.data{4,audIdx+20} = surVec;
% end
% stim.names{4} = 'SurpriseIdyomLISPguilhem';
% 
% save('../dataCND/dataStim_LISP.mat')
% 
% %%
% % load('eLife_DREX.mat')
% 
% clear all
% load('../dataCND/eLife_DREX.mat')
% load('../dataCND/dataStim.mat')
% 
% aud = {audio1',audio2',audio3',audio4',audio5',audio6',audio7',audio8',audio9',audio10'};
% 
% for audIdx = 1:10
%     on = stim.data{2,audIdx};
%     env = stim.data{1,audIdx};
%     
%     disc = sum(on)-length(aud{audIdx});
%     disp("Trial "+audIdx+"; diff "+disc)
%     
%     % Fixing discrepancy
%     if disc > 0
%         sur = cat(1,aud{audIdx},zeros(disc,size(aud{audIdx},2)));
%     elseif disc < 0
%         sur = aud{audIdx}(1:end+disc,:);
%     else
%         sur = aud{audIdx};
%     end
%     
%     surVec = zeros(length(on),size(sur,2));
%     surVec(find(on),:) = sur;
%     
%     stim.data{4,audIdx} = surVec;
%     stim.data{4,audIdx+10} = surVec;
%     stim.data{4,audIdx+20} = surVec;
% end
% stim.names{4} = 'SurpriseIdyomDREXguilhem';
% 
% save('../dataCND/dataStim_DREX.mat')
% 
% %%
% clear all
% load('../dataCND/eLife_IDyOMpy.mat')
% load('../dataCND/dataStim.mat')
% 
% aud = {audio1',audio2',audio3',audio4',audio5',audio6',audio7',audio8',audio9',audio10'};
% 
% for audIdx = 1:10
%     on = stim.data{2,audIdx};
%     env = stim.data{1,audIdx};
%     
%     disc = sum(on)-length(aud{audIdx});
%     disp("Trial "+audIdx+"; diff "+disc)
%     
%     % Fixing discrepancy
%     if disc > 0
%         sur = cat(1,aud{audIdx},zeros(disc,size(aud{audIdx},2)));
%     elseif disc < 0
%         sur = aud{audIdx}(1:end+disc,:);
%     else
%         sur = aud{audIdx};
%     end
%     
%     surVec = zeros(length(on),size(sur,2));
%     surVec(find(on),:) = sur;
%     
%     stim.data{4,audIdx} = surVec;
%     stim.data{4,audIdx+10} = surVec;
%     stim.data{4,audIdx+20} = surVec;
% end
% stim.names{4} = 'SurpriseIdyomLISPpyguilhem';
% 
% save('../dataCND/dataStim_LISPpy.mat')