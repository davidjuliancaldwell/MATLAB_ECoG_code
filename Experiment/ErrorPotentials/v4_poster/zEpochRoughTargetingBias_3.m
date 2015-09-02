% %% collect data
subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';

[~, odir] = filesForSubjid(subjid);
load(fullfile(odir, [subjid '_epochs_clean']));

%% review all epochs
% process on a channel by channel basis

t  = (-itiDur-preDur):1/fs:(fbDur+postDur);
    
tgtCount = extractTargetCountFromFilename(src_files);

ups = (tgtCount == 2) & (tgts == 1)';
downes = (tgtCount == 2) & (tgts == 2)';

up_hg = epochs_hg(:, ups, :);
down_hg = epochs_hg(:, downes, :);

up_beta = epochs_beta(:, ups, :);
down_beta = epochs_beta(:, downes, :);

up_lf = epochs_lf(:, ups, :);
down_lf = epochs_lf(:, downes, :);

% rsas_hg = zeros(size(epochs_hg, 1), length(t));
% rsas_beta = zeros(size(rsas_hg));
% rsas_lf = zeros(size(rsas_hg));
% 
% for c = 1:size(epochs_hg, 1)
%     fprintf('channel %d\n', c);
%   
%     rsas_hg(c, :) = signedSquaredXCorrValue(squeeze(up_hg(c,:,:)), squeeze(down_hg(c,:,:)), 1);
%     rsas_beta(c, :) = signedSquaredXCorrValue(squeeze(up_beta(c,:,:)), squeeze(down_beta(c,:,:)), 1);    
%     rsas_lf(c, :) = signedSquaredXCorrValue(squeeze(up_lf(c,:,:)), squeeze(down_lf(c,:,:)), 1);
% end

[h_hg, ~, ~, stats_hg] = ttest2(up_hg, down_hg, 0.05, 'both', 'unequal', 2);
[h_beta, ~, ~, stats_beta] = ttest2(up_beta, down_beta, 0.05, 'both', 'unequal', 2);
[h_lf, ~, ~, stats_lf] = ttest2(up_lf, down_lf, 0.05, 'both', 'unequal', 2);

h_hg = squeeze(h_hg);
stats_hg.tstat = squeeze(stats_hg.tstat);
h_beta = squeeze(h_beta);
stats_beta.tstat = squeeze(stats_beta.tstat);
h_lf = squeeze(h_lf);
stats_lf.tstat = squeeze(stats_lf.tstat);

upMean_hg = squeeze(mean(up_hg,2));
upSEM_hg = squeeze(sem(up_hg,2));
downMean_hg = squeeze(mean(down_hg,2));
downSEM_hg = squeeze(sem(down_hg,2));

upMean_beta = squeeze(mean(up_beta,2));
upSEM_beta = squeeze(sem(up_beta,2));
downMean_beta = squeeze(mean(down_beta,2));
downSEM_beta = squeeze(sem(down_beta,2));

upMean_lf = squeeze(mean(up_lf,2));
upSEM_lf = squeeze(sem(up_lf,2));
downMean_lf = squeeze(mean(down_lf,2));
downSEM_lf = squeeze(sem(down_lf,2));

[~, odir] = filesForSubjid(subjid);

save(fullfile(odir, [subjid '_tgt_results']), 'upMean_*', 'upSEM_*', ...
    'downMean_*', 'downSEM_*', 'h_*', 'stats_*');
% save(fullfile(odir, [subjid '_results']), 'rsas_*', 'upMean_*', 'upSEM_*', ...
%     'downMean_*', 'downSEM_*', 'h_*', 'stats_*');

%% display one at a time
sfac = 100;

TouchDir(fullfile(odir, 'figs'));

for c = 1:size(epochs_hg, 1)
    if (~ismember(c, bads))
        figure;
        for d = 1:3
            ax1 = subplot(3,1,d);
            
            switch(d)
                case 1
                    upMean = upMean_hg;
                    downMean = downMean_hg;
%                     rsas = rsas_hg;
                    stats = stats_hg;
                    h = h_hg;
                    titleText = 'HG differences in \color{red}{up} vs \color{blue}{down} trials';
                case 2
                    upMean = upMean_beta;
                    downMean = downMean_beta;
%                     rsas = rsas_beta;
                    stats = stats_beta;
                    h = h_beta;
                    titleText = 'Beta differences in \color{red}{up} vs \color{blue}{down} trials';
                case 3
                    upMean = upMean_lf;
                    downMean = downMean_lf;
%                     rsas = rsas_lf;
                    stats = stats_lf;
                    h = h_lf;
                    titleText = 'Low Frequency differences in \color{red}{up} vs \color{blue}{down} trials';
                otherwise
                    error('WHAT!?');
            end
            
            % plot the true version
            plot (t, upMean(c, :), 'Color', [1 .5 .5]);
            hold on;
            plot (t, downMean(c, :), 'Color', [.5 .5 1]);
            
            % plot the smoothed version
            plot (t, GaussianSmooth(upMean(c, :), sfac), 'r', 'LineWidth', 3);
            plot (t, GaussianSmooth(downMean(c, :), sfac), 'b', 'LineWidth', 3);
            ylabel('pwr (AU)');
            axis tight;
            
            % on a different axis plot the tstats            
            ax2 = axes('Position',get(ax1,'Position'),...
                'YAxisLocation','right',...
                'Color','none',...
                'XColor','k','YColor','k');
%             axis off;
            
            tstats = stats.tstat(c, :);
            hold on;
%             plot(t, tstats, 'k', 'Parent', ax2);
            
            idx = h(c, :)==1;
            plot(t(idx), tstats(idx), 'k.', 'MarkerSize', 10, 'Parent', ax2);
        
            set(ax2, 'xlim', get(ax1, 'xlim'));
            set(ax2, 'XTick', []);
            
            vline(-preDur, 'k--');
            vline(0, 'k--');
            vline(fbDur, 'k--');

            xlabel('time(s)');
            ylabel('t-stat');
            title(titleText);
        end    
        
        % save the figure
        maximize;
        mtit(trodeNameFromMontage(c, Montage), 'xoff', 0, 'yoff', 0.025);
        SaveFig(fullfile(odir, 'figs'), ['tgt_raw_' strrep(strrep(trodeNameFromMontage(c, Montage), '(', ''), ')', '')], 'png');
%         pause;
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