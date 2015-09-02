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

DO_GAUSS = false;

%% do plots of activation across the whole brain, by frequency, comparing 
% interior targets to exterior targets.  also stratifying on hit vs miss.

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    [~, hemi, bads] = dataFiles(subjid);
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);

    % perform anova (top level statistical analysis)
    isInterior = targets < ntargets & targets > 1;
    isHit = targets == results;
    trialClass = isInterior * 2 + isHit;
    trialClassNames = {'ext. miss', 'ext. hit', 'int. miss', 'int. hit'};

    % zscore the powers against rest powers for easier visualization
    mu = mean(restPowers, 1);
    sig = std(restPowers, [], 1);
    
    zPre = bsxfun(@minus, prePowers, mu);
    zPre = bsxfun(@rdivide, zPre, sig);
    
    zFb = bsxfun(@minus, fbPowers, mu);
    zFb = bsxfun(@rdivide, zFb, sig);
    
    load('recon_colormap');
    
    for figs = [2 4]%1:4
        switch (figs)
            case 1
                [h, ~, ~, stat] = ttest2(zPre(isInterior ~= 1, :, 1), zPre(isInterior == 1, :, 1), 0.05 / size(zPre, 2));
                titleStr = ('pre-trial delta');                
            case 2
                [h, ~, ~, stat] = ttest2(zPre(isInterior ~= 1, :, 5), zPre(isInterior == 1, :, 5), 0.05 / size(zPre, 2));
                titleStr = ('pre-trial HG');
            case 3
                [h, ~, ~, stat] = ttest2(zFb(trialClass == 1, :, 1), zFb(trialClass ~= 1, :, 1), 0.05 / size(zFb, 2));
                titleStr = ('in-trial delta');
            case 4
                [h, ~, ~, stat] = ttest2(zFb(trialClass == 1, :, 5), zFb(trialClass ~= 1, :, 5), 0.05 / size(zFb, 2));
                titleStr = ('in-trial HG');
        end                
            
%         figure
%         for f = 1:length(h)
%             ax(1) = subplot(211);
%             hist(zPre(trialClass == 1, f, 1));
%             ax(2) = subplot(212);
%             hist(zPre(trialClass ~= 1, f, 1));
%             linkaxes(ax, 'x');
%             title(sprintf('%d, %2.2f', h(f), stat.tstat(f)));
%             x = 5;
%         end
%         
%         return

        figure        
        
        if (DO_GAUSS == false)
            locs = trodeLocsFromMontage(subjid, Montage, false);
            siglocs = locs(h==1, :);
            sigweights = stat.tstat(h==1);
            nsiglocs = locs(h~=1, :);
            nsigweights = stat.tstat(h~=1);
            lims = [-max(abs(stat.tstat)) max(abs(stat.tstat))];
            
            PlotCortex(subjid, hemi);
            PlotDotsDirect(subjid, siglocs, sigweights, hemi, lims, 15, 'recon_colormap', [], false, true);
            PlotDotsDirect(subjid, nsiglocs, nsigweights, hemi, lims, 8, 'recon_colormap', [], false, true);
            
%             stat.tstat(h~=1) = nan;                
%             PlotDots(subjid, Montage.MontageTokenized, stat.tstat, hemi, [-max(abs(stat.tstat)) max(abs(stat.tstat))], 15, 'recon_colormap');
        else
            stat.tstat(isnan(stat.tstat)) = 0;
            PlotGauss(subjid, Montage.MontageTokenized, stat.tstat, hemi, [-max(abs(stat.tstat)) max(abs(stat.tstat))], 'recon_colormap');
        end

        colorbar;
        colormap(cm);
        
        view(90, 0);
        SaveFig(OUTPUT_DIR, sprintf('S%d %s lat', c, titleStr), 'png', '-r600');        
        view(270,0);
        
        if (DO_GAUSS)
            camlight;
        end
        
        SaveFig(OUTPUT_DIR, sprintf('S%d %s med', c, titleStr), 'png', '-r600');
        
    end         
    
%     preP = [];
%     fbP = [];
%     
%     for chan = 1:size(fbPowers, 2)
%         for freq = 1:size(BANDS, 1)
%             preP(chan, freq) = anova1(prePowers(:, chan, freq), trialClass, 'off');
%             fbP(chan, freq) = anova1(fbPowers(:, chan, freq), trialClass, 'off');
%         end
%     end
% 
%     % set bad channels to chance so we ignore them
%     preP(bads, :) = 0.5;
%     fbP(bads, :) = 0.5;
        
%     % break apart in to individual channel basis for pre activity
%     % bonferroni
%     p_thresh = 0.05 / size(fbPowers, 2) / length(BANDS) / 2 / 2;
%     % fdr
% %     p_thresh = fdr(cat(1, fbP(:), preP(:)), 0.05);
%     
% %     figure
% %     PlotCortex(subjid, hemi);
% %     hold on;
% %     PlotElectrodes(subjid, Montage.MontageTokenized, [], 0, 0)
%     
%     for chan = 1:length(preP)
%         if (min(preP(chan, :)) <= p_thresh)
%             figure;
%             titleStr = sprintf('S%d Pre %s', c, trodeNameFromMontage(chan, Montage));
%             multiBandPrettyBar(squeeze(zPre(:, chan, :)), trialClass, BAND_NAMES, [], titleStr);
%         end
%     end

%     for freq = 1:size(BANDS, 1)
%         for class = unique(trialClass)'
%             figure;
%             w = mean(zPre(trialClass==class, :, freq));
%             w(isnan(w)) = 0;
%             PlotGauss(subjid, Montage.MontageTokenized, w, hemi, [-1 1], 'recon_colormap');        
%             title(BAND_NAMES{freq});
%         end
%     end
% 
%     % break apart in to individual channel basis for fb activity
%     for chan = 1:length(fbP)
%         if (min(fbP(chan, :)) <= p_thresh)
%             figure;
%             titleStr = sprintf('S%d FB %s', c, trodeNameFromMontage(chan, Montage));
%             multiBandPrettyBar(squeeze(zPre(:, chan, :)), trialClass, BAND_NAMES, [], titleStr);
%         end
%     end
    
        
end

