%%
Z_Constants;
addpath ./scripts;

SIDS(strcmp(SIDS, '38e116')) = [];

%%
rt = [];
rts = [];
hitrates = [];

for ctr = 1:length(SIDS)
    sid = SIDS{ctr};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject    
    
    load(fullfile(META_DIR, [sid '_results.mat']), 'onsetSamples');
    load(fullfile(META_DIR, [sid '_extracted']), 'fs','t');
    
    rt(ctr) = t(round(mean(onsetSamples)));
    rts(ctr) = std(t(onsetSamples), [], 2);
    
    load(fullfile(META_DIR, [sid '_epochs.mat']), 'tgts', 'ress', 'src_files', 'bad_marker');
    good_trials = ~all(bad_marker);
    hitrates(ctr) = mean(tgts(good_trials)==ress(good_trials));
    
end

%%
mu = mean(rt);
sig = std(rt,[],2);
fprintf('average reaction time is %0.3f msec (+/- %0.3f msec std)\n', mu, sig);

%%
[rho, p] = corr(rt', hitrates')
scatter(rt, hitrates)
rho^2
