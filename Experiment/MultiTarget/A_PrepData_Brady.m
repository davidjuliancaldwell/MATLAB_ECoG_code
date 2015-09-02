%% define constants

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'meta', 'brady');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

SIDS = {'fc9643', '38e116'};


BANDS = [1 4; 4 7; 8 12; 15 31; 70 150];

%%

for c = 1%1:length(SIDS)
    sid = SIDS{c};
    
    % determine the name of the output directory
    ofile = fullfile(META_DIR, [sid '.mat']);

    % get the files to process
    [odir, hemi, bads, prefix, files] = dataFiles(sid);
    
    targets = [];
    results = [];
    ntargets = [];
    filenums = [];
    ztime = [];
    paths = [];
    
    ctr = 0;
    
    for file = files
        ctr = ctr + 1;
        fprintf('processing %d of %d\n', ctr, length(files));
        
        filename = file{:};
        
        % load the data
        [sig, sta, par] = load_bcidat(filename);
        fs = par.SamplingRate.NumericValue;
        Montage = loadCorrespondingMontage(filename);
        Montage.BadChannels = bads;
                
        % check to see if the data file has cursor paths
        if (hasPaths(sta))
            sta.CursorPosX = double(sta.CursorPosX);
            sta.CursorPosY = double(sta.CursorPosY);
        else
            error('no paths for file %s', filename);
        end        
        
        % pre-process
        sig = double(sig);

        if (isint(fs/1000))
            fsFinal = 1000;
        else
            fsFinal = 1200;
        end
        dsFac = fs/fsFinal;
        sig = resample(sig, fsFinal, fs);
        
        sta.TargetCode = sta.TargetCode(1:dsFac:end);
        sta.ResultCode = sta.ResultCode(1:dsFac:end);
        sta.Feedback = sta.Feedback(1:dsFac:end);
        sta.CursorPosX = sta.CursorPosX(1:dsFac:end);
        sta.CursorPosY = sta.CursorPosY(1:dsFac:end);
        fs = fsFinal;
        
        % figure out when the various epoch types begin and end        
        [restStarts, restEnds] = getEpochs(sta.TargetCode == 0, 1, false);
        [preStarts, preEnds] = getEpochs(sta.TargetCode ~= 0 & sta.Feedback == 0 & sta.ResultCode == 0, 1, false);
        [fbStarts, fbEnds] = getEpochs(sta.Feedback == 1, 1, false);        
        [postStarts, postEnds] = getEpochs(sta.ResultCode ~= 0, 1, false);
        
        % prune a few of these
        keepers = ones(1, length(postStarts)) == 1;        
        restStarts = restStarts(keepers);
        restEnds = restEnds(keepers);
        preStarts = preStarts(keepers);
        preEnds = preEnds(keepers);
        fbStarts = fbStarts(keepers);
        fbEnds = fbEnds(keepers);
        
        % now figure out some trial basics and build the t vector
        itiDur = mode(restEnds-restStarts+1)/fs;
        preDur = mode(preEnds-preStarts+1)/fs;
        fbDur = mode(fbEnds-fbStarts+1)/fs;
        postDur = mode(postEnds-postStarts+1)/fs;
        
        t = (-preDur-itiDur):1/fs:((fbDur+postDur)-2/fs);

        % correct the first epoch, if necessary
        temp = postEnds-restStarts;        
        if (temp(1) > temp(2))
            restStarts(1)=restStarts(1)+temp(1)-temp(2);
        end
        
        % drop any epochs that don't fit the bill
        goodL = mode(postEnds-restStarts) == (postEnds-restStarts);
        if (any(~goodL))
            warning(sprintf('dropping %d epochs that aren''t the right length', sum(~goodL)));
        end
        
        postEnds(~goodL) = [];
        restStarts(~goodL) = [];
        postStarts(~goodL) = [];
        
        % now collect the data
        timeseriesForFile = getEpochSignal(sig, restStarts, postEnds);
        X = 1; Y = 2;
        
        pathsForFile = getEpochSignal([sta.CursorPosX sta.CursorPosY], restStarts, postEnds);
        
        targets = cat(1, targets, sta.TargetCode(postStarts));
        results = cat(1, results, sta.ResultCode(postStarts));
        ntargets = cat(1, ntargets, par.NumberTargets.NumericValue*ones(length(postStarts), 1));
        filenums = cat(1, filenums, ctr*ones(length(postStarts), 1));
        tic
        ztime = cat(3, ztime, timeseriesForFile);        
        toc
        paths = cat(3, paths, pathsForFile);
        
    end; clear ctr file sig sta par preStarts preEnds fbStarts fbEnds postStarts postEnds *ForFile 
    return
    save(ofile, '-v7.3', 'targets', 'results', 'ntargets', 'filenums', 'ztime', 'paths', 't', 'fs', 'Montage', 'hemi', 'X', 'Y', '*Dur'); 
end

clear zid sid