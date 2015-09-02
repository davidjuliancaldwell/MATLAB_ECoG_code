%% this script collects BCI data in to relevant epochs and stores a cache file
% the pieces of information saved by this script are
% target codes
% result codes
% decomposed signal
% task timing information

Z_Constants;

%% 
for sIdx = 1:length(SIDS)    
    sid = SIDS{sIdx};
    [ftemp, hemi, ~, montage, cchan] = filesForSubjid(sid);

    % load the bad channels / epochs file
    load(fullfile(META_DIR, [sid '_bad_trials.mat']));
    
    %
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

        % downsample to 600 / 500 Hz
        if (fs == 2400)
            % common average re-ref
            sig = double(sig);
            
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
            
            fs = 1200;
        elseif (fs == 1200)
%             % common average re-ref
%             sig = double(sig);
%             
%             for c = 1:size(sig,2)
%                 sig2(:,c) = resample(sig(:,c), 1, 2);
%             end
% 
%             sig = sig2; clear sig2;
% 
%             sta.TargetCode = sta.TargetCode(1:2:end);
%             sta.ResultCode = sta.ResultCode(1:2:end);
%             sta.Feedback   = sta.Feedback(1:2:end);
% 
%             if (recpaths)
%                 sta.CursorPosX = sta.CursorPosX(1:2:end);
%                 sta.CursorPosY = sta.CursorPosY(1:2:end);
%             end
%             
%             fs = 600;            
        elseif (fs == 1000)
%             % common average re-ref
%             sig = double(sig);
%             
%             for c = 1:size(sig,2)
%                 sig2(:,c) = resample(sig(:,c), 1, 2);
%             end
% 
%             sig = sig2; clear sig2;
% 
%             sta.TargetCode = sta.TargetCode(1:2:end);
%             sta.ResultCode = sta.ResultCode(1:2:end);
%             sta.Feedback   = sta.Feedback(1:2:end);
% 
%             if (recpaths)
%                 sta.CursorPosX = sta.CursorPosX(1:2:end);
%                 sta.CursorPosY = sta.CursorPosY(1:2:end);
%             end
%             
%             fs = 500;            
        else
            error('unknown fs');
        end

        if (recpaths)
            sta.CursorPosY(sta.CursorPosY > 2^15) = sta.CursorPosY(sta.CursorPosY > 2^15) - 2^16;
            sta.CursorPosY = constrain(sta.CursorPosY, 0, par.WindowHeight.NumericValue) / par.WindowHeight.NumericValue;
        end

        t = (-itiDur-preDur):1/fs:((fbDur+postDur)-1/fs);

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
            mepochs = permute(...
                getEpochSignal(sig, rstarts, rstarts+length(t)), ...
                [3 2 1]);
                
            src_files = cat(1, src_files, ctr*ones(size(fstarts)));            
            tgts = cat(1, tgts, sta.TargetCode(fstarts));
            ress = cat(1, ress, sta.ResultCode(fends));
            epochs = cat(1, epochs, mepochs);
            
            if (recpaths)
                if (~exist('endpoints', 'var'))
                    endpoints = [];
                end
                endpoints = cat(2, endpoints, sta.CursorPosY(fends)');
            end                            
        end
    end

    % clear unsaved variables
    clear bi c e e_ctr fends files* fstarts ftemp mepochs mfile par pends rends rstarts sig sta mepochs_beta mepochs_hg
    clear beta hg lf maxx maxy mepochs_lf minx miny mpaths savingCursorInfo temp

    % save the rest
    save(fullfile(META_DIR, [sid '_epochs_raw']), 'montage', 'bad_channels', 'bad_marker', 'epochs*', '*Dur', 'fs', 'hemi', 'ress', 'src_files', 't', 'tgts', 'cchan', 'endpoints');
end