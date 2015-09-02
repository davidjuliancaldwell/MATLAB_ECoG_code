%% make a plot of classification accuracies as a function of feature count

subjids = {'38e116', 'fc9643','4568f4','30052b'};
labels = {'S1','S2','S3','S4'};

ctr = 0;
colors = 'bgrk';
offsets = [-0.15 -0.05 0.05 0.15];

figure;

for zubjid = subjids
    subjid = zubjid{:};
    [~, odir] = filesForSubjid(subjid);
    
    ctr = ctr + 1;
    load(fullfile(odir, [subjid '_timetradeoff']));
    plot(delays, accs, 'Color', colors(ctr));
%     errorbar((1:length(msBeyondResult))+offsets(ctr), accs, 'Color', colors(ctr));
    hold on;
end

ylabel('classification accuracy');
xlabel('time after error occurs (ms)');
title('impact of time window on classification accuracy');
legend(labels);

