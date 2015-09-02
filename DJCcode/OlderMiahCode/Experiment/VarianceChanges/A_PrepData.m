%% define constants

addpath ./scripts;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'VarianceChanges', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'VaranceChanges', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

SIDS = {'fc9643', '38e116'};
cchans = [24 33];

% BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];
BANDS = [70 200];

%%

for c = 2%1:length(SIDS)
    sid = SIDS{c};
    
    % determine the name of the output directory
    ofile = fullfile(META_DIR, [sid '.mat']);

    % get the files to process
    [odir, hemi, bads, prefix, files] = dataFiles(sid);

    
    % process each file, extracting the powers from the three stages of the
    % phase, normalized by rest
    
    restVariances = [];
    preVariances = [];
    fbVariances = [];
    postVariances = [];
    targets = [];
    results = [];
    ntargets = [];
    filenums = [];
    blockVariances = [];
    blockTargets = [];
    blockntargets = [];
    ztime = [];
    
    ctr = 0;
    
    for file = files
        ctr = ctr + 1;
        fprintf('processing %d of %d\n', ctr, length(files));
        
        filename = file{:};
        
        % load the data
        [sig, sta, par] = load_bcidat(filename);
        fs = par.SamplingRate.NumericValue
        Montage = loadCorrespondingMontage(filename);
        Montage.BadChannels = bads;

        % pre-process
        sig = double(sig);
        if c == 2
            sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, sig);
        else
            sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
        end
        sig = notch(sig(:, cchans(c)), [120 180], fs, 4);
        
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
        
        bandPower = log(hilbAmp(sig, [70 200], fs) .^ 2);
%         zbp = zscoreAgainstInterest(bandPower, sta.TargetCode, 0);
                    
        if fs == 2400
            bandPower = downsample(bandPower, 2);
            fbStarts = floor(fbStarts/2);
            fbEnds = floor(fbEnds/2);
        end
        
        targets = cat(1, targets, sta.TargetCode(postStarts));
        results = cat(1, results, sta.ResultCode(postStarts));
        
        ntargets = cat(1, ntargets, par.NumberTargets.NumericValue*ones(length(postStarts), 1));
        
        filenums = cat(1, filenums, ctr*ones(length(postStarts), 1));
       ztime = cat(2, ztime, squeeze(getEpochSignal(bandPower, fbStarts, fbEnds)));
        
    end; %clear ctr file sig sta par preStarts preEnds fbStarts fbEnds postStarts postEnds *ForFile 
    
%     exTrodes = EX_TRODES{c};
     save(ofile, 'targets','results','ntargets','filenums','ztime','fs'); 
end

clear zid sid