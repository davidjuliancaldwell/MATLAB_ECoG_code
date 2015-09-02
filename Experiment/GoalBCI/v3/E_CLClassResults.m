%% Constants
addpath ./functions
Z_Constants;

%% 
accs = [];
for zid = SIDS
    sid = zid{:};
    
    % input files - i know this is a different structure from how we're
    % collecting data files in the rest of the scripts, can be updated
    % later once I have all of the data collected
    [files, ~, ~, ~, isbias] = goalDataFiles(sid);
    files(~isbias) = [];
    
    labels = false(0);
    estimates = false(0);
    probabilities = [];
    biased = false(0);
    
    targets = [];
    results = [];
    mtt = [];
    ise = [];
    endSide = [];
    
    for fileIdx = 1:length(files)
        [~,sta,par] = load_bcidat(files{fileIdx});
        
        if (isfield(par, 'BiasActive') && par.BiasActive.NumericValue == 1)
            % do something with the data
            [mlabels, mestimates, mprobabilities, mbiased] = ...
                extractClassificationPerformance(sta);
            
            labels = cat(1, labels, mlabels);
            estimates = cat(1, estimates, mestimates);
            probabilities = cat(1, probabilities, mprobabilities);
            biased = cat(1, biased, mbiased);
            
            [mTargets, mResults, mMtt, mIse, mEndSide] = extractGoalBCIPerformance(sta, par);
            
            targets = cat(1, targets, mTargets);
            results = cat(1, results, mResults);
            mtt = cat(1, mtt, mMtt);
            ise = cat(1, ise, mIse);            
            endSide = cat(1, endSide, mEndSide);
        end
    end
    if (isempty(files)) % we haven't seen a file with bias active
        warning('no files for subject (%s) with biasing.', sid);
    else

% %         % make a sequential plot
% %         figure
% %         plot(labels,'b*');
% %         hold on;
% %         plot(estimates,'ro');
% %         plot(probabilities,'k','linew',2);
% %         h = vline(find(biased));
% %         set(h,'color',[.5 .5 .5]);
% 
% %         %  make a confusion matrix
% %         figure
% %         prettyconfusion(labels, estimates);
% % 
% %         set(gca,'xtick',[1 2]);
% %         set(gca,'xticklabel',{'Down', 'Up'});
% %         xlabel('Truth', 'fontsize', FONT_SIZE);
% %         set(gca,'ytick',[1 2]);
% %         set(gca,'yticklabel',{'Down', 'Up'});
% %         ylabel('Estimate', 'fontsize', FONT_SIZE);
% %         set(gca,'fontsize',LEGEND_FONT_SIZE);
% %         title(sprintf('Classification confusion matrix - %s', sid), 'fontsize', FONT_SIZE);

%         % compare correct classifications vs incorrect classifications
%         prettybar(probabilities, labels==estimates);
%         [~, p] = ttest2(probabilities(labels~=estimates), probabilities(labels==estimates));
%         set(gca,'xtick',[1 2]);        
%         sigstar({{1 2}}, p);
%         ylabel('posterior probability of classification');
%         xlabel('type');
%         set(gca, 'xticklabel', {'incorrect','correct'});
%         title(sprintf('classification confidence - %s', sid));
%         SaveFig(OUTPUT_DIR, sprintf('class conf %s', sid), 'eps');
%         
        % perform comparison of biasing vs non-biasing        
        figure
        prettybar(results==targets, biased);
        p = chi2pdf(chiTable(confusionmat(results==targets, biased)), 1);
        p = min(p, 1);
        
        sigstar({{1 2}}, p);

        ylabel('accuracy');
        xlabel('type');
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'unbiased','biased'});
        title(sprintf('accuracy change with rt classification - %s', sid));
        SaveFig(OUTPUT_DIR, sprintf('class acc %s', sid), 'eps');


%         
%         prettybar(mtt', biased);
%         [~,p] = ttest2(mtt(biased&~isnan(mtt)),mtt(~biased&~isnan(mtt)));
%         set(gca,'xtick',[1 2]);        
%         sigstar({{1,2}}, p);
%         xlabel('type');
%         ylabel('mtt (sec)');
%         title(sprintf('mtt change with rt classification - %s', sid));
%         legend('unbiased','biased')
%         SaveFig(OUTPUT_DIR, sprintf('class mtt %s', sid), 'eps');
% 
%         
%         prettybar(ise', biased);
%         [~,p] = ttest2(ise(biased), ise(~biased));
%         set(gca,'xtick',[1 2]);        
%         sigstar({{1, 2}}, p);
%         legend('unbiased','biased')
%         xlabel('type');
%         ylabel('ise (workspace-seconds)');
%         title(sprintf('ise change with rt classification - %s', sid));
%         SaveFig(OUTPUT_DIR, sprintf('class ise %s', sid), 'eps');
% 
%         figure
%         bar([mean(endSide(~biased)), mean(endSide(biased))]);
%         p = chi2pdf(chiTable(confusionmat(endSide==1, biased)), 1);
%         p = min(p, 1);        
%         sigstar({{1 2}}, p);    
%         xlabel('type');
%         ylabel('ended well');
%         title(sprintf('ending well change with rt classification - %s', sid));
%         SaveFig(OUTPUT_DIR, sprintf('class end %s', sid), 'eps');
        
        % look at the effect of the intervention on behavioral performance                
        prettybar(results(biased)==targets(biased), labels(biased)==estimates(biased));
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'incorrect', 'correct'});
        ylabel('accuracy');
        title(sprintf('hit rate by classification correctness - %s', sid));
        SaveFig(OUTPUT_DIR, sprintf('class acc correct %s', sid), 'eps');

        prettybar(mtt(biased), labels(biased)==estimates(biased));
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'incorrect', 'correct'});
        ylabel('MTT');
        title(sprintf('MTT by classification correctness - %s', sid));
        SaveFig(OUTPUT_DIR, sprintf('class mtt correct %s', sid), 'eps');

        prettybar(ise(biased), labels(biased)==estimates(biased));
        set(gca, 'xtick', [1 2]);
        set(gca, 'xticklabel', {'incorrect', 'correct'});
        ylabel('ISE');
        title(sprintf('ISE by classification correctness - %s', sid));
        SaveFig(OUTPUT_DIR, sprintf('class ise correct %s', sid), 'eps');
        
        accs(end+1) = mean(labels==estimates);        
    end        
end

fprintf('average classification accuracy across all subjects (N=%d) = %1.2f\n', length(accs), mean(accs));

%%
figure
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


