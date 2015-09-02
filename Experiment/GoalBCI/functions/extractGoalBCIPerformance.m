function [targets, results, timeToTarget, integratedSquaredError, endingSide] = extractGoalBCIPerformance(varargin)
    if (nargin == 1) 
        [~, sta, par] = load_bcidat(varargin{1});
    
    elseif (nargin == 2)
        sta = varargin{1};
        par = varargin{2};
    end
            
    fsamp = par.SamplingRate.NumericValue;
    
    [rs, re, ts, te, hs, he, fs, fe] = identifyFullEpochs(sta, par);
        
    targets = double(sta.TargetCode(fs));
    results = double(sta.ResultCode(fe+2));
    
    timeToTarget = ((fe-1-fs)/fsamp)';
    timeToTarget(results == 0) = NaN;
    
    integratedSquaredError = zeros(size(targets));
    endingSide = zeros(size(targets));
    
    for e = 1:length(fs)
        normpath = map(double(sta.CursorPosY(fs(e):fe(e))), 0, 4096, 0, 1);
        targy = double(par.Targets.NumericValue(targets(e), 2)) / 100;
        targd = par.Targets.NumericValue(targets(e), 5) / 100;
        
        integratedSquaredError(e) = calculateISE(normpath(41:end), targy, targd, fsamp);
        
        if (targy > 0.5)
            endingSide(e) = normpath(end) > 0.5;
        else
            endingSide(e) = normpath(end) <= 0.5;
        end        
    end
    
    catches = targets==9;
    
    targets(catches) = [];
    results(catches) = [];
    timeToTarget(catches) = [];
    integratedSquaredError(catches) = [];
    endingSide(catches) = [];
end