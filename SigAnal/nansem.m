function se = nansem(x, dim)
    if (~exist('dim', 'var'))
        dim = 1;
    end
    
    ls = sum(~isnan(x), dim);
    se = nanstd(x, 0, dim) ./ sqrt(ls);
end