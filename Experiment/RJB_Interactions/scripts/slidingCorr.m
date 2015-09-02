function rs = slidingCorr(x, y, L, stepsize)
    starts = 1:stepsize:(length(x)-L);
    ends = starts + L;
    
    rs = zeros(size(starts));
    
    for step = 1:length(starts)
        t = starts(step):ends(step);
        rs(step) = corr(x(t)', y(t)');
    end
end