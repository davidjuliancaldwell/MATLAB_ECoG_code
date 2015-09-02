%% collect the data and perform statistical analyses
fig_setup;

uAct_all = [];
dAct_all = [];
aAct_all = [];
uLocs_all = [];
dLocs_all = [];
aLocs_all = [];
uCtlChanFlag_all = [];
dCtlChanFlag_all = [];
aCtlChanFlag_all = [];

chanct = 0;
badct = 0;
for c = 1:length(subjids)
    subjid = subjids{c};
    LoadCacheData_beta;
    
    chanct = chanct + size(epochZs, 1);
    badct = badct + length(badchans);
end

for c = 1:length(subjids)
    subjid = subjids{c};
    LoadCacheData_beta;

    % build the subject specific data
    uZs = epochZs(:, targetCodes == up);
    dZs = epochZs(:, targetCodes == down);
    
    uAct = mean(uZs, 2) - mean(restZs, 2);
    dAct = mean(dZs, 2) - mean(restZs, 2);
    aAct = mean(epochZs, 2) - mean(restZs, 2);
    
    [uSigs, uPs] = ttest2(uZs', restZs', 0.05 / (chanct-badct), 'left', 'unequal');
    uSigs = uSigs' == 1;
    [dSigs, dPs] = ttest2(dZs', restZs', 0.05 / (chanct-badct), 'left', 'unequal');
    dSigs = dSigs' == 1;
    [aSigs, aPs] = ttest2(epochZs', restZs', 0.05 / (chanct-badct), 'left', 'unequal');
    aSigs = aSigs' == 1;
    
    uSigs(badchans) = 0;
    dSigs(badchans) = 0;
    aSigs(badchans) = 0;
    
    fprintf('for subject %s: minup = %e, maxup = %e\n', subjid, min(uPs(uSigs')), max(uPs(uSigs')));
    fprintf('          minap = %e, maxap = %e\n', min(aPs(aSigs')), max(aPs(aSigs')));
    fprintf('          Nu = %d, Na = %d\n', sum(uSigs), sum(aSigs));
        
    tlocs = trodeLocsFromMontage(subjid, Montage, true);
    
    uLocs = tlocs(uSigs, :);
    dLocs = tlocs(dSigs, :);
    aLocs = tlocs(aSigs, :);
    
    uCtlChanFlag = uSigs(controlChannel);
    dCtlChanFlag = dSigs(controlChannel);
    aCtlChanFlag = aSigs(controlChannel);
    
    % append it to our collection for all subjects
    uAct_all = cat(1, uAct_all, uAct(uSigs));
    dAct_all = cat(1, dAct_all, dAct(dSigs));
    aAct_all = cat(1, aAct_all, aAct(aSigs));
    uLocs_all = cat(1, uLocs_all, uLocs);
    dLocs_all = cat(1, dLocs_all, dLocs);
    aLocs_all = cat(1, aLocs_all, aLocs);
    uCtlChanFlag_all = cat(1, uCtlChanFlag_all, uCtlChanFlag);
    dCtlChanFlag_all = cat(1, dCtlChanFlag_all, dCtlChanFlag);
    aCtlChanFlag_all = cat(1, aCtlChanFlag_all, aCtlChanFlag);
    
%     save(fullfile(cacheOutDir, ['overall_' subjid '.mat']));
end; clearvars -except uAct_all dAct_all aAct_all uLocs_all dLocs_all aLocs_all uCtlChanFlag_all dCtlChanFlag_all aCtlChanFlag_all figOutDir subjids

%% plot on a common brain

load('recon_colormap');

% up targets
ul = uLocs_all;
ul(:, 1) = abs(ul(:, 1))*1.01;

figure;
PlotDotsDirect('tail', ul, uAct_all, 'r', [-(max(abs(uAct_all))) max(abs(uAct_all))], 15, 'recon_colormap', [], false);
maximize;
title('up - beta');
%set(gca, 'CLim', [0 max(get(gca, 'CLim'))]);
colormap(cm)
%colormap(cm(32:end,:));
colorbar;
% circleControlTrodes(gca, subjids, true);
SaveFig(figOutDir, 'overall_beta.tal.up.lg', 'png', '-r300');

% % down targets
% dl = dLocs_all;
% dl(:, 1) = abs(dl(:, 1))*1.01;
% 
% figure;
% PlotDotsDirect('tail', dl, dAct_all, 'r', [-(max(abs(dAct_all))) max(abs(dAct_all))], 15, 'recon_colormap', [], false);
% maximize;
% title('down - beta');
% %set(gca, 'CLim', [0 max(get(gca, 'CLim'))]);
% colormap(cm)
% %colormap(cm(32:end,:));
% colorbar;
% % circleControlTrodes(gca, subjids, true);
% SaveFig(figOutDir, 'overall_beta.tal.down.lg', 'png', '-r600');
% 
% % all targets
% al = aLocs_all;
% al(:, 1) = abs(al(:, 1))*1.01;
% 
% figure;
% PlotDotsDirect('tail', al, aAct_all, 'r', [-(max(abs(aAct_all))) max(abs(aAct_all))], 15, 'recon_colormap', [], false);
% maximize;
% title('all - beta');
% %set(gca, 'CLim', [0 max(get(gca, 'CLim'))]);
% colormap(cm)
% %colormap(cm(32:end,:));
% colorbar;
% % circleControlTrodes(gca, subjids, true);
% SaveFig(figOutDir, 'overall_beta.tal.all.lg', 'png', '-r600');
% 

