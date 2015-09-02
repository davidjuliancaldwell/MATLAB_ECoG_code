%% this script collects BCI data in to relevant epochs and stores a cache file
% the pieces of information saved by this script are
% target codes
% result codes
% sampling rate
% log hilbert HG power
% task timing information

Z_Constants;

%% 

for zid = SIDS
    sid = zid{:};
    [ftemp, hemi, bads, montage, cchan] = filesForSubjid(sid);

    %%
    tgts = [];
    ress = [];
    epochs = [];
    src_files = [];
    endpoints = [];

    ctr = 0;
    for mfile = ftemp
        ctr = ctr + 1;
        
        fprintf('working on file %s\n', mfile{:});

        % load the data fille
        [sig, sta, par] = load_bcidat(mfile{:});
       
        % collect a few interesting items from the parameter list
        fs = par.SamplingRate.NumericValue;
        itiDur = par.ITIDuration.NumericValue;
        preDur = par.PreFeedbackDuration.NumericValue;
        fbDur = par.FeedbackDuration.NumericValue;
        postDur = par.PostFeedbackDuration.NumericValue;

        recpaths = false;
        if (hasPaths(sta))
            recpaths = true;
            sta.CursorPosX = double(sta.CursorPosX);
            sta.CursorPosY = double(sta.CursorPosY);
        end
        
        % downsample to 600 hz / 500 Hz to keep stats reasonable
        if (fs == 2400)
            % common average re-ref
            sig = ReferenceCAR(GugerizeMontage(montage.Montage), bads, double(sig));
            
            for c = 1:size(sig,2)
                sig2(:,c) = resample(sig(:,c), 1, 4);
            end

            sig = sig2; clear sig2;

            sta.TargetCode = sta.TargetCode(1:4:end);
            sta.ResultCode = sta.ResultCode(1:4:end);
            sta.Feedback   = sta.Feedback(1:4:end);

            if (recpaths)
                sta.CursorPosX = sta.CursorPosX(1:4:end);
                sta.CursorPosY = sta.CursorPosY(1:4:end);
            end
            
            fs = 600;
        elseif (fs == 1200)
            % common average re-ref
            sig = ReferenceCAR(GugerizeMontage(montage.Montage), bads, double(sig));
            
            for c = 1:size(sig,2)
                sig2(:,c) = resample(sig(:,c), 1, 2);
            end

            sig = sig2; clear sig2;

            sta.TargetCode = sta.TargetCode(1:2:end);
            sta.ResultCode = sta.ResultCode(1:2:end);
            sta.Feedback   = sta.Feedback(1:2:end);

            if (recpaths)
                sta.CursorPosX = sta.CursorPosX(1:2:end);
                sta.CursorPosY = sta.CursorPosY(1:2:end);
            end
            
            
            fs = 600;
        elseif (fs == 1000)
            % common average re-ref
            sig = ReferenceCAR(montage.Montage, bads, double(sig));
            
            for c = 1:size(sig,2)
                sig2(:,c) = resample(sig(:,c), 1, 2);
            end

            sig = sig2; clear sig2;

            sta.TargetCode = sta.TargetCode(1:2:end);
            sta.ResultCode = sta.ResultCode(1:2:end);
            sta.Feedback   = sta.Feedback(1:2:end);

            if (recpaths)
                sta.CursorPosX = sta.CursorPosX(1:2:end);
                sta.CursorPosY = sta.CursorPosY(1:2:end);
            end
                        
            fs = 500;        
        else
            error('unknown fs');
        end

        if (recpaths)
            sta.CursorPosY(sta.CursorPosY > 2^15) = sta.CursorPosY(sta.CursorPosY > 2^15) - 2^16;
            sta.CursorPosY = constrain(sta.CursorPosY, 0, par.WindowHeight.NumericValue) / par.WindowHeight.NumericValue;
        end

        t = (-itiDur-preDur):1/fs:((fbDur+postDur)-1/fs);

        % data processing
        % notch filter
        sig = NotchFilter(sig, [60 120 180], fs);
        
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
        DSFAC = fs/fsFinal;        
        t = downsample(t, DSFAC);
                
        % collect data from epochs
        if (~isempty(rstarts))
            % epochs
            % epochs is epochs x frequencies x channels x time
            mepochs = zeros(size(BANDS, 1), length(rstarts), size(sig, 2), length(t));

            for bandi = 1:size(BANDS, 1)
                if (BAND_TYPE(bandi) == 1)
                    bp = hilbAmp(sig, BANDS(bandi, :), fs);
                else
                    bp = sig;
                end
                
                % bp = zscoreAgainstInterest(bp, sta.TargetCode, 0);

                rbp = resample(bp, fsFinal, fs);

                rss = round(rstarts*fsFinal/fs);
                mepochs(bandi, :, :, :) = permute(...
                    getEpochSignal(rbp, rss, rss+length(t)), ...
                    [3 2 1]);
            end
            
            src_files = cat(1, src_files, ctr*ones(size(fstarts)));            
            tgts = cat(1, tgts, sta.TargetCode(fstarts));
            ress = cat(1, ress, sta.ResultCode(fends));
            epochs = cat(2, epochs, mepochs);
            
            if (recpaths)
                if (~exist('endpoints', 'var'))
                    endpoints = [];
                end
                endpoints = cat(2, endpoints, sta.CursorPosY(fends)');
            end                            
        end
        
        fs = fsFinal;
    end

    % clear unsaved variables
    clear bi c e e_ctr fends files* fstarts ftemp mepochs mfile par pends rends rstarts sig sta mepochs_beta mepochs_hg
    clear beta hg lf maxx maxy mepochs_lf minx miny mpaths savingCursorInfo temp

    % save the rest
    save(fullfile(META_DIR, [sid '_epochs']), 'montage', 'bads', 'epochs*', '*Dur', 'fs', 'hemi', 'ress', 'src_files', 't', 'tgts', 'cchan', 'endpoints');
end