function threshold = extractThreshold(all)
    nchans = size(all,1);
    nobs = size(all,2);
    
    chans = [];
    for c = 1:nchans
        chans = cat(1, chans, c*ones(nobs,1));
    end
    
    if (anova1(all(:), chans, 'off') <= 0.05)
        warning('statistically different across channels');
    end
        
    all = all(:);
    sall = sort(all);

    threshold = sall(round(0.95*length(sall)));
end