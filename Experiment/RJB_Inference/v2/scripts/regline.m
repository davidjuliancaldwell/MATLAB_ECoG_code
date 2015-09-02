function legStr = regline(x,y)
    lsline;
    
    [r, p] = corr(x, y);
    
    if (p < 0.001)
	    legStr = sprintf('LS regression (r^2=%0.3f, p<0.001)', r^2);
    else
        legStr = sprintf('LS regression (r^2=%0.3f, p=%0.3f)', r^2, p);        
    end
    
end