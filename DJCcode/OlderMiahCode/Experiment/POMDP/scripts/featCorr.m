function [corrs, signs, thresh] = featCorr(X, y, N, p)
% function [corrs, sigThresh] = featCorr(X, y, N)
%   simultaneously calculates correlations between all features (X) and
%   labels (y)
%
%   X is FxCxO
%   y is O
%   N is number of random permutations of y to use in threshold calc
%   p is the significance threshold (Defaults to 0.05)

    if (~exist('N', 'var'))
        N = 1000;
    end

    if (~exist('p', 'var'))
        p = 0.05;
    end
    
    rX = reshape(X, [size(X, 1)*size(X, 2) size(X, 3)])';
    rCorrs = corr(rX, y);
    corrs = reshape(rCorrs, [size(X, 1) size(X, 2)]);
    
    signs = sign(corrs);
    corrs = corrs.^2;
    
    randMax = zeros(N, 1);
    
    for c = 1:N
        randy = y(randperm(length(y)));
        
        randr = corr(rX, randy).^2;
        
        randMax(c) = max(max(randr));
    end
    
    thresh = prctile(randMax, (1-p)*100);    
end