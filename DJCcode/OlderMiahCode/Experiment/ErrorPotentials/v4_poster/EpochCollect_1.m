%% this script collects BCI data in to relevant epochs and stores a cache file
% the pieces of information saved by this script are
% Montage (this is really only the montage of the final bci run)
% target codes
% result codes
% cursor paths
% sampling rate
% log hilbert HG power
% log hilbert beta power
% log hilbert LF power
% task timing information

fprintf('yeah!');
subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';

[ftemp, odir, hemi, bads] = filesForSubjid(subjid);
TouchDir(odir);

%%
tgts = [];
ress = [];
epochs_beta = [];
epochs_hg = [];
epochs_lf = [];
paths = [];
src_files = {};


for mfile = ftemp

    fprintf('working on file %s\n', mfile{:});

    
    % load the file and corresponding montage file
    [sig, sta, par] = load_bcidat(mfile{:});
    load(strrep(mfile{:}, '.dat', '_montage.mat'));
    
    % if necessary, clean up the path information
    savingCursorInfo = isfield(sta, 'CursorPosX') && isfield(sta, 'CursorPosY');
    
    if (savingCursorInfo == 1)
        sta.CursorPosX(sta.CursorPosX > 2^15) = sta.CursorPosX(sta.CursorPosX > 2^15) - 2^16;
    end

    if (savingCursorInfo == 1)
        sta.CursorPosY(sta.CursorPosY > 2^15) = sta.CursorPosY(sta.CursorPosY > 2^15) - 2^16;
    end
    
    % collect a few interesting items from the parameter list
    fs = par.SamplingRate.NumericValue;
    itiDur = par.ITIDuration.NumericValue;
    preDur = par.PreFeedbackDuration.NumericValue;
    fbDur = par.FeedbackDuration.NumericValue;
    postDur = par.PostFeedbackDuration.NumericValue;

    % common average re-ref
    sig = ReferenceCAR(Montage.Montage, bads, double(sig));

    % downsample to 600 hz / 500 Hz to keep stats reasonable
    if (fs == 2400)
        for c = 1:size(sig,2)
            sig2(:,c) = decimate(sig(:,c), 4);
        end
        
        sig = sig2; clear sig2;
        
        sta.TargetCode = sta.TargetCode(1:4:end);
        sta.ResultCode = sta.ResultCode(1:4:end);
        sta.Feedback   = sta.Feedback(1:4:end);
        
        if (savingCursorInfo == 1)
            sta.CursorPosX = sta.CursorPosX(1:4:end);
            sta.CursorPosY = sta.CursorPosY(1:4:end);
        end
        
        fs = 600;
    elseif (fs == 1200)
        for c = 1:size(sig,2)
            sig2(:,c) = decimate(sig(:,c), 2);
        end
        
        sig = sig2; clear sig2;
        
        sta.TargetCode = sta.TargetCode(1:2:end);
        sta.ResultCode = sta.ResultCode(1:2:end);
        sta.Feedback   = sta.Feedback(1:2:end);

        if (savingCursorInfo == 1)
            sta.CursorPosX = sta.CursorPosX(1:2:end);
            sta.CursorPosY = sta.CursorPosY(1:2:end);
        end
        
        fs = 600;
    elseif (fs == 1000)
        for c = 1:size(sig,2)
            sig2(:,c) = decimate(sig(:,c), 2);
        end
        
        sig = sig2; clear sig2;
        
        sta.TargetCode = sta.TargetCode(1:2:end);
        sta.ResultCode = sta.ResultCode(1:2:end);
        sta.Feedback   = sta.Feedback(1:2:end);
        
        if (savingCursorInfo == 1)
            sta.CursorPosX = sta.CursorPosX(1:2:end);
            sta.CursorPosY = sta.CursorPosY(1:2:end);
        end
        
        fs = 500;        
    else
        error('unknown fs');
    end

    t  = (-itiDur-preDur):1/fs:(fbDur+postDur);
    
    % data processing
    % notch filter
    sig = NotchFilter(sig, [120 180], fs);
    
    % extract frequency bands of interest
    beta = log(hilbAmp(sig, [12 18], fs).^2);
    beta = zscoreAgainstInterest(beta, sta.TargetCode, 0);
    
       % extractAndWhiten(sig, 12:3:18, fs);
    
    hg   = log(hilbAmp(sig, [70 200], fs).^2);
    hg   = zscoreAgainstInterest(hg, sta.TargetCode, 0);
    
       % extractAndWhiten(sig, [70:5:115 125:5:175], fs);
    
    lf   = log(hilbAmp(sig, [1 10], fs).^2);
    lf   = zscoreAgainstInterest(lf, sta.TargetCode, 0);
     
    % find epoch start points and end points
    rends = find(diff(double(sta.TargetCode)) > 0);
    rstarts = rends - itiDur*fs;
    
    fstarts = rends + preDur*fs;
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
        mepochs_hg = zeros(size(sig,2), length(rstarts), mode(pends-rstarts+1));
        mepochs_beta = zeros(size(sig,2), length(rstarts), mode(pends-rstarts+1));
        mepochs_lf = zeros(size(sig,2), length(rstarts), mode(pends-rstarts+1));
        
        if (savingCursorInfo == 1)
            mpaths = zeros(2, length(rstarts), mode(pends-rstarts+1));
        end
        
        for e_ctr = 1:length(rstarts)
            e = rstarts(e_ctr):pends(e_ctr);        
            mepochs_hg(:, e_ctr, :) = hg(e,:)'; 
            mepochs_beta(:, e_ctr, :) = beta(e,:)';
            mepochs_lf(:, e_ctr, :) = lf(e,:)';
            
            if (savingCursorInfo == 1)
                temp = [sta.CursorPosX sta.CursorPosY];
                mpaths(:, e_ctr, :) = temp(e, :)';
            end
            
            src_files = [src_files mfile];
        end

        tgts = cat(1, tgts, sta.TargetCode(fstarts));
        ress = cat(1, ress, sta.ResultCode(fends));
        epochs_beta = cat(2, epochs_beta, mepochs_beta);
        epochs_hg = cat(2, epochs_hg, mepochs_hg);
        epochs_lf = cat(2, epochs_lf, mepochs_lf);
        
        if (savingCursorInfo == 1)
            paths = cat(2, paths, mpaths);
        end
    end
end

if (savingCursorInfo == 1)
    miny = 0;
    minx = 0;

    maxy = par.WindowHeight.NumericValue;
    maxx = min(par.WindowWidth.NumericValue, max(max(paths(1,:,:))));

    % correct paths for screen resolution
    for c = 1:size(paths,2)
        paths(1,c,:) = constrain(paths(1,c,:), minx, maxx);
        paths(1,c,:) = map(paths(1,c,:), minx, maxx, 0, 1);

        paths(2,c,:) = constrain(paths(2,c,:), miny, maxy);
        paths(2,c,:) = map(paths(2,c,:), miny, maxy, 1, 0);
    end
end

% clear unsaved variables
clear bi c e e_ctr fends files* fstarts ftemp mepochs mfile par pends rends rstarts sig sta mepochs_beta mepochs_hg
clear beta hg lf maxx maxy mepochs_lf minx miny mpaths savingCursorInfo temp

% save the rest
save(fullfile(odir, [subjid '_epochs']));

