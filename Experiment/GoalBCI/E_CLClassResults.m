%% Constants
addpath ./functions
Z_Constants;

%% 
accs = []; idx = 0;

ise_mu = [];
ise_sem = [];
hr_mu = [];
hr_sem = [];

for zid = SIDS
    sid = zid{:};
    idx = idx + 1;
    
    % input files - i know this is a different structure from how we're
    % collecting data files in the rest of the scripts, can be updated
    % later once I have all of the data collected
    [files, ~, ~, ~, isbias] = goalDataFiles(sid);
%     files(~isbias) = [];
    
    if (any(isbias))
        labels = false(0);
        estimates = false(0);
        probabilities = [];
        biased = false(0);
        biasPossible = false(0);

        targets = [];
        results = [];
        mtt = [];
        ise = [];
        endSide = [];

        for fileIdx = 1:length(files)
            fprintf('  file %d of %d\n', fileIdx, length(files));
            
            [~,sta,par] = load_bcidat(files{fileIdx});

            [mTargets, mResults, mMtt, mIse, mEndSide] = extractGoalBCIPerformance(sta, par);

            targets = cat(1, targets, mTargets);
            results = cat(1, results, mResults);
            mtt = cat(1, mtt, mMtt);
            ise = cat(1, ise, mIse);            
            endSide = cat(1, endSide, mEndSide);
            
            if (isfield(par, 'BiasActive') && par.BiasActive.NumericValue == 1)
                [mlabels, mestimates, mprobabilities, mbiased] = ...
                    extractClassificationPerformance(sta);

                labels = cat(1, labels, mlabels);
                estimates = cat(1, estimates, mestimates);
                probabilities = cat(1, probabilities, mprobabilities);
                biased = cat(1, biased, mbiased);
                biasPossible = cat(1, biasPossible, true(size(mTargets)));
            else
                labels = cat(1, labels, nan(size(mTargets)));
                estimates = cat(1, estimates, nan(size(mTargets)));
                probabilities = cat(1, probabilities, nan(size(mTargets)));
                biased = cat(1, biased, false(size(mTargets)));
                biasPossible = cat(1, biasPossible, false(size(mTargets)));                
            end
        end
        
        load(fullfile(META_DIR, sprintf('%s-trial_info.mat', sid)), 'bad_marker');    
        bad_trials = all(bad_marker)';
        
        if (length(bad_trials) ~= length(biased))
            error('trial count mismatch');
        end
        
        targets(bad_trials | ~biasPossible) = [];
        results(bad_trials | ~biasPossible) = [];
        mtt(bad_trials | ~biasPossible) = [];
        ise(bad_trials | ~biasPossible) = [];
        endSide(bad_trials | ~biasPossible) = [];
        labels(bad_trials | ~biasPossible) = [];
        estimates(bad_trials | ~biasPossible) = [];
        probabilities(bad_trials | ~biasPossible) = [];
        biased(bad_trials | ~biasPossible) = [];
        biasPossible(bad_trials | ~biasPossible) = [];
                
