function GE = getAllofAFeature(input, feature)
    
    GE = [];
    fn = sort(fieldnames(input));
    for k=1:numel(fn)
        if ~strcmp(fn{k}, "info")
            tmp = getfield(input, fn{k}); 
            tmp = tmp(feature,:);
            GE = [GE tmp];
        end
    end
end

