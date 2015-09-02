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
    
%     % select the hmat values for this sub
%     mhs = hmats{c};
%     
%     % cull the unused hmat values
%     n = size(tstats{1}, 1);    
%     mhs = mhs(1:n);
%     
%     hasact = false(n, length(rt));
    
    for bandi = 1:size(BANDS, 1)
        % first significance threshold the tstats
        h = ismember(blobs{bandi}, find(blobsize{bandi}>=sigthresh(bandi)));
        temp = tstats{bandi} .* gridToLin(h, 1:2);
        
%         hasact = hasact | temp~=0;
        
        % what is meaningful to look at here? fraction of grid
        bandCounts(c, bandi, :) = sum(temp~=0) / size(temp, 1);
    end    
    
%     % number of electrodes with significant weights in a given HMAT area as
%     % a function of time?        
%     for ari = 1:7
%         if (ari == 1)
%             ars = 0;
%         else
%             ars = [ari*2-1 ari*2];
%         end
%         
%         
%         
%         arCounts(c, ari, :) = sum(hasact(ismember(mhs, ars), :), 1) / length(mhs);
%     end    
end

%% look at the qty of electrodes showing a significant change as a function of time ...

cols = 'rgbcm';

figure;

for bandi = 1:length(BAND_NAMES)
    plotWSE(rt, squeeze(bandCounts(:, bandi, :))', cols(bandi), .2, [cols(bandi) '.-'], 2);
    hold on;
end

set(gca, 'ylim', [-0.05 0.30]);
vline([-2 0 3], 'k');


legend(BAND_NAMES, 'location', 'northwest');

title('Significant activity differences across time');
xlabel('Time (s)');
ylabel('Fraction of electrodes');

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
    ylabel('Fraction of electrodes');
end

SaveFig(OUTPUT_DIR, 'ts-freq-slice', 'png', '-r600');
SaveFig(OUTPUT_DIR, 'ts-freq-slice', 'eps', '-r600');

