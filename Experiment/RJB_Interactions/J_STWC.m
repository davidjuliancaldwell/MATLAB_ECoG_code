addpath ./scripts
Z_Constants;

FORCE = false;
%%

% allsids = [3 6 7 10];
% for sIdx = allsids    
for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    fprintf('  loading data: '); tic;
    load(fullfile(META_DIR, [sid '_extracted']));
    toc;
    
%     trodes = trodes([1 end]);
%     alpha = alpha([1 end], : ,:);
%     beta = beta([1 end], : ,:);
%     hg = hg([1 end], : ,:);
    
    %% interaction analyses
    winWidthSec = .500;
    winWidth = ceil(winWidthSec * fs);
    maxLagSec = .30;
    maxLag = ceil(maxLagSec * fs);
    lags = -maxLag:maxLag;
    method = 'corr';
    windowFunction = single(ones(winWidth+1, 1));    

    hg = permute(single(hg), [1 3 2]);
    beta = permute(single(beta), [1 3 2]);
    alpha = permute(single(alpha), [1 3 2]);
    
    c_hg = squeeze(hg(1,:,:));
    c_beta = squeeze(beta(1,:,:));
    c_alpha = squeeze(alpha(1,:,:));

    for chanIdx = 2:size(hg, 1)
        idx = chanIdx - 1;                        
        fprintf('  calculating cross electrode interactions (%d of %d): ', idx, size(hg, 1)-1); tic    

        ofile = fullfile(META_DIR, sid, [sid, '_interactions_' num2str(trodes(chanIdx)) '.mat']);
        
        if (~exist(ofile, 'file') || FORCE)
            r_hg = squeeze(hg(chanIdx, :, :));
            r_beta = squeeze(beta(chanIdx, :, :));
            r_alpha = squeeze(alpha(chanIdx, :, :));

            interactions = zeros(5, size(hg, 3), 2*maxLag + 1, size(hg, 2));        

            for epochIdx = 1:size(interactions, 2)
                interactions(1, epochIdx, :, :) = gausswc(c_hg(:, epochIdx),    r_hg(:, epochIdx), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(2, epochIdx, :, :) = gausswc(c_hg(:, epochIdx),    r_beta(:, epochIdx), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(3, epochIdx, :, :) = gausswc(c_hg(:, epochIdx),    r_alpha(:, epochIdx), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(4, epochIdx, :, :) = gausswc(c_beta(:, epochIdx),  r_hg(:, epochIdx), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(5, epochIdx, :, :) = gausswc(c_alpha(:, epochIdx), r_hg(:, epochIdx), ...
                    winWidth, maxLag, windowFunction, method);                            
            end

            alignedInteractions = []; 
            [alignedInteractions(1, :, :, :), alignedT] = alignInteractionsByOnset(squeeze(interactions(1, :, :, :)), onsetSamples, t);
            [alignedInteractions(2, :, :, :), ~       ] = alignInteractionsByOnset(squeeze(interactions(2, :, :, :)), onsetSamples, t);
            [alignedInteractions(3, :, :, :), ~       ] = alignInteractionsByOnset(squeeze(interactions(3, :, :, :)), onsetSamples, t);
            [alignedInteractions(4, :, :, :), ~       ] = alignInteractionsByOnset(squeeze(interactions(4, :, :, :)), onsetSamples, t);
            [alignedInteractions(5, :, :, :), ~       ] = alignInteractionsByOnset(squeeze(interactions(5, :, :, :)), onsetSamples, t);

            % do the compression and saving here on a channel by channel
            % basis

            early = false(size(interactions, 2), 1);
            late = false(size(interactions, 2), 1);

            mid = floor(size(interactions, 2) / 2);
            early(1:mid) = true;
            late((mid+1):end) = true;

            mInt = squeeze(mean(interactions, 2));
            mIntEarly = squeeze(mean(interactions(:, early, :, :), 2));
            mIntLate  = squeeze(mean(interactions(:,  late, :, :), 2));

            mAlInt = squeeze(mean(alignedInteractions, 2));
            mAlIntEarly = squeeze(mean(alignedInteractions(:, early, :, :), 2));
            mAlIntLate  = squeeze(mean(alignedInteractions(:,  late, :, :), 2));

            TouchDir(fullfile(META_DIR, sid));
            save(fullfile(META_DIR, sid, [sid, '_interactions_' num2str(trodes(chanIdx)) '.mat']), 'winWidth*', 'maxLag*', 'lags', 'method', 'windowFunction', 't', 'alignedT', 'mInt*', 'mAlInt*', 'early', 'late');

            alignedInteractions = squeeze(alignedInteractions(1,:,:,:));
            save(fullfile(META_DIR, sid, ['all_' sid '_interactions_' num2str(trodes(chanIdx)) '.mat']), 'alignedInteractions', 'alignedT', 'lags', 'fs', 'early', 'late');
        end
        
        toc

    end                       
end


%% some plotting stuff that I'm not currently using
% %             for c = 1:2
% %                 switch (c)
% %                     case 1
% %                         idx = earlies;
% %                         str = 'early up hit';
% %                     case 2
% %                         idx = lates;
% %                         str = 'late up hit';
% %                 end
% % 
% %                 subplot(2,1,c);
% %                 interactionPlot(t_relOnset, lags/fs, alignedInteractions(idx, : ,:));
% %                
% %                 vline([0 -mean(t(onsetSamples))],'k:');
% %                 hline(0, 'k--');
% %                 ylabel('lag (sec) [neg implies ctl leads]');
% %                 xlabel('time(sec)');
% %                 title(sprintf('Cross-electrode interaction (%d<->%d) (%s): %s', cchan, trs(chanIdx), str, sid));
% %             end
% % 
% %             set(gcf, 'pos', [  560   109   689   839]);
% 
%             interactionPlot(t_relOnset, lags/fs, alignedInteractions(:, : ,:));
%             axis xy;
%             
%             vline([0 -mean(t(onsetSamples))],'k:');
%             hline(0, 'k--');
%             ylabel('lag (sec) [neg implies ctl leads]');
%             xlabel('time(sec)');
%             title(sprintf('Cross-electrode interaction (%d<->%d): %s', cchan, trs(chanIdx), sid));
% 
%             SaveFig(fullfile(pwd, 'figures'), sprintf('%s-%d-xtrode', sid, chanIdx), 'png');
