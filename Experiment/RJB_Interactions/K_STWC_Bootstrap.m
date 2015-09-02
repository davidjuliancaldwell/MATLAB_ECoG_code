addpath ./scripts
Z_Constants;

% number of bootstrapped repetitions to calculate
N = 100;
FORCE = false;

%%
h = tic;

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

    % let's try running this only on a subset of the time window to save
    % some time...
    t0 = find(t>=0, 1, 'first');
    t1 = find(t<1, 1,'last');

    t0 = t0 - winWidth - maxLag - .5*fs;
    t1 = t1 + winWidth + maxLag + .5*fs;

    t = t(t0:t1);
    hg = hg(:,:,t0:t1);
    beta = beta(:, :, t0:t1);
    alpha = alpha(:, :, t0:t1);
    
    % end this section
    
    hg = permute(single(hg), [1 3 2]);
    beta = permute(single(beta), [1 3 2]);
    alpha = permute(single(alpha), [1 3 2]);
    
    c_hg = squeeze(hg(1,:,:));
    c_beta = squeeze(beta(1,:,:));
    c_alpha = squeeze(alpha(1,:,:));
     
    ti = t>=0 & t<1;    
    
    for chanIdx = 2:size(hg, 1)
        idx = chanIdx - 1;                        
        fprintf('  calculating cross electrode interactions (%d of %d)\n', idx, size(hg, 1)-1);   

        ofile = fullfile(META_DIR, sid, [sid, '_simulations_' num2str(trodes(chanIdx)) '.mat']);

        if (~exist(ofile, 'file') || FORCE)            
            maxes = zeros(5, N);
            maxesEarly = zeros(5, N);
            maxesLate = zeros(5, N);

            mins = zeros(5, N);
            minsEarly = zeros(5, N);
            minsLate = zeros(5, N);

            for n = 1:N
                fprintf('    iteration %d of %d\n', n, N);

                % shuffle the trials when we pull them in
                r_hg = squeeze(hg(chanIdx, :, randperm(size(hg, 3))));
                r_beta = squeeze(beta(chanIdx, :, randperm(size(hg, 3))));
                r_alpha = squeeze(alpha(chanIdx, :, randperm(size(hg, 3))));

                interactions = zeros(2*maxLag + 1, size(hg, 2), size(hg, 3), 5);        

                for epochIdx = 1:size(interactions, 3)
                    interactions(:, :, epochIdx, 1) = gausswc(single(scramblePhase(c_hg(:, epochIdx))),    single(scramblePhase(r_hg(:, epochIdx))), ...
                        winWidth, maxLag, windowFunction, method);            
                    interactions(:, :, epochIdx, 2) = gausswc(single(scramblePhase(c_hg(:, epochIdx))),    single(scramblePhase(r_beta(:, epochIdx))), ...
                        winWidth, maxLag, windowFunction, method);            
                    interactions(:, :, epochIdx, 3) = gausswc(single(scramblePhase(c_hg(:, epochIdx))),    single(scramblePhase(r_alpha(:, epochIdx))), ...
                        winWidth, maxLag, windowFunction, method);            
                    interactions(:, :, epochIdx, 4) = gausswc(single(scramblePhase(c_beta(:, epochIdx))),  single(scramblePhase(r_hg(:, epochIdx))), ...
                        winWidth, maxLag, windowFunction, method);            
                    interactions(:, :, epochIdx, 5) = gausswc(single(scramblePhase(c_alpha(:, epochIdx))), single(scramblePhase(r_hg(:, epochIdx))), ...
                        winWidth, maxLag, windowFunction, method);                            
                end

                % do the compression and saving here on a channel by channel
                % basis

                early = false(size(interactions, 3), 1);
                late = false(size(interactions, 3), 1);

                mid = floor(size(interactions, 3) / 2);
                early(1:mid) = true;
                late((mid+1):end) = true;

                mInt = squeeze(mean(interactions, 3));
                mIntEarly = squeeze(mean(interactions(:, :, early, :), 3));
                mIntLate  = squeeze(mean(interactions(:, :,  late, :), 3));

                maxes(:, n) = max(max(mInt(:,ti,:), [], 1), [], 2);
                mins(:, n) = min(min(mInt(:,ti,:), [], 1), [], 2);
                maxesEarly(:, n) = max(max(mIntEarly(:,ti,:), [], 1), [], 2);
                minsEarly(:, n) = min(min(mIntEarly(:,ti,:), [], 1), [], 2);
                maxesLate(:, n) = max(max(mIntLate(:,ti,:), [], 1), [], 2);
                minsLate(:, n) = min(min(mIntLate(:,ti,:), [], 1), [], 2);
            end        

            TouchDir(fullfile(META_DIR, sid));
            save(fullfile(META_DIR, sid, [sid, '_simulations_' num2str(trodes(chanIdx)) '.mat']), 'maxes*', 'mins*');    
        end        
    end                
end

toc(h)

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
