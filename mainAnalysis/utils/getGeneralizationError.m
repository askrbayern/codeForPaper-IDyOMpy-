function GE = getGeneralizationError(input)
    
    GE = [];
    fn = fieldnames(input);
    for k=1:numel(fn)-1
        tmp = getfield(input, fn{k}); 
        tmp = mean(tmp(1,:));
        GE(k, 1) = tmp;
    end
end

