Z_Constants;
addpath ./scripts

%%

load(fullfile(META_DIR, 'areas'));

for sIdx = 1:length(SIDS)
    sid = SIDS{sIdx};
    fprintf('working on %s\n', sid);
    
    %% loading data
    fprintf('  loading data: '); tic    
    load(fullfile(META_DIR, sprintf('%s_epochs.mat', sid)), 'epochs', 't', 'fs', 'tgts', 'ress', '*Dur', 'cchan', 'montage', 'bad_channels', 'bad_marker');
    toc;
    
    %% preprocess data
    fprintf('  preprocessing data: '); tic
  
    allchans = 1:size(epochs, 3);
    allchans(ismember(allchans, cchan) | ismember(allchans, bad_channels))= [];
    
    trs = [cchan; allchans'];
    chanType = ones(size(trs));
    chanType(1) = 0;
    
    % extract the channels of interest, and smooth
    hg = permute(single(squeeze(epochs(3, :, trs, :))), [2 1 3]);
    beta = permute(single(squeeze(epochs(2, :, trs, :))), [2 1 3]);
    alpha = permute(single(squeeze(epochs(1, :, trs, :))), [2 1 3]);        
    
    % for these electrodes, perform classification analyses    
    ups = tgts==1;
    fbT = t > 0 & t <= fbDur;
    restT = t < -preDur;

    fb_hg   = mean(hg(:,:,fbT), 3);
    rest_hg = mean(hg(:,:,restT), 3);

    earlies = 1:ceil(length(tgts)*.25);
    lates = floor(length(tgts)*.75):length(tgts);
    
    upMod = epochStats(fb_hg(:, ups), rest_hg, [], 'fdr');    
    dnMod = epochStats(fb_hg(:, ~ups), rest_hg, [], 'fdr');
        
    % determine electrode locations
    locs = trodeLocsFromMontage(sid, montage, false);
    tlocs = trodeLocsFromMontage(sid, montage, true);

    save(fullfile(META_DIR, sprintf('%s_extracted.mat', sid)), 'hg', 'beta', 'alpha', 'trs', 'chanType', 'locs', 'tlocs', 't', 'fs', 'tgts', 'ress', '*Dur', 'earlies', 'lates');
    toc;    
end

% % % This is the old version that subselected electrodes
% % for sIdx = 1:length(SIDS)
% %     sid = SIDS{sIdx};
% %     fprintf('working on %s\n', sid);
% %     
% %     %% loading data
% %     fprintf('  loading data: '); tic    
% %     load(fullfile(META_DIR, sprintf('%s_epochs.mat', sid)), 'epochs', 't', 'fs', 'tgts', 'ress', '*Dur', 'cchan', 'montage', 'bad_channels', 'bad_marker');
% %     toc;
% %     
% %     %% preprocess data
% %     fprintf('  preprocessing data: '); tic
% %   
% %     % determine which electrodes are going to be analyzed
% %     fromHmat = find(hmats{sIdx} > 0);
% %     fromBA   = find(ismember(bas{sIdx}, 46))';
% % 
% %     fromHmat(fromHmat==cchan) = []; % eliminate the control electrode from this list
% %     fromBA(fromBA==cchan) = []; % eliminate the control electrode from this list
% %     fromHmat(ismember(fromHmat, fromBA)) = []; % let the brodmann area take precedence
% %     
% %     fromHmat(ismember(fromHmat, bad_channels)) = []; % eliminate bad channels from this list
% %     fromBA(ismember(fromBA, bad_channels)) = []; % eliminate bad channels from this list
% %     
% %     trs = [cchan; fromHmat; fromBA];
% %     chanType = [0; ones(size(fromHmat)); 2*ones(size(fromBA))];
% %     chanInfo = [hmats{sIdx}(cchan); hmats{sIdx}(fromHmat); bas{sIdx}(fromBA)'];
% %     
% %     % extract the channels of interest, and smooth
% %     hg = permute(single(squeeze(epochs(3, :, trs, :))), [2 1 3]);
% %     beta = permute(single(squeeze(epochs(2, :, trs, :))), [2 1 3]);
% %     alpha = permute(single(squeeze(epochs(1, :, trs, :))), [2 1 3]);        
% % %     tgts(all(bad_marker)) = [];
% % %     ress(all(bad_marker)) = [];
% %     
% %     for chan = 1:size(hg, 1)
% %         hg(chan, :, :) = GaussianSmooth(squeeze(hg(chan, :, :)), SMOOTH_TIME_SEC*fs)';        
% %         beta(chan, :, :) = GaussianSmooth(squeeze(beta(chan, :, :)), SMOOTH_TIME_SEC*fs)';
% %         alpha(chan, :, :) = GaussianSmooth(squeeze(alpha(chan, :, :)), SMOOTH_TIME_SEC*fs)';
% %     end    
% %     
% %     % for these electrodes, perform classification analyses    
% %     ups = tgts==1;
% %     fbT = t > 0 & t <= fbDur;
% %     restT = t < -preDur;
% % 
% %     fb_hg   = mean(hg(:,:,fbT), 3);
% %     rest_hg = mean(hg(:,:,restT), 3);
% % 
% %     earlies = 1:ceil(length(tgts)*.25);
% %     lates = floor(length(tgts)*.75):length(tgts);
% %     
% %     upMod = epochStats(fb_hg(:, ups), rest_hg, [], 'fdr');    
% %     dnMod = epochStats(fb_hg(:, ~ups), rest_hg, [], 'fdr');
% % 
% %     % perform electrode classification
% %     %   class = 0 if non-modulated (not modulated for up or down targets)
% %     %   class = 1 if control like (modulated for just up targets)
% %     %   class = 2 if effort (modulated for both up and down targets)
% %     %   class = 3 if inverted (modulated for just down targets)
% %     
% %     class = NaN*zeros(size(rest_hg, 1), 1);
% %     
% %     class(~upMod & ~dnMod) = 0;
% %     class( upMod & ~dnMod) = 1;
% %     class( upMod &  dnMod) = 2;
% %     class(~upMod &  dnMod) = 3;
% %     
% %     % drop the non-modulated electrodes
% %     nonmodulated = class == 0;
% %     trs(nonmodulated) = [];
% %     chanType(nonmodulated) = [];
% %     chanInfo(nonmodulated) = [];
% %     hg(nonmodulated, :, :) = [];
% %     beta(nonmodulated, :, :) = [];
% %     alpha(nonmodulated, :, :) = [];
% %     class(nonmodulated) = [];
% %     
% %     % determine electrode locations
% %     locs = trodeLocsFromMontage(sid, montage, false);
% %     locs = locs(trs, :);
% %     tlocs = trodeLocsFromMontage(sid, montage, true);
% %     tlocs = tlocs(trs, :);
% % 
% %     save(fullfile(META_DIR, sprintf('%s_extracted.mat', sid)), 'hg', 'beta', 'alpha', 'trs', 'chanType', 'chanInfo', 'locs', 'tlocs', 't', 'fs', 'tgts', 'ress', '*Dur', 'class', 'earlies', 'lates');
% %     toc;    
% % end