%%
Z_Constants;
addpath ./scripts;

%%

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    fprintf('  loading data: '); tic;
    load(fullfile(META_DIR, sprintf('%s_extracted.mat', sid)));    
    toc;
    
    % perform covariance analses
    winWidthSec = .500;
    winWidth = ceil(winWidthSec * fs);
    maxLagSec = .30;
    maxLag = ceil(maxLagSec * fs);
    lags = -maxLag:maxLag;
    method = 'corr';

    windowFunction = single(ones(winWidth+1, 1));

    % we will perform the covariance analyses 5 times
    % looking at the following
    %
    %    _CTL_    _REMOTE_
    %    HG       HG
    %    ALPHA    HG
    %    HG       ALPHA
    %    BETA     HG
    %    HG       BETA
    
    for chanIdx = 2:size(hg, 1)
        fprintf('  calculating interactions (%d of %d): \n', chanIdx-1, size(hg, 1)-1); tic    

        interactions = zeros(5, size(hg, 2), 2*maxLag + 1, size(hg, 3));

        for epochIdx = 1:size(hg, 2)
            interactions(1, epochIdx, :, :) = ...
                gausswc(squeeze(hg(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interactions(2, epochIdx, :, :) = ...
                gausswc(squeeze(alpha(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interactions(3, epochIdx, :, :) = ...
                gausswc(squeeze(hg(1, epochIdx, :)), squeeze(alpha(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interactions(4, epochIdx, :, :) = ...
                gausswc(squeeze(beta(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interactions(5, epochIdx, :, :) = ...
                gausswc(squeeze(hg(1, epochIdx, :)), squeeze(beta(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
        end

%         stwcPlot(t, lags, squeeze(interactions(1, :, :, :)));
        interactions = extractAverageInteractions(interactions, tgts, earlies, lates);
        % save the file for this channel
        TouchDir(fullfile(META_DIR, sid));
        save(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_interactions.mat']), 'interactions', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
        toc;
    end
    
    
%     %% cross-electrode hg interactions
%     hghgInteraction = zeros(size(hg, 1)-1, size(hg, 2), 2*maxLag + 1, size(hg, 3));
% 
%     for chanIdx = 2:size(hg, 1)
%         fprintf('  calculating hg-hg cross electrode interactions (%d of %d): \n', chanIdx-1, size(hg, 1)-1); tic    
% 
%         for epochIdx = 1:size(hg, 2)
%             hghgInteraction(chanIdx-1, epochIdx, :, :) = ...
%                 gausswc(squeeze(hg(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%         end
%     end
% 
%     save(fullfile(META_DIR, [sid, '_hghg_interactions.mat']), '-v7.3', 'hghgInteraction', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
%     clear *Interaction
%     
%     %% alpha at control to hg elsewhere
%     alphahgInteraction = zeros(size(hg, 1)-1, size(hg, 2), 2*maxLag + 1, size(hg, 3));
% 
%     for chanIdx = 2:size(hg, 1)
%         fprintf('  calculating alpha-hg cross electrode interactions (%d of %d): \n', chanIdx-1, size(hg, 1)-1); tic    
% 
%         for epochIdx = 1:size(hg, 2)
%             alphahgInteraction(chanIdx-1, epochIdx, :, :) = ...
%                 gausswc(squeeze(alpha(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%         end
%     end    
% 
%     save(fullfile(META_DIR, [sid, '_alphahg_interactions.mat']), '-7.3','alphahgInteraction', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
%     clear *Interaction
%     
%     %% hg at control to alpha elsewhere
%     hgalphaInteraction = zeros(size(hg, 1)-1, size(hg, 2), 2*maxLag + 1, size(hg, 3));
% 
%     for chanIdx = 2:size(hg, 1)
%         fprintf('  calculating hg-alpha cross electrode interactions (%d of %d): \n', chanIdx-1, size(hg, 1)-1); tic    
% 
%         for epochIdx = 1:size(hg, 2)
%             hgalphaInteraction(chanIdx-1, epochIdx, :, :) = ...
%                 gausswc(squeeze(hg(1, epochIdx, :)), squeeze(alpha(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%         end
%     end    
%     
%     save(fullfile(META_DIR, [sid, '_hgalpha_interactions.mat']), '-7.3','hgalphaInteraction', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
%     clear *Interaction
%     
%     %% beta at control to hg elsewhere
%     betahgInteraction = zeros(size(hg, 1)-1, size(hg, 2), 2*maxLag + 1, size(hg, 3));
% 
%     for chanIdx = 2:size(hg, 1)
%         fprintf('  calculating beta-hg cross electrode interactions (%d of %d): \n', chanIdx-1, size(hg, 1)-1); tic    
% 
%         for epochIdx = 1:size(hg, 2)
%             betahgInteraction(chanIdx-1, epochIdx, :, :) = ...
%                 gausswc(squeeze(alpha(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%         end
%     end    
%     
%     save(fullfile(META_DIR, [sid, '_betahg_interactions.mat']), '-7.3','betahgInteraction', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
%     clear *Interaction
%     
%     %% hg at control to alpha elsewhere
%     hgbetaInteraction = zeros(size(hg, 1)-1, size(hg, 2), 2*maxLag + 1, size(hg, 3));
% 
%     for chanIdx = 2:size(hg, 1)
%         fprintf('  calculating hgbeta cross electrode interactions (%d of %d): \n', chanIdx-1, size(hg, 1)-1); tic    
% 
%         for epochIdx = 1:size(hg, 2)
%             hgbetaInteraction(chanIdx-1, epochIdx, :, :) = ...
%                 gausswc(squeeze(hg(1, epochIdx, :)), squeeze(alpha(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%         end
%     end    
% 
%     save(fullfile(META_DIR, [sid, '_hgbeta_interactions.mat']), '-7.3','hgbetaInteraction', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
%     clear *Interaction        
end