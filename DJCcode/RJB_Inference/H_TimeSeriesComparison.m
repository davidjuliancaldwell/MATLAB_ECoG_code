Z_Constants;

addpath ./scripts;

%% 

load(fullfile(META_DIR, 'areas.mat'), 'hmats');
key = {'RM1','LM1','RS1','LS1','RSMA','LSMA','RpSMA','LpSMA','RPMd','LPMd','RPMv','LPMv'};
mkey = {'Other', 'M1', 'S1', 'SMA' ,'pSMA', 'PMd', 'PMv'};

warning 'dropping the seventh subject because their feedback period wasn''t as long';

SIDS(7) = [];
hmats(7) = [];

warning 'dropping the ERP feature because it sucks';
BANDS(6,:) = [];
BAND_NAMES(6) = [];
BAND_TYPE(6) = [];

%%

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), ...
        'tstats', 'blob*', 'repochs', 'montage', 'rt', 'tgts', 'sigthresh', 'winsize', 'stepsize');    
        
    for bandi = 1:size(BANDS, 1)
        % first significance threshold the tstats
        h = ismember(blobs{bandi}, find(blobsize{bandi}>=sigthresh(bandi)));
        temp = tstats{bandi} .* gridToLin(h, 1:2);
                
        % what is meaningful to look at here? fraction of grid
%         bandCounts(c, bandi, :) = sum(temp~=0) / size(temp, 1);
        bandCounts(c, bandi, :) = mean(abs(temp));
    end           
end

%% look at the qty of electrodes showing a significant change as a function of time ...

cols = 'rgbcm';

figure;

for bandi = 1:length(BAND_NAMES)
    plotWSE(rt, squeeze(bandCounts(:, bandi, :))', cols(bandi), .2, [cols(bandi) '.-'], 2);
    hold on;
end

set(gca, 'ylim', [-0.05 0.90]);
vline([-2 0 3], 'k');


legend(BAND_NAMES, 'location', 'northwest');

title('Significant activity differences across time');
xlabel('Time (s)');
ylabel('Average |t-statistic|');

SaveFig(OUTPUT_DIR, 'ts-freq', 'png', '-r600');
SaveFig(OUTPUT_DIR, 'ts-freq', 'eps', '-r600');

%% now show slices at t = ~0 and t = ~1
figure

cols = 'rgbcm';

for temp = {{1, 0},{2, 1}}
    subn = temp{1}{1};
    mint = temp{1}{2};
    
    subplot(2,1,subn);
    
    idx = find(rt>=mint, 1);
    actt = rt(idx);
    
    data = bandCounts(:,:,idx);
    mu = mean(data, 1);
    sig = sem(data, 1);
    
    for bandi = 1:length(BAND_NAMES)
%         set(bar(bandi, mu(bandi)), 'linew', 2, 'facecolor', cols(bandi));
        plot([bandi-.3 bandi+.3], [mu(bandi) mu(bandi)], 'color', cols(bandi), 'linew', 2);
        hold on;
        plot([bandi-.3 bandi+.3], [mu(bandi)+sig(bandi) mu(bandi)+sig(bandi)], 'color', cols(bandi), 'linew', 1);
        plot([bandi-.3 bandi+.3], [mu(bandi)-sig(bandi) mu(bandi)-sig(bandi)], 'color', cols(bandi), 'linew', 1);
        
%         errorbar(bandi, mu(bandi), sig(bandi), 'k', 'linew', 2);
        scatter(jitter(repmat(bandi, size(data, 1), 1), .05), data(:, bandi), 'markerfacecolor', cols(bandi), 'markeredgecolor', 'k', 'linew', 1);
    end
    
    ylims = ylim;
    set(gca, 'ylim', [-0.03 ylims(2)]);
    set(gca, 'xtick', 1:length(BAND_NAMES))
    set(gca, 'xticklabel', BAND_NAMES);
    
    title(sprintf('Significant activity differences at t = %1.2f sec', actt));
    ylabel('Average |t-statistic|');
end

SaveFig(OUTPUT_DIR, 'ts-freq-slice', 'png', '-r600');
SaveFig(OUTPUT_DIR, 'ts-freq-slice', 'eps', '-r600');

%% look at the spatial HG for the three subjects of interest during the cue phase

for c = [2 6 8]
    sid = SIDS{c};
    fprintf('individual brain plots for working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), ...
        'tstats', 'blob*', 'repochs', 'montage', 'rt', 'tgts', 'sigthresh', 'winsize', 'stepsize');    
    
    bas = brodmannAreaForMontage(sid, montage);
    
    h = ismember(blobs{5}, find(blobsize{5}>=sigthresh(5)));
    temp = tstats{5} .* gridToLin(h, 1:2);    
    
    kt = rt>=-1 & rt <=0;
    val = mean(temp(:, kt),2); 
    
    val(abs(val)<1.96) = NaN;

    fprintf(' BAs represented: ');
    arrayfun(@(x) fprintf('%d ', x), bas(~isnan(val)));
    fprintf('\n');
    
    figure
    PlotDotsDirect(sid, montage.MontageTrodes, val, determineHemisphereOfCoverage(sid), [-5 5], 20, 'america', [], false);
    colorbarLabel('t-statistic');
    load('america');
    colormap(cm);    
    set_colormap_threshold(gcf, [-1.96 1.96], [-5 5], [1 1 1]);
    title(sid);
    SaveFig(OUTPUT_DIR, ['ts-brain-' sid], 'png', '-r300');    
end

%% look at the spatial HG for all subjects during the fb phase

for c = 1:length(SIDS)
    sid = SIDS{c};
    fprintf('individual brain plots for working on subject %s\n', sid);

    load(fullfile(META_DIR, sprintf('ts_analysis_%s', sid)), ...
        'tstats', 'blob*', 'repochs', 'montage', 'rt', 'tgts', 'sigthresh', 'winsize', 'stepsize');    
    
    bas = brodmannAreaForMontage(sid, montage);
    
    h = ismember(blobs{5}, find(blobsize{5}>=sigthresh(5)));
    temp = tstats{5} .* gridToLin(h, 1:2);    
    
    kt = rt>=0 & rt <=3;
    val = mean(temp(:, kt),2); 
    
    val(abs(val)<1.96) = NaN;

    fprintf(' BAs represented: ');
    arrayfun(@(x) fprintf('%d ', x), bas(~isnan(val)));
    fprintf('\n');
    
    figure
    PlotDotsDirect(sid, montage.MontageTrodes, val, determineHemisphereOfCoverage(sid), [-5 5], 20, 'america', [], false);
    colorbarLabel('t-statistic');
    load('america');
    colormap(cm);    
    set_colormap_threshold(gcf, [-1.96 1.96], [-5 5], [1 1 1]);
    title(sid);
    SaveFig(OUTPUT_DIR, ['ts-brain-fb-' sid], 'png', '-r300');    
end
