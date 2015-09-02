% table 1

subjids = {'fc9643', '26cb98', '38e116', '4568f4', '30052b', 'mg', '04b3d5'};
ids = {'S1','S2','S3','S4','S5','S6','S7'};

for c = 1:length(subjids)
    subjid = subjids{c};
    id = ids{c};
    
   
    load(fullfile(myGetenv('output_dir'), '1DBCI', 'cache', ['fig_overall.' subjid '.mat']));
        
    targetCodes = allepochs(allepochs(:,4)==1,5);
    epochZs = allmeans(allepochs(:,4)==1,:)';
    restZs  = allmeans(allepochs(:,5)==0,:)';
    
    controlChannel = getControlChannel(subjid);
    % end new way
    
    up = 1;
    down = 2;
    
    upN = sum(targetCodes==up);
    rN = length(restZs(controlChannel,:));
    
    [upH, upP] = ttest2(epochZs(controlChannel, targetCodes == up), restZs(controlChannel, :), 0.05/7, 'right', 'unequal');
    dnN = sum(targetCodes==down);
    [dnH, dnP] = ttest2(epochZs(controlChannel, targetCodes == down), restZs(controlChannel, :), 0.05/7, 'left', 'unequal');
    
    
    fprintf('%s (%s): \n', subjid, id);
    fprintf('  of %d (n2=%d) up trials: h = %d / p = %e\n', upN, rN, upH, upP);
    fprintf('  of %d (n2=%d) dn trials: h = %d / p = %e\n', dnN, rN, dnH, dnP);
    fprintf('\n');

end