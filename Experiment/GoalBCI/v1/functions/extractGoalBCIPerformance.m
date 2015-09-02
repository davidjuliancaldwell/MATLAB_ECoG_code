function [targets, results, timeToTarget, integratedSquaredError] = extractGoalBCIPerformance(filepath)
    [~, sta, par] = load_bcidat(filepath);
    fsamp = par.SamplingRate.NumericValue;
    
    [rs, re, ts, te, hs, he, fs, fe] = identifyFullEpochs(sta, par);
        
    targets = double(sta.TargetCode(fs));
    results = double(sta.ResultCode(fe+1));
    
    timeToTarget = ((fe-1-fs)/fsamp)';
    timeToTarget(results == 0) = NaN;
    
    integratedSquaredError = zeros(size(targets));
    
    for e = 1:length(fs)
        normpath = map(double(sta.CursorPosY(fs(e):fe(e))), 0, 4096, 0, 1);
        targy = double(par.Targets.NumericValue(targets(e), 2)) / 100;
        targd = par.Targets.NumericValue(targets(e), 5) / 100;
        
        integratedSquaredError(e) = calculateISE(normpath(41:end), targy, targd, fsamp);
    end
    
    catches = targets==9;
    
    targets(catches) = [];
    results(catches) = [];
    timeToTarget(catches) = [];
    integratedSquaredError(catches) = [];
    
end