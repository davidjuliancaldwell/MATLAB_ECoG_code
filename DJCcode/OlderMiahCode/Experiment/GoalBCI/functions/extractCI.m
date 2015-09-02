function [lb, ub] = extractCI(X, p)
    % assume two sided
    
    df = length(X)-1;
    
    t_cl = tinv(p, df);
    
    mu = mean(X);
    sig = std(X);
    
    lb = mu - t_cl*sig;
    ub = mu + t_cl*sig;
end