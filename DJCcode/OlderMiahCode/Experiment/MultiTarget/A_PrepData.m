%% define constants

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

SIDS = {'fc9643', '38e116'};


BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];

EX_TRODES = {[21 28 30 56], []};

%%

for c = 1:length(SIDS)
    sid = SIDS{c};
    
    % determine the name of the output directory
    ofile = fullfile(META_DIR, [sid '.mat']);

    % get the files to process
    [odir, hemi, bads, prefix, files] = dataFiles(sid);
    
    % process each file, extracting the powers from the three stages of the
    % phase, normalized by rest
    
    restPowers = [];
    prePowers = [];
    fbPowers = [];
    postPowers = [];
    targets = [];
    results = [];
    ntargets = [];
    filenums = [];
    blockPowers = [];
    blockTargets = [];
    blockntargets = [];
    ztime = {};
    
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

        % pre-process
        sig = double(sig);
        sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
        sig = notch(sig, [120 180], fs, 4);
        
        % figure out when the various epoch types begin and end        
        [restStarts, restEnds] = getEpochs(sta.TargetCode == 0, 1, false);
        [preStarts, preEnds] = getEpochs(sta.TargetCode ~= 0 & sta.Feedback == 0 & sta.ResultCode == 0, 1, false);
        [fbStarts, fbEnds] = getEpochs(sta.Feedback == 1, 1, false);
        
        [postStarts, postEnds] = getEpochs(sta.ResultCode ~= 0, 1, false);

        keepers = ones(1, length(postStarts)) == 1;
        
        restStarts = restStarts(keepers);
        restEnds = restEnds(keepers);
        preStarts = preStarts(keepers);
        preEnds = preEnds(keepers);
        fbStarts = fbStarts(keepers);
        fbEnds = fbEnds(keepers);
        
        % temp hack
        preStarts = preEnds - fs;
        fbStarts = fbEnds - fs;
        
        restPowersForFile = [];
        prePowersForFile = [];
        fbPowersForFile = [];
        postPowersForFile = [];
        timeseriesForFile = {};
  
        for freqIdx = 5%1:size(BANDS, 1)
            bandPower = log(hilbAmp(sig, BANDS(freqIdx, :), fs) .^ 2);
            
            restPowersForFile(:, :, freqIdx) = getEpochMeans(bandPower, restStarts, restEnds)';
            prePowersForFile(:, :, freqIdx) = getEpochMeans(bandPower, preStarts, preEnds)';
            fbPowersForFile(:, :, freqIdx) = getEpochMeans(bandPower, fbStarts, fbEnds)';
            postPowersForFile(:, :, freqIdx) = getEpochMeans(bandPower, postStarts, postEnds)';
            
            zbp = zscoreAgainstInterest(bandPower, sta.TargetCode, 0);
            
            for e = 1:length(restStarts)
                timeseriesForFile{e, freqIdx} = zbp(restStarts(e):postEnds(e), EX_TRODES{c});
            end
            
        end; clear freqIdx        
        
        % for HG only, do block by block
        blocksInFb = (fbEnds(1)-fbStarts(1)) / par.SampleBlockSize.NumericValue;
        blockStartAdder = (0:(blocksInFb-1))*par.SampleBlockSize.NumericValue;
        blockStarts = bsxfun(@plus, repmat(fbStarts, blocksInFb, 1), blockStartAdder');
        blockStarts = blockStarts(:);
        blockEnds = blockStarts + par.SampleBlockSize.NumericValue - 1;
        
        % assuming that the last bandpower processed was HG
        blockPowersForFile = getEpochMeans(bandPower, blockStarts, blockEnds)';
        blockTargetsForFile = sta.TargetCode(blockStarts);
        
        restPowers = cat(1, restPowers, restPowersForFile);
        prePowers = cat(1, prePowers, prePowersForFile);
        fbPowers = cat(1, fbPowers, fbPowersForFile);
        postPowers = cat(1, postPowers, postPowersForFile);
        blockPowers = cat(1, blockPowers, blockPowersForFile);        
        blockTargets = cat(1, blockTargets, blockTargetsForFile);
        targets = cat(1, targets, sta.TargetCode(postStarts));
        results = cat(1, results, sta.ResultCode(postStarts));
        ntargets = cat(1, ntargets, par.NumberTargets.NumericValue*ones(length(postStarts), 1));
        blockntargets = cat(1, blockntargets, par.NumberTargets.NumericValue*ones(length(blockStarts), 1));
        filenums = cat(1, filenums, ctr*ones(length(postStarts), 1));
       ztime = cat(1, ztime, timeseriesForFile);
        
    end; clear ctr file sig sta par preStarts preEnds fbStarts fbEnds postStarts postEnds *ForFile 
    
    exTrodes = EX_TRODES{c};
     save(ofile, 'restPowers', 'prePowers', 'fbPowers', 'postPowers', 'targets', 'results', 'ntargets', 'filenums', 'fs', 'Montage', 'hemi', 'blockPowers', 'blockTargets', 'blockntargets', 'ztime', 'exTrodes'); 
end

clear zid sid