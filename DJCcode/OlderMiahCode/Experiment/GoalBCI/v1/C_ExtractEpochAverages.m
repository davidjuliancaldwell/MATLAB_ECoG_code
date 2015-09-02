%% define constants
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'GoalBCI', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'d6c834', '6cc87c', 'ada1ab', '6b68ef'};
SUBCODES = {'S1','S2','S3','S4'};

BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];

UP = [1 2 3 4];
DOWN = [5 6 7 8];
FAR = [1 2 7 8];
NEAR = [3 4 5 6];
BIG = [2 4 6 8];
SMALL = [1 3 5 7];

%%
for c = 1:length(SIDS);
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);

    [files, ~, Montage] = goalDataFiles(subjid);

    nextTrialNum = 1;

    restMeans = [];
    tgtMeans = [];
    holdMeans = [];
    fbMeans = [];
    targets = [];
    results = [];
    timeSeries = {};
    timeSeries_beta = {};
    
    for fileIdx = 1:length(files)
        fprintf('  file %d of %d\n', fileIdx, length(files));

        [sig, sta, par] = load_bcidat(files{fileIdx});   
        
        par.LPTimeConstant
        
        if (fileIdx == 1 && strcmp(subjid, '6b68ef'))
            sig = sig(4e4:end, :);
            
            for fieldname = fieldnames(sta)'
                temp = sta.(fieldname{:});
                sta.(fieldname{:}) = temp(4e4:end, :);
            end
        end
        
        fs = par.SamplingRate.NumericValue;

        % pre-process
        sig = double(sig);
        sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
        sig = notch(sig, [120 180], fs, 4);

        % figure out when the various epoch types begin and end        
        [restStarts, restEnds, tgtStarts, tgtEnds, holdStarts, holdEnds, fbStarts, fbEnds] = ...
            identifyFullEpochs(sta, par);

        targets = cat(1, targets, double(sta.TargetCode(fbStarts)));
        results = cat(1, results, double(sta.ResultCode(fbEnds+1)));        
        
        restMeansForFile = zeros(size(sig, 2), length(restStarts), size(BANDS, 1));
        tgtMeansForFile = zeros(size(sig, 2), length(tgtStarts), size(BANDS, 1));
        holdMeansForFile = zeros(size(sig, 2), length(holdStarts), size(BANDS, 1));
        fbMeansForFile = zeros(size(sig, 2), length(fbStarts), size(BANDS, 1));
        
        timeSeriesForFile = cell(size(sig, 2), length(restStarts), 1);
        
        % extract the epoch means
        for bandIdx = 1:size(BANDS, 1)
            band = BANDS(bandIdx, :);
            
            % extract the feature of interest
            blp = zscore(log(hilbAmp(sig, band, fs).^2));
        
            restMeansForFile(:, :, bandIdx) = getEpochMeans(blp, restStarts, restEnds);
            tgtMeansForFile(:, :, bandIdx) = getEpochMeans(blp, tgtStarts, tgtEnds);
            holdMeansForFile(:, :, bandIdx) = getEpochMeans(blp, holdStarts, holdEnds);
            fbMeansForFile(:, :, bandIdx) = getEpochMeans(blp, fbStarts, fbEnds);            
            
            if (bandIdx == size(BANDS, 1))
                blp = GaussianSmooth(blp, fs/2);
                blp = downsample(blp, 10);
                timeSeriesForFile = getEpochSignal(blp , round(restStarts/10), round(fbEnds/10));
            end
            
            if (bandIdx == size(BANDS, 1) - 1) % beta
                blp = GaussianSmooth(blp, fs/2);
                blp = downsample(blp, 10);
                timeSeriesForFile_beta = getEpochSignal(blp, round(restStarts/10), round(fbEnds/10));
            end
        end     
                
        restMeans = cat(2, restMeans, restMeansForFile);
        tgtMeans = cat(2, tgtMeans, tgtMeansForFile);
        holdMeans = cat(2, holdMeans, holdMeansForFile);
        fbMeans = cat(2, fbMeans, fbMeansForFile);    
        timeSeries = cat(2, timeSeries, timeSeriesForFile);        
        timeSeries_beta = cat(2, timeSeries_beta, timeSeriesForFile_beta);        
    end
  
%     save(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)), '-append', 'targets', 'results');
    save(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)), 'restMeans','tgtMeans','holdMeans','fbMeans','targets','results', 'fs');
    tsfs = fs / 10;
    save(fullfile(META_DIR, sprintf('%s-timeseries.mat', subcode)), 'timeSeries', 'tsfs');
    save(fullfile(META_DIR, sprintf('%s-timeseries_beta.mat', subcode)), 'timeSeries_beta', 'tsfs');    
end 

