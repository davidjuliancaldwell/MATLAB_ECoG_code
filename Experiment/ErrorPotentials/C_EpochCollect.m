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

Z_Constants;

%% 

for zid = SIDS
    sid = zid{:};
    [ftemp, hemi, bads] = filesForSubjid(sid);

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
        else
            warning(sprintf('not saving cursor info for %s file %s\n', sid, mfile{:}));
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

        % downsample to 600 hz / 500 Hz to keep stats reasonable
        if (fs == 2400)
            % common average re-ref
            sig = ReferenceCAR(GugerizeMontage(Montage.Montage), bads, double(sig));
            
            for c = 1:size(sig,2)
                sig2(:,c) = resample(sig(:,c), 1, 4);
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
            % common average re-ref
            sig = ReferenceCAR(GugerizeMontage(Montage.Montage), bads, double(sig));
            
            for c = 1:size(sig,2)
                sig2(:,c) = resample(sig(:,c), 1, 2);
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
            % common average re-ref
            sig = ReferenceCAR(Montage.Montage, bads, double(sig));
            
            for c = 1:size(sig,2)
                sig2(:,c) = resample(sig(:,c), 1, 2);
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

        t = (-itiDur-preDur):1/fs:((fbDur+postDur)-1/fs);

        % data processing
        % notch filter
        sig = NotchFilter(sig, [60 120 180], fs);

        % extract frequency bands of interest
        beta = log(hilbAmp(sig, [12 18], fs).^2);
        beta = zscoreAgainstInterest(beta, sta.TargetCode, 0);

           % extractAndWhiten(sig, 12:3:18, fs);

        hg   = log(hilbAmp(sig, [70 200], fs).^2);
        hg   = zscoreAgainstInterest(hg, sta.TargetCode, 0);

           % extractAndWhiten(sig, [70:5:115 125:5:175], fs);

        lf   = log(hilbAmp(sig, [1 10], fs).^2);
        lf   = zscoreAgainstInterest(lf, sta.TargetCode, 0);

%         figure, plot(sta.TargetCode);
        
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

        % resample again for computational tractability
        fsFinal = 100;
        
%         t = resample(t, fsFinal, fs);
       
        DSFAC = fs/fsFinal;
        
%         DSFAC = 5;
%         fs = fs / DSFAC;
        
        t = downsample(t, DSFAC);
        
        % collect data from epochs
        if (~isempty(rstarts))
            samples = mode(pends-rstarts+1) / DSFAC;
            
            mepochs_hg = zeros(size(sig,2), length(rstarts), samples);
            mepochs_beta = zeros(size(sig,2), length(rstarts), samples);
            mepochs_lf = zeros(size(sig,2), length(rstarts), samples);

            if (savingCursorInfo == 1)
                mpaths = zeros(2, length(rstarts), samples);
            end

            for e_ctr = 1:length(rstarts)
                e = rstarts(e_ctr):pends(e_ctr);        
                mepochs_hg(:, e_ctr, :) = resample(hg(e,:), fsFinal, fs)'; 
                mepochs_beta(:, e_ctr, :) = resample(beta(e,:), fsFinal, fs)';
                mepochs_lf(:, e_ctr, :) = resample(lf(e,:), fsFinal, fs)';

                if (savingCursorInfo == 1)
                    temp = double([sta.CursorPosX sta.CursorPosY]);
                    mpaths(:, e_ctr, :) = downsample(temp(e, :), DSFAC)';
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
        
        fs = fsFinal;
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
    save(fullfile(META_DIR, [sid '_epochs']), 'Montage', 'bads', 'epochs_beta', 'epochs_hg', 'epochs_lf', 'fbDur', 'fs', 'hemi', 'itiDur', 'paths', 'postDur', 'preDur', 'ress', 'src_files', 't', 'tgts');
end