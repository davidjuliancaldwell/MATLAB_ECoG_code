clear

% for a given subject id and list of electrodes to use, this script will do
% N-fold validation of hit vs miss classification
% subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
subjid = '38e116';
[~, odir] = filesForSubjid(subjid);

load(fullfile(odir, [subjid '_epochs_clean.mat']), 'tgts', 'ress');
load(fullfile(odir, 'significant_clusters.mat'), 'clusterChans_hg', 'allClusters_hg');
load(fullfile(odir, 'featsb'), 'feats', 'delays');

%% now run through all of the permutations of channels, comparing
% classification accuracy

list = find(clusterChans_hg==1);

accs = [];

for c = 1:length(delays)
	fprintf('working on including features up to %d ms beyond the end of the trial\n', delays(c));
	
	% some code here to select the feats
    sub_feats = squeeze(feats(:,:,c));
    bads = mode(sub_feats')==0;
    sub_feats(bads, :) = [];
    
	accs(c)= nFoldCrossValidation(sub_feats', tgts==ress, 5);
end

save(fullfile(odir, [subjid '_timetradeoff']), 'accs', 'delays', 'list');

% errorbar((1:length(list))+.15, accs_mu, accs_std, 'k');

