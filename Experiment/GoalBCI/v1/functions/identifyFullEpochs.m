function [rs, re, ts, te, hs, he, fs, fe] = identifyFullEpochs(sta, par)
    fsamp = par.SamplingRate.NumericValue;
    
    itiDur = par.ITIDuration.NumericValue;
    preDur = par.PreFeedbackDuration.NumericValue;
    fbDur = par.FeedbackDuration.NumericValue;
    postDur = par.PostFeedbackDuration.NumericValue;
    
    % identify the feedback starts
    [tempFeedbackStarts, tempFeedbackEnds] = getEpochs(sta.Feedback, 1, 0);
    
    % that should make the corresponding trial starts
    tempTrialStarts = tempFeedbackStarts - (preDur + itiDur) * fsamp;
    tempTrialEnds = tempFeedbackEnds + itiDur * fsamp - 1;
    
    % eliminate the trials that can't exist given the length of the data
    bads = tempTrialStarts <= 0 | tempTrialEnds > length(sta.Feedback);
    tempTrialStarts(bads) = [];
    tempTrialEnds(bads) = [];
        
    % now parse out the time windows
    rs = tempTrialStarts;
    re = rs + itiDur * fsamp - 1;
    ts = re + 1;
    te = ts + fsamp - 1;
    hs = te + 1;
    he = ts + preDur * fsamp - 1;
    fs = he + 1;
    fe = tempTrialEnds - postDur * fsamp;    
    
%     % dbg
%     figure;
%     plot(sta.TargetCode);
%     hold on;
%     plot(ts, sta.TargetCode(ts), 'r.');
%     plot(te, sta.TargetCode(te), 'ro');
%     plot(fs, sta.TargetCode(fs), 'g.');
%     plot(fe, sta.TargetCode(fe), 'go');
%     x = 5;
end