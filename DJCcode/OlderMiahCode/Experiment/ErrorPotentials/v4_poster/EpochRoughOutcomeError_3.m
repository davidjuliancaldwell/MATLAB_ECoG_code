% %% collect data
subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';

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

% hit_beta = epochs_beta(:, hits, :);
% miss_beta = epochs_beta(:, misses, :);

hit_lf = epochs_lf(:, hits, :);
miss_lf = epochs_lf(:, misses, :);

% rsas_hg = zeros(size(epochs_hg, 1), length(t));
% rsas_beta = zeros(size(rsas_hg));
% rsas_lf = zeros(size(rsas_hg));
% 
% for c = 1:size(epochs_hg, 1)
%     fprintf('channel %d\n', c);
%   
%     rsas_hg(c, :) = signedSquaredXCorrValue(squeeze(hit_hg(c,:,:)), squeeze(miss_hg(c,:,:)), 1);
%     rsas_beta(c, :) = signedSquaredXCorrValue(squeeze(hit_beta(c,:,:)), squeeze(miss_beta(c,:,:)), 1);    
%     rsas_lf(c, :) = signedSquaredXCorrValue(squeeze(hit_lf(c,:,:)), squeeze(miss_lf(c,:,:)), 1);
% end

[h_hg, p_hg, ~, stats_hg] = ttest2(hit_hg, miss_hg, 0.05, 'both', 'unequal', 2);
% [h_beta, ~, ~, stats_beta] = ttest2(hit_beta, miss_beta, 0.05, 'both', 'unequal', 2);
[h_lf, p_beta, ~, stats_lf] = ttest2(hit_lf, miss_lf, 0.05, 'both', 'unequal', 2);

h_hg = squeeze(h_hg);
stats_hg.tstat = squeeze(stats_hg.tstat);
% h_beta = squeeze(h_beta);
% stats_beta.tstat = squeeze(stats_beta.tstat);
h_lf = squeeze(h_lf);
stats_lf.tstat = squeeze(stats_lf.tstat);

hitMean_hg = squeeze(mean(hit_hg,2));
hitSEM_hg = squeeze(sem(hit_hg,2));
missMean_hg = squeeze(mean(miss_hg,2));
missSEM_hg = squeeze(sem(miss_hg,2));

% hitMean_beta = squeeze(mean(hit_beta,2));
% hitSEM_beta = squeeze(sem(hit_beta,2));
% missMean_beta = squeeze(mean(miss_beta,2));
% missSEM_beta = squeeze(sem(miss_beta,2));

hitMean_lf = squeeze(mean(hit_lf,2));
hitSEM_lf = squeeze(sem(hit_lf,2));
missMean_lf = squeeze(mean(miss_lf,2));
missSEM_lf = squeeze(sem(miss_lf,2));

[~, odir] = filesForSubjid(subjid);

save(fullfile(odir, [subjid '_results']), 'hitMean_*', 'hitSEM_*', ...
    'missMean_*', 'missSEM_*', 'h_*', 'stats_*');
% save(fullfile(odir, [subjid '_results']), 'rsas_*', 'hitMean_*', 'hitSEM_*', ...
%     'missMean_*', 'missSEM_*', 'h_*', 'stats_*');

%% display one at a time
sfac = 100;

TouchDir(fullfile(odir, 'figs'));

for c = 1:size(epochs_hg, 1)
    if (~ismember(c, bads))
        figure;
        for d = 1:2
            ax1 = subplot(2,1,d);
            
            switch(d)
                case 1
                    hitMean = hitMean_hg;
                    missMean = missMean_hg;
%                     rsas = rsas_hg;
                    stats = stats_hg;
                    h = h_hg;
                    titleText = 'HG differences in \color{red}{hit} vs \color{blue}{miss} trials';
                    yLabelText = '\gamma';
                case 2
%                     hitMean = hitMean_beta;
%                     missMean = missMean_beta;
% %                     rsas = rsas_beta;
%                     stats = stats_beta;
%                     h = h_beta;
%                     titleText = 'Beta differences in \color{red}{hit} vs \color{blue}{miss} trials';
%                     yLabelText = '\beta';
%                 case 3
                    hitMean = hitMean_lf;
                    missMean = missMean_lf;
%                     rsas = rsas_lf;
                    stats = stats_lf;
                    h = h_lf;
                    titleText = 'Low Frequency differences in \color{red}{hit} vs \color{blue}{miss} trials';
                    yLabelText = 'LF';
                otherwise
                    error('WHAT!?');
            end
            
            % plot the true version
            plot (t, hitMean(c, :), 'Color', [1 .5 .5]);
            hold on;
            plot (t, missMean(c, :), 'Color', [.5 .5 1]);
            
            set(gca, 'FontSize', 14);
            set(gca, 'XTick', []);
%             set(gca, 'YTick', []);
            % plot the smoothed version
            plot (t, GaussianSmooth(hitMean(c, :), sfac), 'r', 'LineWidth', 3);
            plot (t, GaussianSmooth(missMean(c, :), sfac), 'b', 'LineWidth', 3);
            ylabel(sprintf('%s (Z)', yLabelText), 'FontSize', 18);
            axis tight;
            
%             % on a different axis plot the tstats            
%             ax2 = axes('Position',get(ax1,'Position'),...
%                 'YAxisLocation','right',...
%                 'Color','none',...
%                 'XColor','k','YColor','k', 'FontSize', 14);
% %             axis off;
%             
%             tstats = stats.tstat(c, :);
%             hold on;
% %             plot(t, tstats, 'k', 'Parent', ax2);
%             
%             idx = h(c, :)==1;
%             plot(t(idx), tstats(idx), 'k.', 'MarkerSize', 10, 'Parent', ax2);
%         
%             set(ax2, 'xlim', get(ax1, 'xlim'));
%             set(ax2, 'XTick', []);
            
            vline(-preDur, 'k--');
            vline(0, 'k--');
            vline(fbDur, 'k--');

%             xlabel('time(s)', 'FontSize', 18);
%             ylabel('t-stat', 'FontSize', 18);
%             title(titleText, 'FontSize', 18);
            
            if (d == 1)
                title('Band power differences in \color{red}{hit} vs \color{blue}{miss} trials', 'FontSize', 18);
            elseif (d == 2)
                xlabel('time(s)', 'FontSize', 18);
                set(gca, 'XTick', [-3 -2 -1 0 1 2 3 4]);
            end
                
        end    
        
        % save the figure
%         maximize;
%         mtit(trodeNameFromMontage(c, Montage), 'xoff', 0, 'yoff', 0.025, 'FontSize', 18);
        pos = get(gcf, 'Position');
        set(gcf, 'Position', [pos(1) pos(2) round(pos(3)*2) pos(4)]);
        
%         SaveFig(fullfile(odir, 'figs'), ['raw_' strrep(strrep(trodeNameFromMontage(c, Montage), '(', ''), ')', '')], 'png');
        SaveFig(fullfile(odir, 'figs'), ['raw_' strrep(strrep(trodeNameFromMontage(c, Montage), '(', ''), ')', '')], 'eps', '-r300');%         pause;
%         saveas(gcf, fullfile(odir, 'figs', ['raw_' strrep(strrep(trodeNameFromMontage(c, Montage), '(', ''), ')', '') '.eps']), 'psc2')
        
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