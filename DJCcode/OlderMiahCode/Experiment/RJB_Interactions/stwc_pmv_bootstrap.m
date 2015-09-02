Z_Constants;
addpath ./scripts



%%

N = 100;

warning ('just running for one subject');

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    fprintf('  loading data: '); tic;
    load(fullfile(META_DIR, sprintf('%s_extracted.mat', sid)));
    toc;
    
%     fprintf('estimated time completing this subject: %s\n', datestr(now+(5*(size(p_hg,1)*10/(1*24*60)))));
        
    % perform covariance analses
    winWidthSec = .500;
    winWidth = ceil(winWidthSec * fs);
    maxLagSec = .30;
    maxLag = ceil(maxLagSec * fs);
    lags = -maxLag:maxLag;
    method = 'corr';

    windowFunction = single(ones(winWidth+1, 1));
    
    %% cross-electrode hg interactions

    tkeepi = t > -preDur & t < fbDur;
    tkeepN = sum(tkeepi);
    tkeep = t(tkeepi);

    for chanIdx = 2:size(hg, 1)
        maxes = zeros(5, 9, N);
        mins  = zeros(5, 9, N);

        fprintf('  simulating interactions (%d of %d): ', chanIdx-1, size(hg, 1)-1); tic                

        for n = 1:N                                 
            interactions = zeros(5, size(hg, 2), 2*maxLag + 1, tkeepN);
            
            for epochIdx = 1:size(hg, 2)

                c_hg = scramblePhase(squeeze(hg(1, epochIdx, :)));
                c_beta = scramblePhase(squeeze(beta(1, epochIdx, :)));
                c_alpha = scramblePhase(squeeze(alpha(1, epochIdx, :)));

                r_hg = scramblePhase(squeeze(hg(chanIdx, epochIdx, :)));
                r_beta = scramblePhase(squeeze(beta(chanIdx, epochIdx, :)));
                r_alpha = scramblePhase(squeeze(alpha(chanIdx, epochIdx, :)));


                interactions(1, epochIdx, :, :) = ...
                    gausswc(c_hg(tkeepi), r_hg(tkeepi), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(2, epochIdx, :, :) = ...
                    gausswc(c_alpha(tkeepi), r_hg(tkeepi), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(3, epochIdx, :, :) = ...
                    gausswc(c_hg(tkeepi), r_alpha(tkeepi), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(4, epochIdx, :, :) = ...
                    gausswc(c_beta(tkeepi), r_hg(tkeepi), ...
                    winWidth, maxLag, windowFunction, method);            
                interactions(5, epochIdx, :, :) = ...
                    gausswc(c_hg(tkeepi), r_beta(tkeepi), ...
                    winWidth, maxLag, windowFunction, method);            
            end            

            muInts = extractAverageInteractions(interactions(:, randperm(size(interactions, 2)), :, :), tgts, earlies, lates);
            
            maxes(:, :, n) = max(max(muInts, [], 4), [], 3);
            mins(:, :, n)  = min(min(muInts, [], 4), [], 3);
        end

        TouchDir(fullfile(META_DIR, sid));
%         save(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_interactions.mat']), 'interactions', 'winWidth*', 'maxLag*', 'lags', 't', 'method');        
        
        save(fullfile(META_DIR, sid, [num2str(trs(chanIdx)) '_simulations.mat']), 'method', 'N', 'maxes', 'mins');
        
        toc
    end

end