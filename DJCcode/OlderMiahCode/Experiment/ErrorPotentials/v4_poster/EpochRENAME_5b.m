%% this script selects which electrodes are meaningful for future classification analyses
subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% % % no longer being used % subjid = '9ad250';
% subjid = '38e116';

[~, odir] = filesForSubjid(subjid);
% load the relevant data
load(fullfile(odir, [subjid '_epochs_clean']), 't', 'tgts', 'ress', 'Montage', 'epochs*');
%% select two simple features, the 500 ms leading up to the end of a trial and the 500 ms immediately following.
clearvars -except subjid epochs* t Montage tgts ress odir

hits = tgts==ress;
misses = tgts~=ress;

featStart = 2.5;
featStop = 3;

nchans = size(epochs_hg, 1);
locs = trodeLocsFromMontage(subjid, Montage, false);

feats_beta = mean(epochs_beta(:,:,t > featStart & t < featStop),3);
feats_hg = mean(epochs_hg(:,:,t > featStart & t < featStop),3);
feats_lf = mean(epochs_lf(:,:,t > featStart & t < featStop),3);

[hs_beta, ts_beta, ~, stats_beta] = ttest2(feats_beta(:, hits), feats_beta(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);
[hs_hg, ps_hg, ~, stats_hg] = ttest2(feats_hg(:,hits), feats_hg(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);
[hs_lf, ps_lf, ~, stats_lf] = ttest2(feats_lf(:,hits), feats_lf(:, ~hits), 'Dim', 2, 'Alpha', 0.05/nchans);

% [hs_beta, ts_beta, ~, stats_beta] = ttest2(feats_beta(:, hits), feats_beta(:, ~hits), 'Dim', 2, 'Alpha', 0.05);
% [hs_hg, ps_hg, ~, stats_hg] = ttest2(feats_hg(:,hits), feats_hg(:, ~hits), 'Dim', 2, 'Alpha', 0.05);
% [hs_lf, ps_lf, ~, stats_lf] = ttest2(feats_lf(:,hits), feats_lf(:, ~hits), 'Dim', 2, 'Alpha', 0.05);

load('recon_colormap');

figure
ts = stats_hg.tstat;
ts(hs_hg == 0) = NaN;
PlotDotsDirect(subjid, locs, ts, 'r', [-10 10], 10, 'recon_colormap');
title('hg sigs');
colormap(cm);
colorbar;

figure
ts = stats_beta.tstat;
ts(hs_beta == 0) = NaN;
PlotDotsDirect(subjid, locs, ts, 'r', [-10 10], 10, 'recon_colormap');
title('beta sigs');
colormap(cm);
colorbar;

figure
ts = stats_lf.tstat;
ts(hs_lf == 0) = NaN;
PlotDotsDirect(subjid, locs, ts, 'r', [-10 10], 10, 'recon_colormap');
title('lf sigs');
colormap(cm);
colorbar;
% 
% %% a simple classification
% 
% feats = [feats_hg(hs_hg == 1, :); feats_beta(hs_beta == 1, :); feats_lf(hs_lf == 1, :)];
% nFoldCrossValidation(feats', hits, 10)

%% a slightly more complicated classification

idxs = find(hs_hg == 1);
feats = [];

for idx = idxs(1:3)'
    fprintf('performing pc on %d of %d\n', find(idx==idxs), length(idxs));
    [mFeats, pcs] = projectOnPCs(squeeze(epochs_hg(idx, :, :)), 3);
    feats = cat(2, feats, mFeats);
end

acc = nFoldCrossValidation(feats, hits, 10)
plot(t,pcs);

%% 
X = feats;
y = misses;

idxs = randperm(size(X,1));
idxs = idxs(1:floor(end/2));

trainX = X(idxs, :);
testX = X;
testX(idxs, :) = [];

trainY = y(idxs);
testY = y;
testY(idxs) = [];

model = logregFitBayes(trainX, trainY);
[yhat, prob] = logregPredictBayes(model, testX);
% figure;
% plot(X(:,1), jitter(y,.1), 'ko', 'linewidth', 2, 'MarkerSize', 4, 'markerfacecolor', 'k');
% hold on
% plot(X(:,1), prob, 'ro', 'linewidth', 2,'MarkerSize', 10)
% for i=1:size(X,1)
%   line([X(i,1) X(i,1)], [pCI(i,1) pCI(i,2)]);
% end

% ROC
figure;
[mx, my, ~, AUC] = perfcurve(testY, prob, true)
plot(mx, my); title(sprintf('AUC = %1.3f', AUC));

% %% this script selects which electrodes are meaningful for future classification analyses
% 
% subjid = 'fc9643';
% [~, odir] = filesForSubjid(subjid);
% 
% %% load data
% load(fullfile(odir, [subjid '_decomp.mat']), 'tgts', 'ress', 'fw' , 't', 'Montage', 'bads');
% 
% %% analyze each channel
% 
% for chan = 1:max(cumsum(Montage.Montage))
%     if (~ismember(chan, bads))
%         % load in channel data
%         fprintf('loading channel data: %d\n', chan);
%         load(fullfile(odir, 'chan', [num2str(chan) '.mat']));
%         dca = abs(decompAll);
% 
%         % perform t-test of hit vs missed trials
%         fprintf('perfoming t-test...');
%         tic
%         [h,p,~,stats] = ttest2(squeeze(dca(:,:,ress==tgts)), squeeze(dca(:,:,ress~=tgts)), 0.05, 'both', 'unequal', 3);
%         [tvals, clusters] = findClusterStats(h, stats.tstat);
%         toc
% 
%         % calculate rsa values for hit vs missed trials
%         fprintf('performing rsas...');
%         tic
%         rsas = zeros(size(p));
%         for c = 1:length(fw)
%             rsas(:,c) = signedSquaredXCorrValue(squeeze(dca(:,c,ress==tgts)), squeeze(dca(:,c,ress~=tgts)), 2);
%         end
%         toc
% 
%         % load results from monte-carlo randomization
%         load(fullfile(odir, 'stats', [num2str(chan) '.mat']));
% 
%         % determine significant clusters from original statistical test
%         p_targ = 0.0001;
%         off = floor(size(alltvals, 2)*(p_targ/2));
% 
%         sortedTVals = sort(alltvals);
% 
%         lb = sortedTVals(off);
%         ub = sortedTVals(end-off);
% 
%         keepers = tvals < lb | tvals > ub;
% 
%         cClusters = clusters(keepers);
%         cTvals = tvals(keepers);
% 
%         mask = zeros(size(p));
% 
%         if (~isempty(cClusters))
%             fprintf('significant clusters found: %d\n', length(cClusters));
% 
%             for c = 1:length(cClusters)
%                 cc = cClusters{c};
% 
%                 for d = 1:size(cc,1)
%                     mask(cc(d,1), cc(d,2)) = 1;
%                 end
%             end
% 
%             figure;
%             imagesc(t, fw, (rsas .* mask)');
%             m = max(max(abs(rsas)));
%             set_colormap_threshold(gca, [-0.01*m 0.01*m], [-m m], [1 1 1]); 
%             % load('recon_colormap');
%             % colormap(cm);
%             % set(gca, 'CLim', [-m m]);
%             colorbar;
%             title(sprintf('R^2 of hits vs. misses: %s', trodeNameFromMontage(chan, Montage)));
%             xlabel('time (s)');
%             ylabel('frequency (Hz)');
% 
%             axis xy;    
% 
%             SaveFig(fullfile(odir, 'fig'), [num2str(chan) '.eps'], 'eps');
% 
%             close;
%             
%             clusterChans(chan) = 1;
%             allClusters{chan} = cClusters;
%             masks{chan} = mask;
%             allRsas{chan} = rsas;
%         else
%             fprintf('no clusters found\n');
%             clusterChans(chan) = 0;
%             allClusters{chan} = {};
%             masks{chan} = {};
%             allRsas{chan} = {};
%         end
%     end
% end
% 
% save(fullfile(odir, 'significant_clusters.mat'), 'clusterChans', 'allClusters', 'masks', 'allRsas', 'p_targ');