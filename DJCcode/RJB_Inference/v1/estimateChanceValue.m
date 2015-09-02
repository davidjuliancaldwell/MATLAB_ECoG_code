% Z_ClassificationChanceHack

function chance = estimateChanceValue(N, p)
    DBG = 0;
    
    trials = 1000;
    res = zeros(trials, 1);

    for c = 1:trials
        res(c) = random('binom', N, p);
    end

    sres = sort(res);
    
    if (DBG)
        figure;
        hist(res);
        vline(sres(ceil(.95*trials)))
    end
    
    chance = sres(ceil(.95*trials)) / N;
end