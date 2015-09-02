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

[~,~,par] = load_bcidat(src_files{1});
if (par.SamplingRate.NumericValue == 2400)
    sbs = par.SampleBlockSize.NumericValue / 4;
else
    sbs = par.SampleBlockSize.NumericValue / 2;
end

fbstart = find(t==0)+1;
fbend = find(t==fbDur);
ypaths = squeeze(paths(2,:,:));

t_temp = 1:sbs:size(ypaths,2);
ypaths = interp1(t_temp, ypaths(:,t_temp)', 1:size(ypaths, 2))';

tgtCount = extractTargetCountFromFilename(src_files);
[hasExeError, exeErrorIndex] = identifyExecutionErrors(ypaths, tgts, tgtCount);

exeErrorIndex(isnan(exeErrorIndex)) = [];

errorTrials = find(hasExeError == 1);
goodTrials = find((hasExeError ~= 1)' & tgtCount == 2); % temporary

% collect the epochs of interest
goodTrialIndex = randi(fbend-fbstart+1, length(goodTrials))+fbstart;
prewin = 250;
postwin = 500;
t = -prewin:postwin;

good_hg = zeros(size(epochs_hg, 1), length(goodTrials), prewin+postwin+1);
good_beta = zeros(size(epochs_hg, 1), length(goodTrials), prewin+postwin+1);
good_lf = zeros(size(epochs_hg, 1), length(goodTrials), prewin+postwin+1);

error_hg = zeros(size(epochs_hg, 1), length(errorTrials), prewin+postwin+1);
error_beta = zeros(size(epochs_hg, 1), length(errorTrials), prewin+postwin+1);
error_lf = zeros(size(epochs_hg, 1), length(errorTrials), prewin+postwin+1);

for c = 1:length(goodTrials)
    range = (goodTrialIndex(c)-prewin):(goodTrialIndex(c)+postwin);
    good_hg(:,c,:) = epochs_hg(:, goodTrials(c), range);
    good_beta(:,c,:) = epochs_beta(:, goodTrials(c), range);
    good_lf(:,c,:) = epochs_lf(:, goodTrials(c), range);
end

for c = 1:length(errorTrials)
    range = (exeErrorIndex(c)-prewin):(exeErrorIndex(c)+postwin);
    error_hg(:,c,:) = epochs_hg(:, errorTrials(c), range);
    error_beta(:,c,:) = epochs_beta(:, errorTrials(c), range);
    error_lf(:,c,:) = epochs_lf(:, errorTrials(c), range);
end

[h_hg, ~, ~, stats_hg] = ttest2(good_hg, error_hg, 0.05, 'both', 'unequal', 2);
[h_beta, ~, ~, stats_beta] = ttest2(good_beta, error_beta, 0.05, 'both', 'unequal', 2);
[h_lf, ~, ~, stats_lf] = ttest2(good_lf, error_lf, 0.05, 'both', 'unequal', 2);

h_hg = squeeze(h_hg);
stats_hg.tstat = squeeze(stats_hg.tstat);
h_beta = squeeze(h_beta);
stats_beta.tstat = squeeze(stats_beta.tstat);
h_lf = squeeze(h_lf);
stats_lf.tstat = squeeze(stats_lf.tstat);

goodMean_hg = squeeze(mean(good_hg,2));
goodSEM_hg = squeeze(sem(good_hg,2));
errorMean_hg = squeeze(mean(error_hg,2));
errorSEM_hg = squeeze(sem(error_hg,2));

goodMean_beta = squeeze(mean(good_beta,2));
goodSEM_beta = squeeze(sem(good_beta,2));
errorMean_beta = squeeze(mean(error_beta,2));
errorSEM_beta = squeeze(sem(error_beta,2));

goodMean_lf = squeeze(mean(good_lf,2));
goodSEM_lf = squeeze(sem(good_lf,2));
errorMean_lf = squeeze(mean(error_lf,2));
errorSEM_lf = squeeze(sem(error_lf,2));

[~, odir] = filesForSubjid(subjid);

save(fullfile(odir, [subjid 'exe_error_results']), 'goodMean_*', 'goodSEM_*', ...
    'errorMean_*', 'errorSEM_*', 'h_*', 'stats_*');
% save(fullfile(odir, [subjid '_results']), 'rsas_*', 'goodMean_*', 'goodSEM_*', ...
%     'errorMean_*', 'errorSEM_*', 'h_*', 'stats_*');

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
                    goodMean = goodMean_hg;
                    errorMean = errorMean_hg;
%                     rsas = rsas_hg;
                    stats = stats_hg;
                    h = h_hg;
                    titleText = 'HG differences in \color{red}{good} vs \color{blue}{error} trials';
                case 2
                    goodMean = goodMean_beta;
                    errorMean = errorMean_beta;
%                     rsas = rsas_beta;
                    stats = stats_beta;
                    h = h_beta;
                    titleText = 'Beta differences in \color{red}{good} vs \color{blue}{error} trials';
                case 3
                    goodMean = goodMean_lf;
                    errorMean = errorMean_lf;
%                     rsas = rsas_lf;
                    stats = stats_lf;
                    h = h_lf;
                    titleText = 'Low Frequency differences in \color{red}{good} vs \color{blue}{error} trials';
                otherwise
                    error('WHAT!?');
            end
            
            % plot the true version
            plot (t, goodMean(c, :), 'Color', [1 .5 .5]);
            hold on;
            plot (t, errorMean(c, :), 'Color', [.5 .5 1]);
            
            % plot the smoothed version
            plot (t, GaussianSmooth(goodMean(c, :), sfac), 'r', 'LineWidth', 3);
            plot (t, GaussianSmooth(errorMean(c, :), sfac), 'b', 'LineWidth', 3);
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
            
%             vline(0, 'k--');

            xlabel('time(s)');
            ylabel('t-stat');
            title(titleText);
        end    
        
        % save the figure
        maximize;
        mtit(trodeNameFromMontage(c, Montage), 'xoff', 0, 'yoff', 0.025);
        SaveFig(fullfile(odir, 'figs'), ['exe_raw_' strrep(strrep(trodeNameFromMontage(c, Montage), '(', ''), ')', '')], 'png');
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