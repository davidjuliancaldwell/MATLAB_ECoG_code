% %% collect data
% subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';

[~, odir] = filesForSubjid(subjid);
load(fullfile(odir, [subjid '_epochs_clean']));

%% review all epochs
% process on a channel by channel basis

t  = (-itiDur-preDur):1/fs:(fbDur+postDur);
    
hits = tgts==ress;
misses = ~hits;

hit_hg = epochs_hg(:, hits, :);
miss_hg = epochs_hg(:, misses, :);

hit_beta = epochs_beta(:, hits, :);
miss_beta = epochs_beta(:, misses, :);
    
rsas_hg = zeros(size(epochs_hg, 1), length(t));
rsas_beta = zeros(size(rsas_hg));

for c = 1:size(epochs_hg, 1)
    fprintf('channel %d\n', c);
  
    rsas_hg(c, :) = signedSquaredXCorrValue(squeeze(hit_hg(c,:,:)), squeeze(miss_hg(c,:,:)), 1);
    rsas_beta(c, :) = signedSquaredXCorrValue(squeeze(hit_beta(c,:,:)), squeeze(miss_beta(c,:,:)), 1);    
end

[h_hg, ~, ~, stats_hg] = ttest2(hit_hg, miss_hg, 0.05, 'both', 'unequal', 2);
[h_beta, ~, ~, stats_beta] = ttest2(hit_beta, miss_beta, 0.05, 'both', 'unequal', 2);

h_hg = squeeze(h_hg);
stats_hg.tstat = squeeze(stats_hg.tstat);
h_beta = squeeze(h_beta);
stats_beta.tstat = squeeze(stats_beta.tstat);

hitMean_hg = squeeze(mean(hit_hg,2));
hitSEM_hg = squeeze(sem(hit_hg,2));
missMean_hg = squeeze(mean(miss_hg,2));
missSEM_hg = squeeze(sem(miss_hg,2));

hitMean_beta = squeeze(mean(hit_beta,2));
hitSEM_beta = squeeze(sem(hit_beta,2));
missMean_beta = squeeze(mean(miss_beta,2));
missSEM_beta = squeeze(sem(miss_beta,2));

[~, odir] = filesForSubjid(subjid);

save(fullfile(odir, [subjid '_results']), 'rsas_hg', 'rsas_beta', 'hitMean_hg', 'hitSEM_hg', ...
    'missMean_hg', 'missSEM_hg', 'hitMean_beta', 'hitSEM_beta', 'missMean_beta', 'missSEM_beta', ...
    'h_hg', 'h_beta', 'stats_hg', 'stats_beta');

return;

%% display one at a time
sfac = 100;

TouchDir(fullfile(odir, 'figs'));

for c = 1:size(epochs_hg, 1)
    if (~ismember(c, bads))
        figure;
        subplot(211);
        plot(t, GaussianSmooth(hitMean_hg(c, :), sfac), 'r', 'LineWidth', 2); hold on;
%         plot(t,  hitSEM_hg(c, :) + hitMean_hg(c,:), 'r:');
%         plot(t, -hitSEM_hg(c, :) + hitMean_hg(c,:), 'r:');
        
        plot(t, GaussianSmooth(missMean_hg(c, :), sfac), 'b', 'LineWidth', 2);
%         plot(t,  missSEM_hg(c, :) + missMean_hg(c,:), 'b:');
%         plot(t, -missSEM_hg(c, :) + missMean_hg(c,:), 'b:');
        
        sra = rsas_hg(c, :);
        idx = h_hg(c, :)==1;
        
        plot(t(idx), sra(idx), 'k.', 'MarkerSize', 20);
        plot(t, sra, 'k');
%         plot(t, GaussianSmooth(rsas_hg(c, :), sfac), 'k', 'LineWidth', 2);
        
        ylims = ylim;
        plot([-preDur -preDur], ylims, 'k--');
        plot([0       0      ], ylims, 'k--');
        plot([fbDur   fbDur  ], ylims, 'k--');

        xlabel('time(s)');
        ylabel('feature power (AU) / r^2 (hits vs misses)');
        title('HG differences in \color{red}{hit} vs \color{blue}{miss} trials');
        
        subplot(212);
        
        plot(t, hitMean_beta(c, :), 'r', 'LineWidth', 2); hold on;
%         plot(t, hitSEM_beta(c, :) + hitMean_beta(c,:), 'r:');
%         plot(t, hitSEM_beta(c, :) - hitMean_beta(c,:), 'r:');
         
        plot(t, missMean_beta(c, :), 'b', 'LineWidth', 2);
%         plot(t,  missSEM_beta(c, :) + missMean_beta(c,:), 'b:');
%         plot(t, -missSEM_beta(c, :) + missMean_beta(c,:), 'b:');
        
%         plot(t, rsas_beta(c, :), 'k', 'LineWidth', 2);
        
        sra = rsas_beta(c, :);
        idx = h_beta(c, :)==1;
        
        plot(t(idx), sra(idx), 'k.', 'MarkerSize', 20);
        plot(t, sra, 'k');
        
        ylims = ylim;
        plot([-preDur -preDur], ylims, 'k--');
        plot([0       0      ], ylims, 'k--');
        plot([fbDur   fbDur  ], ylims, 'k--');

        xlabel('time(s)');
        ylabel('feature power (AU) / r^2 (hits vs misses)');
        title('BETA differences in \color{red}{hit} vs \color{blue}{miss} trials');
        
        
        maximize;
        mtit(trodeNameFromMontage(c, Montage), 'xoff', 0, 'yoff', 0.025);
        SaveFig(fullfile(odir, 'figs'), ['raw_' strrep(strrep(trodeNameFromMontage(c, Montage), '(', ''), ')', '')], 'eps');
        pause;
        close;
    end
end



% %% list the interesting electrodes
% 
% % % list = [20 97 98]; % 9ad250
% % list = [7 8 12 16 20 32 54 88]; % fc
% % % list = [2 14 33 37 47 57 58 62 66 85 95 96]; % 4568f4
% % % list = [7 18 19 27 28 35 50 69 79 ]; % 30052b
% 
% list = getElectrodeList(subjid);

% %% plot them all on the talairach brain for comparison of location
% alltrodes = [];
% allvals = [];
% 
% sids = {'9ad250','fc9643','4568f4','30052b'};
% lists = {[20 97 98], ...
%     [8 12 13 16 20 32 56 88], ...
%     [2 33 37 47 57 58 59 62 66 85 95 96], ...
%     [7 14 18 19 27 28 48 50 69 79]};
% 
% for c = 1:length(sids)
%     subjid = sids{c};
%     list = lists{c};
%     
%     load(fullfile(subjid, [subjid '_epochs.mat']), 'Montage');
%     locs = trodeLocsFromMontage(subjid, Montage, true);
%     alltrodes = cat(1, alltrodes, locs(list, :));
%     allvals = cat(1, allvals, c*ones(size(list))');
% end
% 
% PlotDotsDirect('tail', alltrodes, allvals, 'both', [1 4], 20, 'recon_colormap', [], false);
% view(90,0);
% SaveFig(pwd, 'all-r', 'png');
% view(270,0);
% SaveFig(pwd, 'all-l', 'png');
% % todo actually plot on the brain