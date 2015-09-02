%% so what's the idea here?
% we want to use all of the features to classify errors
% we want to know our predictive and reactive capability to detect errors
%    as a function of feature count
%    as a function of frequency info used
% we want AUC's for pH pL pBoth rH rL rBoth
%  Question: separately include predictive and reactive?

% eventually we will probably want to run this on all subjects at once
% clean

% subjid = 'fc9643'; subcode = 'S1';
% subjid = '4568f4'; subcode = 'S2'; % why are the ROC's reversed?
% subjid = '30052b'; subcode = 'S3';
% subjid = '9ad250'; subcode = 'S4';
subjid = '38e116'; subcode = 'S5';

[~, odir, ~, bads] = filesForSubjid(subjid);
load(fullfile(odir, [subjid '_features']), 're*', 'pre*', 'locs*', 'hits', 'misses');

% [nansum(prehs_hg) nansum(prehs_lf) nansum(rehs_hg) nansum(rehs_lf)]
% return

% %% equalize the prior
% while(mean(misses) < .5)
%     poss = find(misses==0);
%     idx = poss(randi(length(poss)));
%     
%     preFeats_hg(:,idx) = [];
%     preFeats_lf(:,idx) = [];
%      reFeats_hg(:,idx) = [];
%      reFeats_lf(:,idx) = [];
%     
%     misses(idx) = [];
% end

%% predictive and reactive classification accuracy as a function of feature count?
% one figure for predictive
% one figure for reactive
% one figure for cumulative
% each figure contains 3 curves, HG, LF, both

acc = [];
mx = [];
my = [];
aucs = [];
sens = [];
spec = [];

for c = 1:3 % predictive vs reactive vs both
    for d = 1:3 % HG vs LF vs both
        switch(c)
            case 1
                switch(d)
                    case 1
                        feats = preFeats_hg(prehs_hg==1, :);
                    case 2
                        feats = preFeats_lf(prehs_lf==1, :);
                    case 3
                        feats = [preFeats_hg(prehs_hg==1, :); preFeats_lf(prehs_lf==1, :)];
                end
            case 2
                switch(d)
                    case 1
                        feats = reFeats_hg(rehs_hg==1, :);
                    case 2
                        feats = reFeats_lf(rehs_lf==1, :);
                    case 3
                        feats = [reFeats_hg(rehs_hg==1, :); reFeats_lf(rehs_lf==1, :)];
                end
            case 3
                switch(d)
                    case 1
                        feats = [preFeats_hg(prehs_hg==1, :); reFeats_hg(rehs_hg==1, :)];
                    case 2
                        feats = [preFeats_lf(prehs_lf==1, :); reFeats_lf(rehs_lf==1, :)];
                    case 3
                        feats = [preFeats_hg(prehs_hg==1, :); preFeats_lf(prehs_lf==1, :); reFeats_hg(rehs_hg==1, :); reFeats_lf(rehs_lf==1, :)];
                end
        end

%         % here's a test to randomize the hits and see what kind of
%         % classification we get
%         nummisses = sum(misses);
%         idxs = randperm(length(misses));
%         idxs = idxs(1:nummisses);
%         misses = zeros(size(misses));
%         misses(idxs) = 1;
%         % end randomization
        
        nfolds = 4;
        
        if (size(feats, 1) > 0)
            [acc(c, d), mx(c, d, :), my(c, d, :), aucs(c,d), sens(c, d), spec(c, d)] = nFoldCrossValidation(feats', misses==1, 4, 1);
        else
            acc(c, d) = NaN;
            len = floor(length(misses)/4);
            mx(c, d, :) = ((0:len)/len);
            my(c, d, :) = ((0:len)/len);
            sens(c, d) = .5;
            spec(c, d) = .5;
            aucs(c, d) = .5;
        end
        fprintf('%d, %d: acc: %0.3f auc: %0.3f sens: %0.3f spec: %0.3f\n', c, d, acc(c, d), aucs(c,d), sens(c, d), spec(c, d));
        
    end
end

%% plot the ROCs and AUCs
% predictive ROCs
for c = 1:3
    switch(c)
        case 1
            tit = sprintf('Predictive ROC - %s', subcode);
            fname = fullfile(odir, 'figs', 'preROC.eps');
        case 2
            tit = sprintf('Reactive ROC - %s', subcode);
            fname = fullfile(odir, 'figs', 'reROC.eps');
        case 3
            tit = sprintf('Combined ROC - %s', subcode);
            fname = fullfile(odir, 'figs', 'combROC.eps');
    end
    
    figure;
    ax = plot(squeeze(mx(c,:,:))', squeeze(my(c,:,:))', 'LineWidth', 3);
    set(ax(3), 'LineStyle', ':');
    
    legend(sprintf('\\gamma (AUC: %0.3f)', aucs(c, 1)), ...
           sprintf(    'LF (AUC: %0.3f)', aucs(c, 2)), ...
           sprintf(  'Both (AUC: %0.3f)', aucs(c, 3)), ...           
           'Location', 'Southeast');
    set(gca, 'FontSize', 14);
    title(tit, 'FontSize', 18);
    xlabel('False positive rate', 'FontSize', 18);
    ylabel('True positive rate', 'FontSize', 18);
    saveas(gcf, fname, 'psc2');
end



