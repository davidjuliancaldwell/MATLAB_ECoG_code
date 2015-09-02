%% setup path
addpath ./scripts

%% define constants
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'fc9643', '38e116'};
SUBCODES = {'S1', 'S2'};
CONTROL_CHANS = [24 33];

BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];
BAND_NAMES = {'delta', 'theta', 'alpha', 'beta', 'gamma'};

themeColorList = [5 6 7 8 9 10 4];

%% do work
for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);

    if (exist('exTrodes', 'var') && ~isempty(exTrodes))
        isInterior = targets < ntargets & targets > 1;
        isHit = targets == results;            
        trialClass = isInterior * 2 + ~isHit;
        trialClassNames = {'ext. hit', 'ext. miss', 'int. hit', 'int. miss'};        
        
        for d = 1:length(exTrodes)
            trode = exTrodes(d);            
            trodeName = trodeNameFromMontage(trode, Montage);
            
            % all this next section is doing is reorganizing the timeseries
            % as a matrix
            shortest = Inf;
            
            for e = 1:size(ztime, 1)
                shortest = min(shortest, size(ztime{e, 5}, 1));
            end
            
            ts = zeros(shortest, size(ztime, 1));
            
            for e = 1:size(ztime, 1)
                ts(:, e) = ztime{e, 5}((end-shortest+1):end, d);
            end

            % now we want to display the average timeseries surrounded by
            % their std errors
            uniqueClasses = unique(trialClass);
            
            figure;
            
            for classIdx = 1:length(uniqueClasses)
                idxs = trialClass == uniqueClasses(classIdx);
                muTs = mean(ts(:, idxs), 2);
                sigTs = std(ts(:, idxs), [], 2);
                semTs = sigTs / sum(idxs);
                
                h = plot(GaussianSmooth(muTs + semTs, fs/2), ':', 'color', theme_colors(themeColorList(classIdx), :), 'linewidth', 2);
                legendOff(h);
                hold on;
                h = plot(GaussianSmooth(muTs - semTs, fs/2), ':', 'color', theme_colors(themeColorList(classIdx), :), 'linewidth', 2);
                legendOff(h);
                plot(GaussianSmooth(muTs, fs/2), 'color', theme_colors(themeColorList(classIdx), :), 'linewidth', 3);
            end
            
            set(gcf,'Position',[100 100 2100 500])  
            
            axis tight;
            
            h = legend('ext. hit', 'ext. miss', 'int. hit', 'int. miss', 'Location', 'eastoutside');
            set(h, 'fontsize', LEGEND_FONT_SIZE)
            title(trodeName, 'fontsize', FONT_SIZE);

            vline(fs, 'k');
            vline(fs*3, 'k');
            vline(fs*6, 'k');
            set(gca, 'xticklabel', [-3 -2 -1 0 1 2 3 4]);
            set(gca, 'fontsize', LEGEND_FONT_SIZE);
            xlabel('Time (s)', 'fontsize', FONT_SIZE);
            ylabel('z(log HG)', 'fontsize', FONT_SIZE);
            
            SaveFig(OUTPUT_DIR, sprintf('ts_ex_%d',d), 'eps', '-r300');
        end
    end    
end

