function GE = getEntropy(input)
    
    GE = [];
    fn = fieldnames(input);
    for k=1:numel(fn)-1
        tmp = getfield(input, fn{k}); 
        tmp = mean(tmp(2,:));
        GE(k, 1) = tmp;
    end
end