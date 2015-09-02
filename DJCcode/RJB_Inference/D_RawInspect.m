%% this script collects BCI data in to relevant epochs and stores a cache file
% the pieces of information saved by this script are
% target codes
% result codes
% sampling rate
% log hilbert HG power
% task timing information

Z_Constants;

%% 

fprintf('please note. this script is for manual identification of bad trials and bad channels.  It must be run on a subject-by-subject basis and matrices saved out manually.');

for sIdx = 1%1:length(SIDS)    
    sid = SIDS{sIdx};
    [ftemp, hemi, bads, montage, cchan] = filesForSubjid(sid);

    epochs = [];
    
    ctr = 0;
    for mfile = ftemp
        ctr = ctr + 1;
        
        fprintf('working on file %s\n', mfile{:});

        % load the data fille
        [sig, sta, par] = load_bcidat(mfile{:});
       
        % collect a few interesting items from the parameter list
        fs = par.SamplingRate.NumericValue;
        
        if (fs == 2400)
            sig = sig(1:2:end,:);
            fs = fs/2;
            sta.TargetCode = sta.TargetCode(1:2:end);
        end
        
        itiDur = par.ITIDuration.NumericValue;
        preDur = par.PreFeedbackDuration.NumericValue;
        fbDur = par.FeedbackDuration.NumericValue;
        postDur = par.PostFeedbackDuration.NumericValue;
        
        t = (-itiDur-preDur):1/fs:((fbDur+postDur)-1/fs);

        % data processing
        % notch filter
        sig = NotchFilter(double(sig), [60 120 180], fs);
        
        % find epoch start points and end points
        rends = find(diff(double(sta.TargetCode)) > 0);
        rstarts = rends - itiDur*fs + 1;

        fstarts = rends + preDur*fs + 1;
        fends = rends + (preDur+fbDur)*fs;

        pends = fends + postDur*fs;

        % drop bad indices (bad epochs)
        bi = rstarts < 0 | pends > length(sta.TargetCode);
        rends(bi) = [];
        rstarts(bi) = [];
        fends(bi) = [];
        fstarts(bi) = [];
        pends(bi) = [];
                
        % collect data from epochs
        if (~isempty(rstarts))
            mepochs = getEpochSignal(sig, rstarts, rstarts+length(t));
            epochs = cat(3, epochs, mepochs);            
        end
    end
    
    fprintf('previously determined bad channels for %s: ', sid);
    fprintf(' %d', bads);
    fprintf('\n');
    fprintf('remember to save the bad channels & epochs file for this subject.');
    
    channel_inspector(epochs, t, fs);
    return
end