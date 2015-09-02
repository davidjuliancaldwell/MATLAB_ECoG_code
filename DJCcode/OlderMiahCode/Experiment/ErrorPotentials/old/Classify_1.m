% for a given subject id and list of electrodes to use, this script will do
% N-fold validation of hit vs miss classification
subjid = 'fc9643';
list = [7 8 12 16 20 32 54 88]; % fc


% %% step one
% % let's look at the data and see if we can tell hits from misses
% 
% figure;
% 
% load(fullfile(subjid, [subjid '_decomp']), 'tgts', 'ress', 't', 'fw');
% 
% for idx = 1%:length(list)
%     chan = list(idx);
%     
%     load(fullfile(subjid, 'chan', num2str(chan)));
%     
%     for d = 1:size(decompAll, 3)
%         f = squeeze(abs(decompAll(:,:,d)))';
%         fn = normalize_plv(f, f);
%         imagesc(fn);
%         colorbar;
%         set_colormap_threshold(gca, [-2 2], [-7 7], [1 1 1]);
%         axis xy;
%         title(sprintf('trial %d (%d)', d, tgts(d)==ress(d)));
%         pause;
%     end
% end

% %% step two
% % let's take HG activity in a single channel in the 500 samples at the end
% % of the trial, and the 500 samples before that
% f = squeeze(mean(abs(decompAll(:, fw > 70, :)), 2));
% clear ef
% % ef(:, 1) = squeeze(mean(f(t > 2 & t < 3, :), 1));
% ef(:, 1) = squeeze(mean(f(t > 3 & t < 3.90, :), 1));
% 
% % ef(:, 1) = squeeze(mean(f(t > 2 & t < 2.5, :), 1));
% % ef(:, 2) = squeeze(mean(f(t > 3 & t < 3.50, :), 1));
% % ef(:, 3) = squeeze(mean(f(t > 2.5 & t < 3, :), 1));
% % ef(:, 4) = squeeze(mean(f(t > 3.5 & t < 3.90, :), 1));
% 
% % gscatter(ef(1,:), ef(2,:), tgts==ress);
% 
% labels = {};
% 
% for c = 1:length(tgts)
%     if (tgts(c)==ress(c))
%         labels{c} = 'h';
%     else
%         labels{c} = 'm';
%     end
% end
% 
% class = classify(ef(401:end, :), ef(1:400, :), labels(1:400), 'linear', [sum(strcmp(labels(1:400), 'h')), sum(strcmp(labels(1:400), 'm'))]);
% 
% ct = 0;
% tot = 0;
% 
% for c = 1:length(class)
%     if (labels{c+400} == class{c})
%         ct = ct + 1;
%     end
%     tot = tot + 1;
% end
% 
% ct
% tot
% 
% ct/tot
% 
% % hr = squeeze(mean(abs(decompAll(:,fw > 70, ress == tgts)), 2));
% % mr = squeeze(mean(abs(decompAll(:,fw > 70, ress ~= tgts)), 2));
% 
% % figure,
% % imagesc(normalize_plv(hr', hr(t<2,:)')); axis xy;
% % figure,
% % imagesc(normalize_plv(mr', mr(t<2,:)')); axis xy;

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
    accs_std(count) = std(sub_accs);
end

errorbar(1:length(list), accs_mu, accs_std);

