%% define constants
tcs;

META_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'meta');
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'), 'MultiTarget', 'figures');

TouchDir(META_DIR);
TouchDir(OUTPUT_DIR);

SIDS = {'fc9643', '38e116'};
SUBCODES = {'S1', 'S2'};
CONTROL_CHANS = [24 33];

FONT_SIZE = 20;
LEGEND_FONT_SIZE = 14;

BANDS = [1 4; 4 7; 8 12; 13 18; 70 200];

themeColorList = [5 6 7 8 9 10 4];

%% do the plots of HG activation at the control electrode

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);
    
    tgtTypes = unique(blockntargets);

    figures = [];
    ps{c} = [];
    filenames = {};
    
    for tgtType = tgtTypes'
        % process all cases where total number of targets was tgtType
        handle = figure;

        controlHG = blockPowers(blockntargets==tgtType, CONTROL_CHANS(c), end);
        subTargets = blockTargets(blockntargets==tgtType);
        
        leg = {};

        for target = 1:tgtType
            hs = histfit(controlHG(subTargets==target));
              % hs(1) is the patch object
              % hs(2) is the lineseries object            
            set(hs(1), 'facecolor', theme_colors(themeColorList(target), :));
            set(hs(1), 'edgecolor', 'none');
            set(hs(1), 'facealpha', .5);
            set(hs(2), 'color', theme_colors(themeColorList(target), :));
            legendOff(hs(1));
            hold on;            
        end
        
        if (c == 1 && tgtType == 3)
            handleToSave = handle;
        end
        
%         ax = prettybox(controlHG, subTargets, theme_colors(4*ones(tgtType, 1)+c, :), 3, true);
%         ps{c}(end+1) = anova1(controlHG, subTargets, 'off');
%             
%         
%         title(sprintf('%s - Target Count: %d', subcode, tgtType));        
%         ylabel('log HG power');        
%         minylim = min(min(ylim), minylim);
%         maxylim = max(max(ylim), maxylim);        
%         set(gca, 'xtick', []);
%         set(gca, 'xdir', 'reverse');
%         filenames{figures(end)} = sprintf('control-whisker-%s-%d',subcode, tgtType);
    end
        
%     for fig = figures
%         figure(fig);
%         
%         ylim([minylim maxylim]);
%         set(gca, 'xticklabel', 'none')
%         set(gca,'ydir','reverse')
% 
%         view(-90, 90);
%         
% %         SaveFig(OUTPUT_DIR, filenames{fig}, 'eps', '-r300');
%     end
end

figure(handleToSave);
set(gca, 'fontsize', LEGEND_FONT_SIZE);
xlabel('log HG power', 'fontsize', FONT_SIZE);
ylabel('counts', 'fontsize', FONT_SIZE);
title('Distribution of HG power per block', 'fontsize', FONT_SIZE);
legend('Highest', 'Middle', 'Lowest');
SaveFig(OUTPUT_DIR, 'by_block_example', 'eps', '-r300');
