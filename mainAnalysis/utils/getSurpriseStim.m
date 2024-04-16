function stim = getSurpriseStim(surpriseFile, pathtoCND_stim)

    load(pathtoCND_stim);
    stim = stim.data(2,:);

    load(surpriseFile);

    % We replace with the new surprise
    stim_tmp = {};
    for i=1:10
        tmp = getOnsetfromMidi("utils/midi/eLife/audio"+num2str(i)+".mid", 64, 0);
        ind = find(tmp);
        ind = ind - ind(1) + find(stim{i}, 1); 
        ind = round(ind * (find(stim{i}, 1, 'last')/ind(end)));
        ind = ind + (ind(1) == 0);
        tmp(find(tmp)) = 0; 
        tmp(ind)=1;
        tmp_surp = eval("audio"+num2str(i));
        tmp(ind) = tmp_surp(1,:);
        stim_tmp{i} = tmp';
    end
    
    stim = cat(1, [stim_tmp, stim_tmp, stim_tmp]);
end
