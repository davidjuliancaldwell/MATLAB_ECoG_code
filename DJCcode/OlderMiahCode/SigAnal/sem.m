function se = sem(x, dim)
    if (~exist('dim', 'var'))
        dim = 1;
    end
    
    l = size(x, dim);
    se = std(x, 0, dim) / sqrt(l);
end