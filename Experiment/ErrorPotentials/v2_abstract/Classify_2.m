%% make a plot of classification accuracies as a function of feature count

subjids = {'38e116', 'fc9643','4568f4','30052b'};
labels = {'S1','S2','S3','S4'};

ctr = 0;

colors = 'bgkr';

offsets = [-0.15 -0.05 0.05 0.15];

figure;

for zubjid = subjids
    subjid = zubjid{:};
    [~, odir] = filesForSubjid(subjid);
    
    ctr = ctr + 1;
    load(fullfile(odir, [subjid '_class']));
    
    len = min(length(list),8);
    if (length(accs_mu) > 0)
        errorbar((1:len)+offsets(ctr), accs_mu, accs_std, colors(ctr)); hold on;
        plot((1:len)+offsets(ctr), accs_mu, 'd-', 'Color', colors(ctr), 'LineWidth', 2);
        allmus(ctr) = max(accs_mu);
    end
    hold on;
end

ylabel('Classification accuracy', 'FontSize', 15);
xlabel('Features used', 'FontSize', 15);
title('Impact of feature count on classification accuracy', 'FontSize', 15);
% legend(labels);

mean(allmus)
std(allmus)

SaveFig(pwd, 'class', 'eps');