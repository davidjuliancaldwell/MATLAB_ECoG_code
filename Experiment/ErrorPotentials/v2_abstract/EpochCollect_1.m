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
src_files = {};


for mfile = ftemp

    fprintf('working file %s\n', mfile{:});

    
    % load the file and corresponding montage file
    [sig, sta, par] = load_bcidat(mfile{:});
    load(strrep(mfile{:}, '.dat', '_montage.mat'));
    
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
        fs = 600;
    elseif (fs == 1200)
        for c = 1:size(sig,2)
            sig2(:,c) = decimate(sig(:,c), 2);
        end
        
        sig = sig2; clear sig2;
        
        sta.TargetCode = sta.TargetCode(1:2:end);
        sta.ResultCode = sta.ResultCode(1:2:end);
        sta.Feedback   = sta.Feedback(1:2:end);
        fs = 600;
    elseif (fs == 1000)
        for c = 1:size(sig,2)
            sig2(:,c) = decimate(sig(:,c), 2);
        end
        
        sig = sig2; clear sig2;
        
        sta.TargetCode = sta.TargetCode(1:2:end);
        sta.ResultCode = sta.ResultCode(1:2:end);
        sta.Feedback   = sta.Feedback(1:2:end);
        fs = 500;        
    else
        error('unknown fs');
    end

    t  = (-itiDur-preDur):1/fs:(fbDur+postDur);
    
    % data processing
    % notch filter
    sig = NotchFilter(sig, [120 180], fs);
    
    % extract frequency bands of interest
    beta = hilbAmp(sig, [12 18], fs);
       % extractAndWhiten(sig, 12:3:18, fs);
    
    hg   = hilbAmp(sig, [70 200], fs);
       % extractAndWhiten(sig, [70:5:115 125:5:175], fs);
    
    % adjust distributions so data are normal
    nbeta = zeros(size(beta));
    for c = 1:size(sig, 2)
        nbeta(:, c) = convert2normal(beta(:, c));
    end
    
    nhg = zeros(size(hg));
    for c = 1:size(sig, 2)
        nhg(:, c) = convert2normal(hg(:, c));
    end
    
   
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

        for e_ctr = 1:length(rstarts)
            e = rstarts(e_ctr):pends(e_ctr);        
            mepochs_hg(:, e_ctr, :) = nhg(e,:)'; 
            mepochs_beta(:, e_ctr, :) = nbeta(e,:)';
            src_files = [src_files mfile];
        end

        tgts = cat(1, tgts, sta.TargetCode(fstarts));
        ress = cat(1, ress, sta.ResultCode(fends));
        epochs_beta = cat(2, epochs_beta, mepochs_beta);
        epochs_hg = cat(2, epochs_hg, mepochs_hg);
    end
end

% clear unsaved variables
clear bi c e e_ctr fends files* fstarts ftemp mepochs mfile par pends rends rstarts sig sta mepochs_beta mepochs_hg

% save the rest
save(fullfile(odir, [subjid '_epochs']));

