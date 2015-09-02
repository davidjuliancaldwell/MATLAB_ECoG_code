% subjid = 'fc9643';
% subjid = '38e116';
% subjid = '4568f4';
% subjid = '30052b';
subjid = '9ad250';

[~, odir] = filesForSubjid(subjid);

%% load data
load(fullfile(odir, [subjid '_epochs_clean.mat']), 'epochs_hg');
load(fullfile(odir, 'significant_clusters.mat'), 'clusterChans_hg', 'allClusters_hg');

%% generate feature values for all epochs
clusterChans_hg = clusterChans_hg(1:length(allClusters_hg));
nepochs = epochs_hg(clusterChans_hg==1, :, :);
allClusters_hg(clusterChans_hg==0) = [];

delays = 0:50:950;
feats = zeros(size(nepochs, 1), size(nepochs, 2), length(delays));

for c = 1:length(allClusters_hg)
    cc = allClusters_hg{c};
    
    res = [];
    for d = 1:length(cc)
        res = union(res, cc{d}(2,:));
    end
   
    for d = 1:length(delays)
        temp_res = res(res < 3000 + delays(d));
        feats(c, :, d) = squeeze(sum(nepochs(c,:,temp_res), 3));
    end
%     feats(c, :) = squeeze(sum(nepochs(c, :, res), 3));
end

save(fullfile(odir, 'featsb.mat'), 'feats', 'delays');