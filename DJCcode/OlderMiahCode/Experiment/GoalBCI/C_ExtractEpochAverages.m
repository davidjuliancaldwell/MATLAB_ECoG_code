%% define constants
tcs;
Z_Constants;

%%
for c = 1:length(SIDS);
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    fprintf ('processing %s: \n', subcode);

    [files, ~, Montage, ~, isbias] = goalDataFiles(subjid);
%     files(isbias==1) = [];

    nextTrialNum = 1;

    restMeans = [];
    tgtMeans = [];
    holdMeans = [];
    preFbMeans = [];
    fbMeans = [];
    targets = [];
    results = [];
    timeSeries = {};
    timeSeries_beta = {};
    
    for fileIdx = 1:length(files)
        fprintf('  file %d of %d\n', fileIdx, length(files));

        [sig, sta, par] = load_bcidat(files{fileIdx});   

        if (strendswith(files{fileIdx}, 'D5\6b68ef_goal_bci001\6b68ef_goal_bciS001R01.dat'))
            sig = sig(9362:end, :);
            
            for fieldname = fieldnames(sta)'
                temp = sta.(fieldname{:});
                sta.(fieldname{:}) = temp(9362:end, :);
            end
        end
        
        fs = par.SamplingRate.NumericValue;
        
        % pre-process
        sig = double(sig);
        sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, sig);
        sig = notch(sig, [120 180], fs, 4);

        % figure out when the various epoch types begin and end        
        [restStarts, restEnds, tgtStarts, ~, ~, holdEnds, fbStarts, fbEnds] = ...
            identifyFullEpochs(sta, par);
%         [restStarts, restEnds, tgtStarts, tgtEnds, holdStarts, holdEnds, fbStarts, fbEnds] = ...
%             identifyFullEpochs(sta, par);

        targets = cat(1, targets, double(sta.TargetCode(fbStarts)));
        results = cat(1, results, double(sta.ResultCode(fbEnds+1)));        
        
        restMeansForFile = zeros(size(sig, 2), length(restStarts), size(BANDS, 1));
%         tgtMeansForFile = zeros(size(sig, 2), length(tgtStarts), size(BANDS, 1));
%         holdMeansForFile = zeros(size(sig, 2), length(holdStarts), size(BANDS, 1));
        preFbMeansForFile = zeros(size(sig, 2), length(tgtStarts), size(BANDS, 1));
        fbMeansForFile = zeros(size(sig, 2), length(fbStarts), size(BANDS, 1));
        
        timeSeriesForFile = cell(size(sig, 2), length(restStarts), 1);
        
        % extract the epoch means
        for bandIdx = 1:size(BANDS, 1)
            band = BANDS(bandIdx, :);
            
            % extract the feature of interest
            blp = hilbAmp(sig, band, fs);
%             blp = zscore(log(hilbAmp(sig, band, fs).^2));
        
            restMeansForFile(:, :, bandIdx) = getEpochMeans(blp, restStarts, restEnds);
%             tgtMeansForFile(:, :, bandIdx) = getEpochMeans(blp, tgtStarts, tgtEnds);
%             holdMeansForFile(:, :, bandIdx) = getEpochMeans(blp, holdStarts, holdEnds);
            preFbMeansForFile(:, :, bandIdx) = getEpochMeans(blp, tgtStarts, holdEnds);
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
%         tgtMeans = cat(2, tgtMeans, tgtMeansForFile);
%         holdMeans = cat(2, holdMeans, holdMeansForFile);
        preFbMeans = cat(2, preFbMeans, preFbMeansForFile);
        fbMeans = cat(2, fbMeans, fbMeansForFile);    
        timeSeries = cat(2, timeSeries, timeSeriesForFile);        
        timeSeries_beta = cat(2, timeSeries_beta, timeSeriesForFile_beta);        
    end
  
%     save(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)), '-append', 'targets', 'results');
    save(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)), 'restMeans','preFbMeans','fbMeans','targets','results', 'fs');
    
    tsfs = fs / 10;
    save(fullfile(META_DIR, sprintf('%s-timeseries.mat', subcode)), 'timeSeries', 'tsfs');
    save(fullfile(META_DIR, sprintf('%s-timeseries_beta.mat', subcode)), 'timeSeries_beta', 'tsfs');    
end 

