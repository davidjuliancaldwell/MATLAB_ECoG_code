%%
SIDS = {
    '30052b', ...
    '4568f4', ...
    '3745d1', ...
    '26cb98', ...
    'fc9643', ...
    '58411c', ...
    '0dd118', ...
    '7ee6bc', ...
    '38e116', ...
    'f83dbb', ...
};


%%

load data/areas.mat;

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    %% loading data
    fprintf('  loading data: '); tic
    load(fullfile('pmvdata_n150', sprintf('%s_epochs.mat', sid)), 'epochs*', 't', 'fs', 'tgts', 'ress', '*Dur', 'cchan');
    load(fullfile('data', sprintf('%s_results.mat', sid)), 'cchan');
    toc;
    
    %% preprocess data
    fprintf('  preprocessing data: '); tic
    c_hg = single(squeeze(epochs_hg(cchan, :, :))');    
    c_hg = GaussianSmooth(c_hg, .05*fs);
    c_hg = c_hg - repmat(mean(c_hg, 1), [size(c_hg, 1), 1]);
    
    c_beta = -single(squeeze(epochs_beta(cchan, :, :))');
    c_beta = GaussianSmooth(c_beta, .05*fs);
    c_beta = c_beta - repmat(mean(c_beta, 1), [size(c_beta, 1), 1]);
        
    trs = trodesOfInterest{sIdx};
    trs(trs == cchan) = [];
    
    p_hg = permute(squeeze(epochs_hg(trs, :, :)), [1 3 2]);
    toc;
    
    % figure out which epochs are interesting
    half = true(size(tgts));
    half(ceil(length(half)/2):end) = 0;

%     early = tgts == 1 & half;
%     late = tgts == 1 & ~half;

    early = tgts == 1 & ress == 1 & half;
    late = tgts == 1 & ress == 1 & ~half;
    
    % perform covariance analses
    winWidthSec = .150;
    winWidth = ceil(winWidthSec * fs);
    maxLagSec = .80;
    maxLag = ceil(maxLagSec * fs);
    lags = -maxLag:maxLag;
    
%     %% calculate variances for normalization
%     fprintf('  calculating individual variances: '); tic
%     c_hg_vars = zeros(size(c_hg));
%     c_beta_vars = zeros(size(c_beta));    
%     p_hg_vars = zeros(size(p_hg));
%     
%     for center = 1:size(c_hg,1)
%         start = max(center-floor(winWidth/2), 1);
%         stop  = min(center+ceil(winWidth/2), size(c_hg,1));
%         
%         c_hg_vars(center, :) = std(c_hg(start:stop, :), [], 1);
%         c_beta_vars(center, :) = std(c_beta(start:stop, :), [], 1);
%         p_hg_vars(:, center, :) = std(p_hg(:, start:stop, :), [], 2);
%     end    
%     toc
    
%     %% control electrode cross frequency interactions
%     fprintf('  calculating cross frequency interactions at the control electrode: '); tic
%     crossFreqInteraction = zeros(size(c_hg, 2), 2*maxLag + 1, size(c_hg, 1));
%     for epochIdx = 1:size(c_hg, 2)
%         crossFreqInteraction(epochIdx, :, :) = stwc(c_hg(:, epochIdx), c_beta(:, epochIdx), winWidth, maxLag);            
%     end
%     normalizer = permute(repmat(c_hg_vars .* c_beta_vars, [1 1 size(crossFreqInteraction, 2)]), [2 3 1]);
%     crossFreqInteraction = crossFreqInteraction ./ normalizer;
% 
%     % do cross-frequency plots
%     interactionPlot(t, lags/fs, crossFreqInteraction(ofInterest, :, :), ...
%         [round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % smoothing window width
%         .25*[round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % gaussian std dev
%         preDur, fbDur);
%     ylabel('lag (sec) [neg implies hg leads]');
%     xlabel('time(sec)');
%     title(sprintf('Cross-freqeuncy interaction (hg<->beta) at CTL ([up&hit]&&early): %s', sid));
%     SaveFig(fullfile(pwd, 'figures'), sprintf('%s-xfreq-good', sid), 'png');
%     
%     interactionPlot(t, lags/fs, crossFreqInteraction(ofInterest, :, :), ...
%         [round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % smoothing window width
%         .25*[round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % gaussian std dev
%         preDur, fbDur);
%     ylabel('lag (sec) [neg implies hg leads]');
%     xlabel('time(sec)');
%     title(sprintf('Cross-freqeuncy interaction (hg<->beta) at CTL ([up&miss]||down||late): %s', sid));
%     SaveFig(fullfile(pwd, 'figures'), sprintf('%s-xfreq-bad', sid), 'png');
%     toc
    
    %% cross-electrode hg interactions
    hgInteraction = zeros(size(p_hg, 1), size(c_hg, 2), 2*maxLag + 1, size(c_hg, 1));
    [onsetSamples, modulationDepths] = findHGOnsets(c_hg, t, fs);

    for chanIdx = 1:size(p_hg, 1)
        fprintf('  calculating cross electrode interactions (%d of %d): ', chanIdx, size(p_hg, 1)); tic    
        p_hg_temp = single(squeeze(p_hg(chanIdx, :, :)));
        p_hg_temp = GaussianSmooth(p_hg_temp, 0.05*fs);
        p_hg_temp = p_hg_temp - repmat(mean(p_hg_temp, 1), [size(p_hg_temp, 1), 1]);        
        
        for epochIdx = 1:size(c_hg, 2)
            hgInteraction(chanIdx, epochIdx, :, :) = stwc(c_hg(:, epochIdx), p_hg_temp(:, epochIdx), winWidth, maxLag);            
        end
%         normalizer = permute(repmat(c_hg_vars .* squeeze(p_hg_vars(chanIdx, :, :)), [1 1 size(hgInteraction, 3)]), [2 3 1]);
%         hgInteraction(chanIdx, :, :, :) = squeeze(hgInteraction(chanIdx, :, :, :)) ./ normalizer;
        
        % do cross-electrode plots
%         interactionPlot(t, lags/fs, squeeze(hgInteraction(chanIdx, ofInterest, :, :)), ...
%             [round(size(hgInteraction, 3)/20) round(size(hgInteraction, 4)/140)], ... % smoothing window width
%             .6*[round(size(hgInteraction, 3)/20) round(size(hgInteraction, 4)/140)], ... % gaussian std dev
%             preDur, fbDur);

        tempInteractions = squeeze(hgInteraction(chanIdx, :, :, :));
        [alignedInteractions, t_relOnset] = alignByOnset(tempInteractions, onsetSamples, t);
        
        for c = 1:2
            switch (c)
                case 1
                    idx = early;
                    str = 'early up hit';
                case 2
                    idx = late;
                    str = 'late up hit';
            end
            
            subplot(2,1,c);
            interactionPlot(t_relOnset, lags/fs, alignedInteractions(idx, : ,:), ...
                [], ... % smoothing window width
                [] ... % gaussian std dev
                );
            vline([0 -mean(t(onsetSamples))],'k:');
            hline(0, 'k--');
            ylabel('lag (sec) [neg implies ctl leads]');
            xlabel('time(sec)');
            title(sprintf('Cross-electrode interaction (%d<->%d) (%s): %s', cchan, trs(chanIdx), str, sid));
        end
        
        set(gcf, 'pos', [ 560   109   515   839]);
        
        SaveFig(fullfile(pwd, 'figures'), sprintf('%s-%d-xtrode', sid, chanIdx), 'png');

        toc
    end
    
%     %% cross-electrode, cross-frequency interactions
%     betaInteraction = zeros(size(p_hg, 1), size(c_beta, 2), 2*maxLag + 1, size(c_beta, 1));
%     for chanIdx = 1:size(p_hg, 1)
%         fprintf('  calculating cross electrode, cross frequency interactions (%d of %d): ', chanIdx, size(p_hg, 1)); tic    
%         p_hg_temp = single(squeeze(p_hg(chanIdx, :, :)));
%         p_hg_temp = p_hg_temp - repmat(mean(p_hg_temp, 1), [size(p_hg_temp, 1), 1]);        
%         
%         for epochIdx = 1:size(c_hg, 2)
%             betaInteraction(chanIdx, epochIdx, :, :) = stwc(c_beta(:, epochIdx), p_hg_temp(:, epochIdx), winWidth, maxLag);            
%         end
%         normalizer = permute(repmat(c_beta_vars .* squeeze(p_hg_vars(chanIdx, :, :)), [1 1 size(betaInteraction, 3)]), [2 3 1]);
%         betaInteraction(chanIdx, :, :, :) = squeeze(betaInteraction(chanIdx, :, :, :)) ./ normalizer;
% 
%         % do cross-electrode plots
%         interactionPlot(t, lags/fs, squeeze(betaInteraction(chanIdx, ofInterest, :, :)), ...
%             [round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % smoothing window width
%             .25*[round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % gaussian std dev
%             preDur, fbDur);
%         ylabel('lag (sec) [neg implies ctl leads]');
%         xlabel('time(sec)');
%         title(sprintf('Cross-electrode cross-frequency interaction (ctl<->pMV) ([up&hit]&&early): %s', sid));
%         SaveFig(fullfile(pwd, 'figures'), sprintf('%s-%d-xtrodefreq-good', sid, chanIdx), 'png');
% 
%         interactionPlot(t, lags/fs, squeeze(betaInteraction(chanIdx, ~ofInterest, :, :)), ...
%             [round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % smoothing window width
%             .25*[round(size(crossFreqInteraction, 2)/5) round(size(crossFreqInteraction, 3)/35)], ... % gaussian std dev
%             preDur, fbDur);
%         ylabel('lag (sec) [neg implies ctl leads]');
%         xlabel('time(sec)');
%         title(sprintf('Cross-electrode cross-frequency interaction (ctl<->pMV) ([up&miss]||down||late): %s', sid));
%         SaveFig(fullfile(pwd, 'figures'), sprintf('%s-%d-xtrodefreq-bad', sid, chanIdx), 'png');
%         
%         toc
%     end              
    
    close all;
    
    clearvars -except SIDS sIdx trodesOfInterest
end