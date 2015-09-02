function po = binotest2(x, n, p)
    % x is number observed
    % n is trials
    % p is p(observing one in a trial)
    
    % expectation
%     e = n * p;
%     
%     if (x > e)
        pl = binocdf(x, n, p);
        ph = binocdf(n-x, n, p);
        
        po = min(1, min(pl, ph) * 2);
        
%     elseif(x < e)
%         po = binocdf(n-x, n, p) * 2;
%     else
%         po = 1;
%     end
end