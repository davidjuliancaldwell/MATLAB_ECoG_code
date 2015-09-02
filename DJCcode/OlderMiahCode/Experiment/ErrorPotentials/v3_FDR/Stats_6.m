% calculate rough stats on data

subjids = {'9ad250', 'fc9643', '4568f4', '30052b', '38e116'};
labels = {'S1','S2','S3','S4', 'S5'};
idx = 0;

for zubjid = subjids
    subjid = zubjid{:};
    
    idx = idx + 1;
    lab = labels{idx};
    load(fullfile(subjid, [subjid '_epochs_clean']), 'tgts', 'ress');

    fprintf('%s (%s): total trials %d (%2.1f)\n', subjid, lab, length(tgts), 100*sum(tgts==ress)/length(tgts));
    
    tots(idx) = length(tgts);
    pcts(idx) = 100*sum(tgts==ress)/length(tgts);
end

fprintf('total trial count (sd): %3.1f (%1.1f)\n', mean(tots), std(tots));
fprintf('hit percent (sd): %2.1f (%2.1f)\n', mean(pcts), std(pcts));