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
    
    % first smooth all of the data segments
    for chanIdx = 1:size(hg, 1)
        hg(chanIdx, :, :) = GaussianSmooth(squeeze(hg(chanIdx, :, :)), round(SMOOTH_TIME_SEC * fs))';
        alpha(chanIdx, :, :) = GaussianSmooth(squeeze(alpha(chanIdx, :, :)), round(SMOOTH_TIME_SEC * fs))';
        beta(chanIdx, :, :) = GaussianSmooth(squeeze(beta(chanIdx, :, :)), round(SMOOTH_TIME_SEC * fs))';
    end
    
    for chanIdx = 2:size(hg, 1)
        fprintf('  calculating interactions (%d of %d): ', chanIdx-1, size(hg, 1)-1); tic    
        
%         interactions = zeros(5, size(hg, 2), 2*maxLag + 1, size(hg, 3));

        all_summer = zeros(5, 2*maxLag + 1, size(hg, 3));
        up_summer = zeros(5, 2*maxLag + 1, size(hg, 3));
        down_summer = zeros(5, 2*maxLag + 1, size(hg, 3));
        interaction = zeros(5, 2*maxLag + 1, size(hg, 3));
                
        for epochIdx = 1:size(hg, 2)
%             interactions(1, epochIdx, :, :) = ...
%                 gausswc(squeeze(hg(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%             interactions(2, epochIdx, :, :) = ...
%                 gausswc(squeeze(alpha(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%             interactions(3, epochIdx, :, :) = ...
%                 gausswc(squeeze(hg(1, epochIdx, :)), squeeze(alpha(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%             interactions(4, epochIdx, :, :) = ...
%                 gausswc(squeeze(beta(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            
%             interactions(5, epochIdx, :, :) = ...
%                 gausswc(squeeze(hg(1, epochIdx, :)), squeeze(beta(chanIdx, epochIdx, :)), ...
%                 winWidth, maxLag, windowFunction, method);            

            interaction(1, :, :) = ...
                gausswc(squeeze(hg(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interaction(2, :, :) = ...
                gausswc(squeeze(alpha(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interaction(3, :, :) = ...
                gausswc(squeeze(hg(1, epochIdx, :)), squeeze(alpha(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interaction(4, :, :) = ...
                gausswc(squeeze(beta(1, epochIdx, :)), squeeze(hg(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            interaction(5, :, :) = ...
                gausswc(squeeze(hg(1, epochIdx, :)), squeeze(beta(chanIdx, epochIdx, :)), ...
                winWidth, maxLag, windowFunction, method);            
            
            if (tgts(epochIdx)==1)
                up_summer = up_summer + interaction;
            else
                down_summer = down_summer + interaction;
            end
            
            all_summer = all_summer + interaction;
        end
        
% %         stwcPlot(t, lags, squeeze(interactions(1, :, :, :)));
%         interactions = extractAverageInteractions(interactions, tgts, earlies, lates);
        interactions = zeros(size(all_summer, 1), 3, size(all_summer, 2), size(all_summer, 3));
        
        interactions(:,1,:,:) = all_summer / length(tgts);
        interactions(:,2,:,:) = up_summer / sum(tgts==1);
        interactions(:,3,:,:) = down_summer / sum(tgts~=1);
        
        % save the file for this channel                
        TouchDir(fullfile(META_DIR, sid));
        save(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_interactions.mat']), 'interactions', 'winWidth*', 'maxLag*', 'lags', 't', 'method');                
        toc;
    end
end