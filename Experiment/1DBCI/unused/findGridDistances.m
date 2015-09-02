function distances = findGridDistances(ctl, trodes, m, n)
    if (~exist('m', 'var'))
        m = 8;
    end
    if (~exist('n', 'var'))
        n = 8;
    end
    
    grid = reshape(1:(m*n), m, n);
    
    
    distances = zeros(size(trodes));
    
    for c = 1:length(trodes)
        distances(c) = findGridDistance(ctl, trodes(c), grid);
    end
end

function distance = findGridDistance(ctl, tgt, grid)
    [ctl_r, ctl_c] = find(grid == ctl);
    [tgt_r, tgt_c] = find(grid == tgt);
    
    distance = sqrt((ctl_r-tgt_r)^2+(ctl_c-tgt_c)^2);
end