%         % perform comparison of biasing vs non-biasing         
%         prettyconfusion(labels, estimates);
%         set(gca, 'xticklabel', {'down', 'up'})
%         set(gca, 'yticklabel', {'down', 'up'})
%         title(sprintf('Classification confusion matrix - %s',sid));
%         SaveFig(OUTPUT_DIR, sprintf('class conf %s', sid), 'eps');
                
        %
        prettybar(results==targets, biased);
        p = chi2pdf(chiTable(confusionmat(results==targets, biased)), 1);
        p_hr = min(p, 1);        
        sigstar({{1 2}}, p_hr);
        ylabel('accuracy');
        xlabel('type');
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'unbiased','biased'});
        title(sprintf('accuracy change with rt classification - %s', sid));
        SaveFig(OUTPUT_DIR, sprintf('class acc %s', sid), 'eps');

        %
        prettybar(ise, biased);
        [~, p_ise] = ttest2(ise(biased), ise(~biased));        
        sigstar({{1 2}}, p_ise);
        ylabel('accuracy');
        xlabel('type');
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'unbiased','biased'});
        title(sprintf('ise change with rt classification - %s', sid));
        SaveFig(OUTPUT_DIR, sprintf('class ise %s', sid), 'eps');
        
        hr_mu(idx, 1) = mean(results(biased)==targets(biased));
        hr_mu(idx, 2) = mean(results(~biased)==targets(~biased));
        hr_sem(idx, 1) = sem(results(biased)==targets(biased));
        hr_sem(idx, 2) = sem(results(~biased)==targets(~biased));
        ise_mu(idx, 1) = mean(ise(biased));
        ise_mu(idx, 2) = mean(ise(~biased));
        ise_sem(idx, 1) = sem(ise(biased));
        ise_sem(idx, 2) = sem(ise(~biased));
        hr_p(idx) = p_hr; 
        ise_p(idx) = p_ise;
        
        % look at the effect of the intervention on behavioral performance               
        prettybar(results(biased)==targets(biased), labels(biased)==estimates(biased));
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'incorrect', 'correct'});
        ylabel('hit rate');
        title(sprintf('hit rate by classification correctness - %s', sid));
        p = chi2pdf(chiTable(confusionmat(results(biased)==targets(biased), labels(biased)==estimates(biased))), 1);
        p_hr = min(p, 1);
        sigstar({{1 2}}, p_hr);
        SaveFig(OUTPUT_DIR, sprintf('class acc correct %s', sid), 'eps');

        %
        prettybar(ise(biased), labels(biased)==estimates(biased));
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'incorrect', 'correct'});
        ylabel('ISE');
        title(sprintf('ISE by classification correctness - %s', sid));
        [~, p_ise] = ttest2(ise(biased & labels==estimates),ise(biased & labels~=estimates))
        
        sigstar({{1 2}}, p_ise);        
        SaveFig(OUTPUT_DIR, sprintf('class ise correct %s', sid), 'eps');
        
        cor = labels(biased)==estimates(biased);
        hit = results(biased)==targets(biased);
        ise = ise(biased);
        ihr_mu(idx, 1) = mean(hit(cor));
        ihr_mu(idx, 2) = mean(hit(~cor));
        ihr_sem(idx, 1) = sem(hit(cor));
        ihr_sem(idx, 2) = sem(hit(~cor));
        iise_mu(idx, 1) = mean(ise(cor));
        iise_mu(idx, 2) = mean(ise(~cor));
        iise_sem(idx, 1) = sem(ise(cor));
        iise_sem(idx, 2) = sem(ise(~cor));
        ihr_p(idx) = p_hr; 
        iise_p(idx) = p_ise;
        
        
        accs(end+1) = mean(labels(biased)==estimates(biased));        
        
    else
        warning('no files for subject (%s) with biasing.', sid);
    end        
end

fprintf('average classification accuracy across all subjects (N=%d) = %1.2f\n', length(accs), mean(accs));

%%
figure
bar(hr_mu)
bar(mean(accs),'facecolor',[.5 .5 .5], 'linew', 2);
hold on;
legendOff(errorbar(mean(accs), std(accs),'k','linestyle','none','linew',2));
ylim([0 1]);
xlim([0 2]);
plot([0 2], [.5 .5],'k:');
ylabel('Classification accuracy');
title('Real-time classification results');
set(gca,'xtick',[]);
legend('Aggregate (N=3)', 'Chance');

SaveFig(OUTPUT_DIR, 'RT_summary', 'eps', '-r300');
SaveFig(OUTPUT_DIR, 'RT_summary', 'png', '-r300');

%% additional pretty rt summaries
bads = all(hr_mu==0,2);
hr_mu(bads,:) = [];
hr_sem(bads,:) = [];
ise_mu(bads,:) = [];
ise_sem(bads,:) = [];
hr_p(bads) = [];
ise_p(bads) = [];
ihr_mu(bads,:) = [];
ihr_sem(bads,:) = [];
iise_mu(bads,:) = [];
iise_sem(bads,:) = [];
ihr_p(bads) = [];
iise_p(bads) = [];

figure
subplot(121);
ax = bar(hr_mu(:,2:-1:1));
set(ax, 'linew', 2);
temp = get(get(ax(1),'Children'), 'xdata');
xs(:, 1) = mean(temp(1:2:end,:));
temp = get(get(ax(2),'Children'), 'xdata');
xs(:, 2) = mean(temp(1:2:end,:));
set(ax(1), 'facecolor', [1 0 0]);
set(ax(2), 'facecolor', [0 0 1]);

