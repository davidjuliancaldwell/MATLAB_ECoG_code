%% define constants
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'VarianceChanges', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'VarianceChanges', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

SIDS = {'fc9643', '38e116'};
SUBCODES = {'S1', 'S2'};
CONTROL_CHANS = [24 33];

BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];

themeColorList = [5 6 7 8 9 10 4];

%% do the plots of HG activation at the control electrode

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);
return    
    tgtTypes = unique(ntargets);

    minylim = Inf;
    maxylim = -Inf;
    
    figures = [];
    ps{c} = [];
    filenames = {};
    
    for tgtType = tgtTypes'
        % process all cases where total number of targets was tgtType
        figures(end+1) = figure;

        controlHG = fbPowers(ntargets==tgtType, CONTROL_CHANS(c), end);
        restHG = restPowers(ntargets==tgtType, CONTROL_CHANS(c), end);

        subTargets = targets(ntargets==tgtType);
        
        leg = {};

        ax = prettybox(cat(1, restHG, controlHG), cat(1, zeros(length(restHG), 1), subTargets), cat(1, [0 0 0], theme_colors(4*ones(tgtType, 1)+c, :)), 3, true);
        ps{c}(end+1) = anova1(controlHG, subTargets, 'off');
            
        
        %title(sprintf('%s - Target Count: %d', subcode, tgtType));        
        ylabel('log HG power', 'fontsize', FONT_SIZE);        
        set(gca, 'fontsize', LEGEND_FONT_SIZE);
        minylim = min(min(ylim), minylim);
        maxylim = max(max(ylim), maxylim);        
        set(gca, 'xtick', []);
        set(gca, 'xdir', 'reverse');
        filenames{figures(end)} = sprintf('control-whisker-%s-%d',subcode, tgtType);
    end
    
    for fig = figures
        figure(fig);
        
        if (c == 1)
            ylim([20 maxylim]);
        else
            ylim([minylim maxylim]);
        end
        
        set(gca, 'xticklabel', 'none')
        set(gca,'ydir','reverse')

        view(-90, 90);
        
        SaveFig(OUTPUT_DIR, filenames{fig}, 'eps', '-r300');
    end
end

