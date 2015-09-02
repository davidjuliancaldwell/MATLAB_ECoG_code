%% define constants
addpath ./functions
Z_Constants;

%%
alllocs = [];
allweights = [];
allsources = [];

for c = 1:length(SIDS)
    subjid = SIDS{c};
    subcode = SUBCODES{c};

    %% load in data and get set up
    fprintf ('processing %s: \n', subcode);
    
    load(fullfile(META_DIR, sprintf('%s-epochs.mat', subjid)), 'fs', 'cchan', 'hemi', 'montage', 'bad_channels', 'targets');    
    load(fullfile(META_DIR, ['regression ' subjid '.mat']), 'ts', 'fits', 'included', 'srcs', 'residuals', 'ys');

    %% get all the trial data
    L = max(arrayfun(@(x) sum(srcs==x), unique(srcs)));
    
    trials = nan(size(residuals, 2), L, length(targets));
    rtrials = nan(size(residuals, 2), L, length(targets));
    
    for tr = unique(srcs)'
        idxs = find(srcs==tr);            
        trials(:, 1:length(idxs), tr) = ys(idxs, :)';
        rtrials(:, 1:length(idxs), tr) = residuals(idxs, :)';
    end
    
    %%
    [nx, ny] = subplotDims(size(residuals, 2));
    t = (1:L)/fs;

    predictors = reshape(trials(:, t <= 1, :), size(trials, 1)*sum(t<=1), size(trials, 3));
    outcomes = ismember(targets, UP);
    [accs, ~, ~, estimates, posteriors] = mTrainValTestSVM(predictors, outcomes, ceil(map ((1:length(outcomes)), 1, length(outcomes), 1/length(outcomes), 5)), []);
    mean(toRow(estimates) == toRow(outcomes))
%     figure
%     for ch = 1:size(residuals, 2)
%         if (~ismember(ch, bad_channels))
%             subplot(nx, ny, ch);
%             
%             data = squeeze(trials(ch,:,:));
%             rdata = squeeze(rtrials(ch,:,:));
%                         
% %             plot(t, nanmean(data')-mean(nanmean(data')));
% %             hold all;
% %             plot(t, nanmean(rdata'));
% %             xlim([min(t) max(t)]);
%             
%             prettyline(t, data, ismember(targets, UP), 'br');            
%             vline(1);
%             
%             % ask whether there is a transient response
%             pres = nanmean(rdata(t > 0 & t <= 1.0, :));
%             posts = nanmean(rdata(t > 1.0, :));
%             
%             [hasERP, p] = ttest2(pres, posts, 'tail', 'right', 'alpha', 0.05 / size(residuals, 2));
%             
%             if (ch==cchan)
%                 title(num2str(ch), 'color', [0 0 1]);
%             elseif (hasERP)
%                 title(num2str(ch), 'color', [1 0 0]);
%             else
%                 title(num2str(ch), 'color', [0 0 0]);
%             end
%         end
%     end    
end
