Z_Constants;

addpath ./scripts;

%% make the performance plot

for c = 1:length(SIDS);
    sid = SIDS{c};
    fprintf('working on subject %s\n', sid);

    load(fullfile(META_DIR, [sid '_epochs.mat']), 'epochs', 't', '*Dur', 'ress');
    
    prefeats = mean(epochs(:, :, :, t > -preDur + PRE_RT_SEC & t <= 0), 4);
    fbfeats  =  mean(epochs(:, :, :, t > 0 + FB_RT_SEC & t <= fbDur), 4);
%     fbfeats  =  mean(epochs(:, :, :, t > 0 + FB_RT_SEC & t <= fbDur), 4);
    
    save(fullfile(META_DIR, [sid '_epochs.mat']), '-append', '*feats');
end
