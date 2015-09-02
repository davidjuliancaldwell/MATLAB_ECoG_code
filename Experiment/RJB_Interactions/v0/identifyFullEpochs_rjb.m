function [rs, re, ts, te, fs, fe, ps, pe] = identifyFullEpochs_rjb(sta, par)
    fsamp = par.SamplingRate.NumericValue;
    
    itiDur = par.ITIDuration.NumericValue;
    preDur = par.PreFeedbackDuration.NumericValue;
%     fbDur = par.FeedbackDuration.NumericValue;
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
    te = ts + preDur * fsamp - 1;
    fs = te + 1;
    fe = tempTrialEnds - postDur * fsamp;    
    ps = fe + 1;
    pe = ps + postDur * fsamp - 1;
    
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