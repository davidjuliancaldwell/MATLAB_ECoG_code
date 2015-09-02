%%
Z_Constants;
addpath ./scripts;

RESPONSE_TIME = 0; % response time in seconds
FORGET_TIME = 0;

%% perform analyses
load(fullfile(META_DIR, 'areas.mat'));

ctr = 0;
for zid = SIDS
    sid = zid{:};
    ctr = ctr + 1;
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
    load(fullfile(META_DIR, [sid '_epochs']));
    ups = tgts == 1;
    
    resultsFilepath = fullfile(META_DIR, [sid '_results']);
    toc;
    
    if(strcmp(sid,'26cb98'))
        bads = union(bads, 82);
    end
        
    %% Generate time series of ups vs down trials
    fprintf(' performing timeseries analyses: ');
    tic;
    
    % generate mean and sem values for all non-bad electrodes, based on
    % ups vs downs
    muUp_hg   = squeeze(mean(epochs_hg(:, ups, :), 2));
    muDown_hg   = squeeze(mean(epochs_hg(:, ~ups, :), 2));
    
    semUp_hg   = squeeze(sem(epochs_hg(:, ups, :), 2));
    semDown_hg   = squeeze(sem(epochs_hg(:, ~ups, :), 2));
        
    % save them to the results file
    if (exist(resultsFilepath, 'file'))
        save(resultsFilepath, '-append', 'mu*', 'sem*');
    else
        save(resultsFilepath, 'mu*', 'sem*');
    end
    toc;    
    
    %% perform analyses for mean activation by trial type in the pre phase and the fb phase    
    % perform analyses for mean activation comparing rest to pre for all
    % trial types
    
    fprintf(' performing epoch-based analyses: ');
    tic;
    
    restT = t < -preDur;
    preT = t > -preDur & t <=0;
    fbT = t > 0 & t <= fbDur;
    
    % aggregate the samples from each epoch
    rest_hg = mean(epochs_hg(:,:,restT), 3);
    pre_hg   = mean(epochs_hg(:,:,preT), 3);
    fb_hg   = mean(epochs_hg(:,:,fbT), 3);

  
    
%     % perform statistical analyses
    [taskfH_hg, taskfP_hg, taskfT_hg] = epochStats(fb_hg, rest_hg, bads, 'fdr');
    [taskfuH_hg, taskfuP_hg, taskfuT_hg] = epochStats(fb_hg(:, ups), rest_hg, bads, 'fdr');    
    [taskfdH_hg, taskfdP_hg, taskfdT_hg] = epochStats(fb_hg(:, ~ups), rest_hg, bads, 'fdr');

    % perform electrode classification
    %   class = 0 if taskfH_hg | taskfH_hg & taskfT_hg < 0
    %   class = 1 if control like (up modulated for just up targets)
    %   class = 2 if effort (up modulated for both up and down targets)
    class = NaN*zeros(size(rest_hg, 1), 1);
    class(~taskfH_hg | (taskfH_hg & taskfT_hg < 0)) = 0;
    class(taskfuH_hg & taskfuT_hg > 0 ) = 1;
    class((taskfuH_hg & taskfuT_hg >0 ) & (taskfdH_hg & taskfdT_hg > 0)) = 2;
%     electrodeClass = taskfH_gh 
    
    save(resultsFilepath, 'rest*', 'pre*', 'fb*', 'task*', 'cchan', 'class');
    
    toc;   
end