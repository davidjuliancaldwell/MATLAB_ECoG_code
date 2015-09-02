function chi2 = chiTable(t)
    % t is a 2x2 table
    % returns the chi squared value
    
    n = (t(1,1)*t(2,2) - t(2,1)*t(1,2))^2 * sum(sum(t));
    d = prod(sum(t,1))*prod(sum(t,2));
    
    chi2 = n/d;
end