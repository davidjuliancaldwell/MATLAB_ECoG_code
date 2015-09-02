% for a given subject id and list of electrodes to use, this script will do
% N-fold validation of hit vs miss classification
% subjid = 'fc9643';
% subjid = '4568f4';
% subjid = '30052b';
subjid = '9ad250';

list = getElectrodeList(subjid);
% %% step 3 actually take an earnest stab at multi electrode classification
% 
% load(fullfile(subjid, [subjid '_decomp']), 'tgts', 'ress', 't', 'fw');
% 
% % start by building the features for the channels of interest
% for idx = 1:length(list)
%     chan = list(idx);
%     
%     load(fullfile(subjid, 'chan', num2str(chan)));
%     f = squeeze(mean(abs(decompAll(:, fw > 70, :)), 2));
%     feats(:, idx) = squeeze(mean(f(t > 3 & t < 3.9, :), 1));
% end
% 
% save(fullfile(subjid, [subjid '_feats']), 'feats');

%% now run through all of the permutations of channels, comparing
% classification accuracy

load(fullfile(subjid, [subjid '_feats']), 'feats');
load(fullfile(subjid, [subjid '_decomp']), 'tgts', 'ress');

clear accs_mu accs_std;

for count = 1:length(list)
    fprintf('working on combinations of %d features\n', count);
    combs = nchoosek(1:length(list), count);
     
    clear sub_accs; idx = 0;
    for comb = combs'
        idx = idx + 1;
        sub_feats = feats(:, comb);
        sub_accs(idx) = nFoldCrossValidation(sub_feats, tgts == ress, 5);
    end
     
    accs_mu(count) = mean(sub_accs);
    accs_std(count) = sem(sub_accs, 2);
end

save(fullfile(subjid, [subjid '_class']), 'accs_mu', 'accs_std', 'list');

% errorbar((1:length(list))+.15, accs_mu, accs_std, 'k');

