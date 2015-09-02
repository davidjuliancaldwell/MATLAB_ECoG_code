function [result, ntrials] = determinePerformance(sta)
    [~,ends] = getEpochs(double(sta.Feedback), 1);
   
    if (max(ends) >= length(sta.Feedback))
        ends(end) = [];
    end
    
    result = mean(sta.TargetCode(ends+1) == sta.ResultCode(ends+1));
    ntrials = length(ends);
end