hold on;
ax = errorbar(xs, hr_mu(:,2:-1:1), hr_sem(:,2:-1:1));
set(ax, 'color', 'k', 'linew', 2, 'linestyle', 'none');

sigstar(arrayfun(@(n) {xs(n,1) xs(n,2)}, 1:3, 'uniformoutput', false),hr_p);

set(gca,'xticklabel', {'S7', 'S8', 'S9'});
title('Accuracy changes with RT goal inference');
ylabel('Hitrate');
legend('Unbiased', 'Biased', 'location', 'southwest');

subplot(122);
ax = bar(ise_mu(:,2:-1:1));
set(ax, 'linew', 2);
temp = get(get(ax(1),'Children'), 'xdata');
xs(:, 1) = mean(temp(1:2:end,:));
temp = get(get(ax(2),'Children'), 'xdata');
xs(:, 2) = mean(temp(1:2:end,:));
set(ax(1), 'facecolor', [1 0 0]);
set(ax(2), 'facecolor', [0 0 1]);

hold on;
ax = errorbar(xs, ise_mu(:,2:-1:1), ise_sem(:,2:-1:1));
set(ax, 'color', 'k', 'linew', 2, 'linestyle', 'none');

sigstar(arrayfun(@(n) {xs(n,1) xs(n,2)}, 1:3, 'uniformoutput', false),ise_p);

set(gca,'xticklabel', {'S7', 'S8', 'S9'});
title('ISE changes with RT goal inference');
ylabel('ISE (screen-sec)');
% legend('Unbiased', 'Biased', 'location', 'southwest');
set(gcf,'pos',[624         474        1205         504]);

SaveFig(OUTPUT_DIR, 'rt summary', 'eps', '-r300');


figure
subplot(121);
ax = bar(ihr_mu(:,2:-1:1));
set(ax, 'linew', 2);
temp = get(get(ax(1),'Children'), 'xdata');
xs(:, 1) = mean(temp(1:2:end,:));
temp = get(get(ax(2),'Children'), 'xdata');
xs(:, 2) = mean(temp(1:2:end,:));
set(ax(1), 'facecolor', [1 0 0]);
set(ax(2), 'facecolor', [0 0 1]);

hold on;
ax = errorbar(xs, ihr_mu(:,2:-1:1), ihr_sem(:,2:-1:1));
set(ax, 'color', 'k', 'linew', 2, 'linestyle', 'none');

sigstar(arrayfun(@(n) {xs(n,1) xs(n,2)}, 1:3, 'uniformoutput', false),ihr_p);
ylim([0 0.8])
set(gca,'xticklabel', {'S7', 'S8', 'S9'});
title('Accuracy by classification correctness');
ylabel('Hitrate');
legend('Incorrect', 'Correct', 'location', 'southwest');

subplot(122);
ax = bar(iise_mu(:,2:-1:1));
set(ax, 'linew', 2);
temp = get(get(ax(1),'Children'), 'xdata');
xs(:, 1) = mean(temp(1:2:end,:));
temp = get(get(ax(2),'Children'), 'xdata');
xs(:, 2) = mean(temp(1:2:end,:));
set(ax(1), 'facecolor', [1 0 0]);
set(ax(2), 'facecolor', [0 0 1]);

hold on;
ax = errorbar(xs, iise_mu(:,2:-1:1), iise_sem(:,2:-1:1));
set(ax, 'color', 'k', 'linew', 2, 'linestyle', 'none');

sigstar(arrayfun(@(n) {xs(n,1) xs(n,2)}, 1:3, 'uniformoutput', false),iise_p);

set(gca,'xticklabel', {'S7', 'S8', 'S9'});
title('ISE by classification correctness');
ylabel('ISE (screen-sec)');
% legend('Unbiased', 'Biased', 'location', 'southwest');
set(gcf,'pos',[624         474        1205         504]);

SaveFig(OUTPUT_DIR, 'rt summary crr', 'eps', '-r300');
