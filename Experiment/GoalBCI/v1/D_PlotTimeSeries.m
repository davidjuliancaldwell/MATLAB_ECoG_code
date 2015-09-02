% plot some basic things like subject coverage
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

for c = 1:length(SIDS)    
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

    % sort by trial type
    [sortedTargets, sortOrder] = sort(targets);

    for chan = 1:size(timeSeries, 1)
        maxLen = -Inf;
        for epoch = 1:size(timeSeries, 2)
             maxLen = max(maxLen, length(timeSeries{chan, epoch}));
        end
        
        data = NaN*zeros(size(timeSeries, 2), maxLen);
        
        for epoch = 1:size(timeSeries, 2)
            data(epoch, 1:length(timeSeries{chan, epoch})) = timeSeries{chan, epoch};
        end

        % new version, looking at time-series only
        % drop the null targets                
        isUp    = ismember(targets, UP);
        isDown  = ismember(targets, DOWN);
        isNear  = ismember(targets, NEAR);
        isFar   = ismember(targets, FAR);
        isBig   = ismember(targets, BIG);
        isSmall = ismember(targets, SMALL);

        t = (1:maxLen)/tsfs;
        data(nulls, :) = [];

        subplot(221);
        D_PlotTimeSeries_SubPlot(t, data, isUp, isDown, {'up', 'down'}); axis tight;
        subplot(222);
        D_PlotTimeSeries_SubPlot(t, data, isNear, isFar, {'near', 'far'}); axis tight;
        subplot(223);
        D_PlotTimeSeries_SubPlot(t, data, isBig, isSmall, {'big', 'small'}); axis tight;
        
        % original version
%         % drop the null targets
%         data(nulls, :) = [];
%                 
%         % do the by trial plot
%         subplot(2,2,1);
%         
%         trial = 1:size(data, 1);
%         t = (1:maxLen)/tsfs;
%         
%         imagesc(t, trial, data(sortOrder, :));
%         vline(1);
%         vline(2);
%         vline(4);
%         
%         xlabel('time (s)');
%         ylabel('trial');
%         
%         subplot(222);
%         imagesc([targets(sortOrder) results(sortOrder)])
%         
%         subplot(2,2,3:4);
%         
%         plot(t, nanmean(data(ismember(targets, UP), :)), 'r');
%         hold on;
%         plot(t, nanmean(data(ismember(targets, DOWN), :)), 'g');
%         plot(t, nanmean(data(ismember(targets, NEAR), :)), 'b');
%         plot(t, nanmean(data(ismember(targets, FAR), :)), 'c');
%         plot(t, nanmean(data(ismember(targets, BIG), :)), 'm');
%         plot(t, nanmean(data(ismember(targets, SMALL), :)), 'k');
%         
%         legend('up', 'down', 'near', 'far', 'big', 'small', 'location', 'eastoutside');
%         
%         vline(1);
%         vline(2);
%         vline(4);
        
        mtit(trodeNameFromMontage(chan, Montage));        
        axis tight;
        
%         subplot(224);
%         M.MontageTokenized = {trodeNameFromMontage(c, Montage)};
%         loc = trodeLocsFromMontage(sid, Montage, false);
%         PlotDotsDirect(sid, loc, 1, hemi, [0 1], 20, 'recon_colormap', [], false, false);
        
        TouchDir(fullfile(OUTPUT_DIR, 'dump'));

        SaveFig(fullfile(OUTPUT_DIR, 'dump'), sprintf('%s-%d', subcode, chan), 'png');
        close;
    end
    
end