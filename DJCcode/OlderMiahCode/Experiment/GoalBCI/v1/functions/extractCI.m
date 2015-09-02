function [lb, ub] = extractCI(X, p)
    % p = typically .95
    % X is distribution
    if (~exist('p','var'))
        p = 0.95;
    end

    pdiff = 1 - p;
    
    minp = pdiff/2;
    maxp = 1-minp;
    
    sorted = sort(X);
    lidx = floor(length(sorted) * minp);
    uidx = ceil(length(sorted) * maxp);
    lb = sorted(lidx);
    ub = sorted(uidx);
end