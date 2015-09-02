%% table 1, this section also contributes information to the section
%% entitled Volitional modulation of activity at the controlling electrode
%% from the paper.

subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};
ids = {'S1','S2','S3','S4','S5','S6','S7'};

for c = 1:length(subjids)
    subjid = subjids{c};
    id = ids{c};    
    LoadCacheData;
    
    up = 1;
    down = 2;
    
    upN = sum(targetCodes==up);
    dnN = sum(targetCodes==down);
    rN = length(restZs(controlChannel,:));
    
    [upH, upP] = ttest2(epochZs(controlChannel, targetCodes == up), restZs(controlChannel, :), 0.05/7, 'right', 'unequal');
    [dnH, dnP] = ttest2(epochZs(controlChannel, targetCodes == down), restZs(controlChannel, :), 0.05/7, 'left', 'unequal');
    
    
    fprintf('%s (%s): \n', subjid, id);
    fprintf('  of %d (n2=%d) up trials: h = %d / p = %e\n', upN, rN, upH, upP);
    fprintf('  of %d (n2=%d) dn trials: h = %d / p = %e\n', dnN, rN, dnH, dnP);
    fprintf('\n');

end

%% This section contributes information to the section entitled
%% Task-modulated activity throughout cortex from the paer.

subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};
ids = {'S1','S2','S3','S4','S5','S6','S7'};

trodect = 0;
badct = 0;
for c = 1:length(subjids)
    subjid = subjids{c};
    id = ids{c};    
    LoadCacheData;
    
    trodect = trodect + size(epochZs, 1);
    badct = badct + length(badchans);
end

fprintf ('the total number of electrodes recorded was %d\n', trodect);
fprintf ('the number of excluded channels was %d\n', badct);
fprintf ('the number of remaining channels analyzed was %d\n', trodect-badct);
    
upTot = 0;
dnTot = 0;
allTot = 0;

for c = 1:length(subjids)
    subjid = subjids{c};
    id = ids{c};    
    LoadCacheData;
    
    up = 1;
    down = 2;
    
    upN = sum(targetCodes==up);
    dnN = sum(targetCodes==down);
    rN = size(restZs,2);
    
    [upH, upP] = ttest2(epochZs(:, targetCodes == up)', restZs', 0.05/(trodect-badct), 'right', 'unequal');
    upH(badchans) = 0;
    
    [dnH, dnP] = ttest2(epochZs(:, targetCodes == down)', restZs', 0.05/(trodect-badct), 'right', 'unequal');
    dnH(badchans) = 0;

    [allH, allP] = ttest2(epochZs', restZs', 0.05/(trodect-badct), 'right', 'unequal');
    allH(badchans) = 0;
    
    fprintf('%s (%s): \n', subjid, id);
    fprintf('  %d of %d electrodes showed an increase during up trials: minp = %e, maxp = %e, maxp\n', ...
        sum(upH), length(upH)-length(badchans), min(upP(upH==1)), max(upP(upH==1)));

    fprintf('  %d of %d electrodes showed an increase during down trials: minp = %e, maxp = %e, maxp\n', ...
        sum(dnH), length(dnH)-length(badchans), min(dnP(dnH==1)), max(dnP(dnH==1)));

    fprintf('  %d of %d electrodes showed an increase during all trials: minp = %e, maxp = %e, maxp\n', ...
        sum(allH), length(allH)-length(badchans), min(allP(allH==1)), max(allP(allH==1)));
    
    upTot = upTot + sum(upH);
    dnTot = dnTot + sum(dnH);
    allTot = allTot + sum(allH);
    
%     fprintf('  of %d (n2=%d) up trials: h = %d / p = %e\n', upN, rN, upH, upP);
%     fprintf('  of %d (n2=%d) dn trials: h = %d / p = %e\n', dnN, rN, dnH, dnP);
%     fprintf('\n');

end

upTot
dnTot
allTot