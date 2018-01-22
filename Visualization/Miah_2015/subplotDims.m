function [x, y] = subplotDims(N)
% guesses the appropriate dimensions for a given number of subplots
    x = ceil(sqrt(N));
    
    ys = 1:x;
    y = ys(find((ys * x) >= N, 1, 'first'));
end