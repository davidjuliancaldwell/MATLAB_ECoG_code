% % %% collect data
% subjid = 'fc9643';
% % subjid = '4568f4';
% % subjid = '30052b';
% % subjid = '9ad250';
% % subjid = '38e116';
% 
[~, odir, hemi, bads] = filesForSubjid(subjid);
load(fullfile(odir, [subjid '_epochs_clean']), 'tgts', 'ress', 'epochs_hg', 'epochs_lf', 'Montage', 't');
load(fullfile(odir, [subjid '_features']), 'rehs*', 'prehs*', 'restats*', 'prestats*', 'locst');

%% we are now going to subdivide the features in to 100ms chunks, so there will be 5 predictive and 5 reactive features as follows:
% pre feats:
%  2.5s < t < 2.6s
%  2.5s < t < 2.7s
%  2.5s < t < 2.8s
%  2.5s < t < 2.9s
%  2.5s < t < 3.0s
% re feats
%  3.0s < t < 3.1s
%  3.0s < t < 3.2s
%  3.0s < t < 3.3s
%  3.0s < t < 3.4s
%  3.0s < t < 3.5s

preStartTime = 2.5;
preEndTimes = 2.6:.1:3.0;

reStartTime = 3.0;
reEndTimes = 3.1:.1:3.5;

divPreHGFeats = zeros(length(preEndTimes), sum(prehs_hg==1), size(epochs_hg, 2));
divPreLFFeats = zeros(length(preEndTimes), sum(prehs_lf==1), size(epochs_lf, 2));
divReHGFeats  = zeros(length( reEndTimes), sum( rehs_hg==1), size(epochs_hg, 2));
divReLFFeats  = zeros(length( reEndTimes), sum( rehs_lf==1), size(epochs_lf, 2));

for c = 1:length(preEndTimes)
    divPreHGFeats(c, :, :) = mean(epochs_hg(prehs_hg==1, :, t > preStartTime & t < preEndTimes(c)), 3);
    divPreLFFeats(c, :, :) = mean(epochs_lf(prehs_lf==1, :, t > preStartTime & t < preEndTimes(c)), 3);
end

for c = 1:length(reEndTimes)
    divReHGFeats(c, :, :) = mean(epochs_hg(rehs_hg==1, :, t > reStartTime & t < reEndTimes(c)), 3);
    divReLFFeats(c, :, :) = mean(epochs_lf(rehs_lf==1, :, t > reStartTime & t < reEndTimes(c)), 3);
end

save(fullfile(odir, 'time_versus_acc_feats'), 'preStartTime', 'preEndTimes', 'reStartTime', 'reEndTimes', 'div*');
