addpath ./scripts
Z_Constants;


% %%
% % 3745d1 46
% % 58411c 46
% % 0dd118 20
% % f83dbb 36
% 
% allsids = [3 6 7 10];
% alltrs = [46 46 20 36];
% 
% ctr = 0;
% for sIdx = allsids
%     ctr = ctr + 1;

for sIdx = [2 5]% 1:length(SIDS)
    sid = SIDS{sIdx};
    scode = SCODES{sIdx};
    
    fprintf('working on %s\n', sid);
    
    fprintf('  loading data: '); tic;
    load(fullfile(META_DIR, sprintf('%s_epochs.mat', sid)));
    load(fullfile(META_DIR, sprintf('%s_results.mat', sid)), 'class');
    toc;
    
    %% first, select, reorder and smooth the data
    trialsToConsider = ~all(bad_marker) & (tgts == 1)';
    
%     trs = find(class == 1 | class == 2); % this gets only the task modulated electrodes
    trs = find(~isnan(class));
    
    trodes = [cchan; trs(trs ~= cchan)];
%     trodes = [cchan; trs(trs ~= cchan); alltrs(ctr)];
    
    alpha = epochs_alpha(trodes, trialsToConsider, :);
    beta  = epochs_beta (trodes, trialsToConsider, :);
    hg    = epochs_hg   (trodes, trialsToConsider, :);     
    
    for ei = 1:size(alpha, 2)
        alpha(:, ei, :) = GaussianSmooth(squeeze(alpha(:, ei, :))', SMOOTH_TIME_SEC * fs)';
        beta (:, ei, :) = GaussianSmooth( squeeze(beta(:, ei, :))', SMOOTH_TIME_SEC * fs)';
        hg   (:, ei, :) = GaussianSmooth(   squeeze(hg(:, ei, :))', SMOOTH_TIME_SEC * fs)';
    end
    
    %% now determine what the offsets should be
    [onsetSamples, modulationDepths] = findHGOnsets(squeeze(hg(1, :, :))', t, fs);
%     save(fullfile(META_DIR, [sid '_results.mat']), '-append', 'onsetSamples', 'modulationDepths');

    
    %% make some simple onsets plots
    [aligned_c_hg, alignedT] = alignActivationsByOnset(squeeze(hg(1, :, :))', onsetSamples, t);
    figure;
%     subplot(131);
    imagesc(alignedT, 1:size(aligned_c_hg, 2), aligned_c_hg');
%     colormap('gray')
    hold on;
    scatter(-t(onsetSamples), 1:size(aligned_c_hg, 2), 30, 'markerfacecolor', 'k', 'markeredgecolor', 'w');        
    vline(0,'k');        
    xlabel('Time rel. HG onset (sec)'); 
    ylabel('Trials');
    title(scode);

%     aligned_c_beta = alignActivationsByOnset(squeeze(beta(1, :, :))', onsetSamples, t);
%     subplot(132);
%     imagesc(alignedT, 1:size(aligned_c_beta, 2), aligned_c_beta');
%     hold on;
%     scatter(-t(onsetSamples), 1:size(aligned_c_hg, 2), 30, 'markerfacecolor', 'k', 'markeredgecolor', 'w');
%     vline(0,'k');       
%     xlabel('time rel. HG onset at CTL'); ylabel('trials');
%     title([sid 'Beta ' trodeNameFromMontage(cchan, montage)]);
% 
%     aligned_c_alpha = alignActivationsByOnset(squeeze(alpha(1, :, :))', onsetSamples, t);
%     subplot(133);
%     imagesc(alignedT, 1:size(aligned_c_alpha, 2), aligned_c_alpha');
%     hold on;
%     scatter(-t(onsetSamples), 1:size(aligned_c_hg, 2), 30, 'markerfacecolor', 'k', 'markeredgecolor', 'w');
%     vline(0,'k');       
%     xlabel('time rel. HG onset at CTL'); ylabel('trials');
%     title([sid 'Alpha ' trodeNameFromMontage(cchan, montage)]);        
    set(gca, 'clim', [-1 3]);
    
    colorbarLabel(colorbar, 'HG Amplitude (Z units)');
    
    set(gcf, 'pos', [680   558   400   400]);
    SaveFig(OUTPUT_DIR, [sid '_ctl_col'], 'eps');        
        colormap('gray')
    SaveFig(OUTPUT_DIR, [sid '_ctl'], 'eps');        
        
    close all;    
    
    %% save the important bits
%     save(fullfile(META_DIR, [sid '_extracted']), 'alpha', 'beta', 'hg', 't', 'onsetSamples', 'alignedT', 'trodes', 'fs');
end


