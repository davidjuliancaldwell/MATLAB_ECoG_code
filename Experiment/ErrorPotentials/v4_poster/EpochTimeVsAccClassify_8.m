%% so what's the idea here?
% we want to find mean classification acc/auc/sens/spec for features
% that were derived by using successively more and more time out of the
% full feature length, effectively asking what is the associated cost with
% making a decision sooner.
%
% This willl need to happen for all subjects at once, since we're going to
% average the classifier results across subjects

% set up our container variables
ACC = 1;
AUC = 2;
SENS = 3;
SPEC = 4;

preResults = []; % lazy size setting
reResults = [];

subjids = {'fc9643', ... 
           '4568f4', ... 
           '30052b', ... 
           '9ad250', ... 
           '38e116'};

for snum = 1:length(subjids)
    subjid = subjids{snum};
    
    % load in the electrodes for this subject
    [~, odir] = filesForSubjid(subjid);
%     load(fullfile(odir, [subjid '_features']), 'rehs*', 'prehs*', 'restats*', 'prestats*', 'locst');
    load(fullfile(odir, [subjid '_features']), 'misses');
    load(fullfile(odir, 'time_versus_acc_feats'), 'preStartTime', 'preEndTimes', 'reStartTime', 'reEndTimes', 'div*');

    for times = 1:5
        [preResults(snum, times,  ACC), ~, ~, preResults(snum, times,  AUC), preResults(snum, times,  SENS), preResults(snum, times,  SPEC)] = ...
            nFoldCrossValidation(squeeze(divPreHGFeats(times, :, :))', misses==1, 4);
        
        [ reResults(snum, times,  ACC), ~, ~,  reResults(snum, times,  AUC),  reResults(snum, times,  SENS),  reResults(snum, times,  SPEC)] = ...
            nFoldCrossValidation(squeeze(divReHGFeats(times, :, :))', misses==1, 4);
    end
end

%% display results
reResults(reResults == 0 | reResults == 1) = NaN;
preResults(preResults == 0 | preResults == 1) = NaN;

prevals = squeeze(nanmean(preResults, 1));
presems = squeeze(nanstd(preResults, 1))/sqrt(length(subjids));

 revals = squeeze(nanmean( reResults, 1));
 resems = squeeze(nanstd( reResults, 1))/sqrt(length(subjids));
 
figure;
ax = plot(preEndTimes-3, prevals-.0025, ':', 'LineWidth', 3, 'Color', 'k');
hold on;
errorbar(repmat(preEndTimes'-3, 1, 4), prevals-0.0025, presems, 'LineWidth', 3, 'LineStyle', ':', 'Color', 'k');
errorbar(repmat(preEndTimes'-3, 1, 4), prevals, presems, 'LineWidth', 3, 'LineStyle', ':');

ax = plot(reEndTimes-3, revals-.0025, '-', 'LineWidth', 3, 'Color', 'k');
errorbar(repmat(reEndTimes'-3, 1, 4), revals-0.0025, resems, 'LineWidth', 3, 'LineStyle', '-', 'Color', 'k');
errorbar(repmat(reEndTimes'-3, 1, 4), revals, resems, 'LineWidth', 3, 'LineStyle', '-');

xlim([-0.5 0.6]);

set(gca, 'FontSize', 14);
xlabel('Classification time rel. to trial end (s)', 'FontSize', 18);
title('Time vs accuracy tradeoff', 'FontSize', 18);

SaveFig(fullfile(fileparts(odir), 'figs'), 'time_vs_acc', 'eps', '-r300');


