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

% PERICONTROL_TRODES = {[5 8 16 24 32 7 15 23 31], [25 33 41 26 34 42]};
PRE_TRODES = {[54 55 24 28 21], [41 60 61 62]};
FB_TRODES = {[56 55 22 30 20], [33 41 60 59]};

%% plot the brains, so we have them
for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);

    [~, hemi, bads] = dataFiles(subjid);

    w = ones(size(fbPowers, 2), 1);
    w(bads) = NaN;
    locs = trodeLocsFromMontage(subjid, Montage, false);
    
    % do the pre figure
    figure;
    is = zeros(size(w));
    is(PRE_TRODES{c}) = 1;
    
    PlotDotsDirect(subjid, locs(is==0, :), w(is==0), hemi, [0 1], 5, 'recon_colormap', [], false, false);
    PlotDotsDirect(subjid, locs(is==1, :), w(is==1), hemi, [0 1], 10, 'recon_colormap', [], false, true);
    
    SaveFig(OUTPUT_DIR, sprintf('%s pre brain', subcode), 'png', '-r300');

    % do the fb figure
    figure;
    is = zeros(size(w));
    is(FB_TRODES{c}) = 1;
    
    PlotDotsDirect(subjid, locs(is==0, :), w(is==0), hemi, [0 1], 5, 'recon_colormap', [], false, false);
    PlotDotsDirect(subjid, locs(is==1, :), w(is==1), hemi, [0 1], 10, 'recon_colormap', [], false, true);
    
    SaveFig(OUTPUT_DIR, sprintf('%s fb brain', subcode), 'png', '-r300');
    
    
end

%% do plots of activation across the whole brain, by frequency, comparing 
% interior targets to exterior targets.  also stratifying on hit vs miss.

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};
    
    metaFile = fullfile(META_DIR, sprintf('%s.mat', subjid));
    load(metaFile);

    % perform anova (top level statistical analysis)
    isInterior = targets < ntargets & targets > 1;
    isHit = targets == results;
    trialClass = isInterior * 2 + ~isHit;
    trialClassNames = {'ext. hit', 'ext. miss', 'int. hit', 'int. miss'};

    % zscore the powers against rest powers for easier visualization
    mu = mean(restPowers, 1);
    sig = std(restPowers, [], 1);
    
    zPre = bsxfun(@minus, prePowers, mu);
    zPre = bsxfun(@rdivide, zPre, sig);
    
    zFb = bsxfun(@minus, fbPowers, mu);
    zFb = bsxfun(@rdivide, zFb, sig);

%     zPre = prePowers;
%     zFb = fbPowers;
    
    trodes = PRE_TRODES{c};
    
    for trode = trodes
        trodeName = trodeNameFromMontage(trode, Montage);
        
        figure;
        
        [~, p] = ttest2(zPre(isInterior==0, trode, 5), zPre(isInterior==1, trode, 5));
        
        [mu, sem] = barStats(zPre(:, trode, 5), trialClass);
        % assume all classes are represented (0:3)
        
        % mash in an extra between mu(2) and mu(3)
        mu = [mu(1:2); 0; mu(3:4)];
        sem = [sem(1:2); 0; sem(3:4)];
        
        cm = theme_colors([5 6 1 7 8], :);
        h = barweb(mu, sem, 1, [], [], [], [], cm, 'none');        
        ylabel('z(log HG)', 'fontsize', FONT_SIZE+8);
        
        if (max(mu) < 0)
            ys = get(gca, 'ylim');
            set(gca, 'ylim', [ys(1) 0.1]);
        end
        
        ticklocs = linspace(.70, 1.3, 9);        
        sigstar({ticklocs([2 8])}, p);
        
        mTitle = sprintf('S%d %s - pre', c, trodeName);
        SaveFig(OUTPUT_DIR, mTitle, 'eps');
        close
    end
    
    trodes = FB_TRODES{c};
    
    for trode = trodes
        trodeName = trodeNameFromMontage(trode, Montage);
        
        figure;
        
        [~, p] = ttest2(zFb(isInterior==0 & isHit==1, trode, 5), zFb(isInterior~=0 | isHit~=1, trode, 5));
        
        [mu, sem] = barStats(zFb(:, trode, 5), trialClass);
        % assume all classes are represented (0:3)

        % mash in an extra between mu(2) and mu(3)
        mu = [mu(1); 0; mu(2:4)];
        sem = [sem(1); 0; sem(2:4)];
        
        cm = theme_colors([5 1 6 7 8], :);
        h = barweb(mu, sem, 1, [], [], [], [], cm, 'none');        
        ylabel('z(log HG)', 'fontsize', FONT_SIZE+8);

        if (max(max(mu+sem)) < 0)
            ys = get(gca, 'ylim');
            set(gca, 'ylim', [ys(1) 0.1]);
        end

        
        ticklocs = linspace(.70, 1.3, 9);        
        sigstar({ticklocs([1 7])}, p);
        
        mTitle = sprintf('S%d %s - fb', c, trodeName);
        SaveFig(OUTPUT_DIR, mTitle, 'eps');
        close
    end
    
end

