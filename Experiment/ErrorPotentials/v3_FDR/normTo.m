function nX = normTo(x, minimum, maximum)
    % normalizes x to be on the range [minimum, maximum]
    
    xmax = max(x);
    xmin = min(x);
    
    xprime = (x - xmin)/(xmax-xmin);
    nX = xprime * (maximum-minimum) + minimum;
end