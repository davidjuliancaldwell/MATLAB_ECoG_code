%% make a plot of classification accuracies as a function of feature count

subjids = {'9ad250', 'fc9643', '4568f4', '30052b'};
labels = {'S1','S2','S3','S4'};

ctr = 0;
colors = 'bgrk';
offsets = [-0.15 -0.05 0.05 0.15];

figure;

for zubjid = subjids
    subjid = zubjid{:};
    
    ctr = ctr + 1;
    load(fullfile(subjid, [subjid '_class']));
    errorbar((1:length(list))+offsets(ctr), accs_mu, accs_std, colors(ctr));
    allmus(ctr) = max(accs_mu);
    hold on;
end

ylabel('classification accuracy');
xlabel('features used');
title('impact of feature count on classification accuracy');
legend(labels);

mean(allmus)
std(allmus)