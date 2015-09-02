clear

% for a given subject id and list of electrodes to use, this script will do
% N-fold validation of hit vs miss classification
% subjid = 'fc9643';
subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';
[~, odir] = filesForSubjid(subjid);

load(fullfile(odir, [subjid '_epochs_clean.mat']), 'tgts', 'ress');
load(fullfile(odir, 'significant_clusters.mat'), 'clusterChans_hg', 'allClusters_hg');
load(fullfile(odir, 'feats'), 'feats');

%% now run through all of the permutations of channels, comparing
% classification accuracy

list = find(clusterChans_hg==1);

% if (strcmp(subjid, '4568f4'))
%     list = list(list <= 64);
% end

accs_mu = [];
accs_std = [];

% list = list(1:min(5, length(list)));

for count = 1:length(list)
    fprintf('working on combinations of %d features\n', count);
    combs = nchoosek(1:length(list), count);
    
    if (size(combs, 1) > 100)
        idx = randi(size(combs,1),100,1);
        combs = combs(unique(idx), :);
    end
    
    clear sub_accs; idx = 0;
    for comb = combs'
        idx = idx + 1;
        sub_feats = feats(comb, :);
        sub_accs(idx) = nFoldCrossValidation(sub_feats', tgts == ress, 5);
    end
     
    accs_mu(count) = mean(sub_accs);
    accs_std(count) = sem(sub_accs, 2);
end

save(fullfile(odir, [subjid '_class']), 'accs_mu', 'accs_std', 'list');

% errorbar((1:length(list))+.15, accs_mu, accs_std, 'k');

