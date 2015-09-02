% plot some basic things like subject coverage
addpath ./functions
Constants
%%
warning 'faked out'
for c = 4%1:length(SIDS)    
% for c = 1:length(SIDS)    
    sid = SIDS{c};
    subcode = SUBCODES{c};
    
    [~, hemi, Montage] = goalDataFiles(sid);
%     load(fullfile(META_DIR, sprintf('%s-timeseries_beta.mat', subcode)));
%     timeSeries = timeSeries_beta;
   load(fullfile(META_DIR, sprintf('%s-timeseries.mat', subcode)));
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subcode)), 'targets', 'results');

    nulls = targets == 9;
    targets(nulls) = [];
    results(nulls) = [];

    isUp = ismember(targets, UP);      
    
    maxsbp = 16;    
    nsubs = ceil(sqrt(maxsbp));
    sbp = 1;
    nfigs = 0;
    
    for chan = 1:size(timeSeries, 1)
        if (sbp > maxsbp)
            mtit(subcode, 'xoff', 0, 'yoff', .025);
            SaveFig(OUTPUT_DIR, sprintf('ts_%s_%d', subcode, nfigs), 'eps', '-r600');
            sbp = 1;
        end
        
        if (sbp == 1)
            figure
            nfigs = nfigs + 1;
        end
        
        subplot(nsubs, nsubs, sbp);
        sbp = sbp + 1;
        
        maxLen = -Inf;
        for epoch = 1:size(timeSeries, 2)
             maxLen = max(maxLen, length(timeSeries{chan, epoch}));
        end
        
        data = NaN*zeros(size(timeSeries, 2), maxLen);
        
        for epoch = 1:size(timeSeries, 2)
            data(epoch, 1:length(timeSeries{chan, epoch})) = timeSeries{chan, epoch};
        end

        data(nulls,:) = [];
        t = (1:size(data, 2))/tsfs;
        
        prettyline(t-4, data', isUp, [ .4 .4 .8; .8 .4 .4]);
        
%         leg = cell(length(legendValues), 1);
%         for d = 1:length(legendValues)
%             leg{d} = num2str(legendValues(d));
%         end
%         legend(leg);
        
        vline([1 4 10]-4, 'k:');

        title(trodeNameFromMontage(chan, Montage));        
        axis tight;

%         TouchDir(fullfile(OUTPUT_DIR, 'dump'));
% 
%         SaveFig(fullfile(OUTPUT_DIR, 'dump'), sprintf('%s-%d', subcode, chan), 'png');
%         close;
    end    
    
    mtit(subcode, 'xoff', 0, 'yoff', .025);
    SaveFig(OUTPUT_DIR, sprintf('ts_%s_%d', subcode, nfigs), 'eps', '-r600');
    
end