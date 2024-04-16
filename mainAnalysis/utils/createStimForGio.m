function createStimForGio(surpriseFile, pathtoCND_stim, outName)
    All_surp = getSurpriseStim(surpriseFile, pathtoCND_stim);
    load(pathtoCND_stim);
    
    stim.data = All_surp;
    
    save(outName, "stim"); 
end
