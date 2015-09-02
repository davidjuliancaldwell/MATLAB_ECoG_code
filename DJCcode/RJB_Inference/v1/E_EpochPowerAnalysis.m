%%
Z_Constants;

RESPONSE_TIME = .5; % response time in seconds

%% perform analyses

for zid = SIDS
    sid = zid{:};
    
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
        
%     %% Generate time series of ups vs down trials
%     fprintf(' performing timeseries analyses: ');
%     tic;
%     
%     % generate mean and sem values for all non-bad electrodes, based on
%     % ups vs downs
%     muUp_hg   = squeeze(mean(epochs_hg(:, ups, :), 2));
%     muDown_hg   = squeeze(mean(epochs_hg(:, ~ups, :), 2));
%     
%     semUp_hg   = squeeze(sem(epochs_hg(:, ups, :), 2));
%     semDown_hg   = squeeze(sem(epochs_hg(:, ~ups, :), 2));
%         
%     % save them to the results file
%     if (exist(resultsFilepath, 'file'))
%         save(resultsFilepath, '-append', 'mu*', 'sem*');
%     else
%         save(resultsFilepath, 'mu*', 'sem*');
%     end
%     toc;    
    
    %% perform analyses for mean activation by trial type in the pre phase and the fb phase    
    % perform analyses for mean activation comparing rest to pre for all
    % trial types
    
    fprintf(' performing epoch-based analyses: ');
    tic;
    
    restT = t < -preDur;
%     preT = t > -preDur + RESPONSE_TIME & t <=0;
    preT = t > -preDur & t <=0;
    fbT = t > 0 + RESPONSE_TIME & t <= fbDur;
    
    % aggregate the samples from each epoch
    rest_hg = mean(epochs_hg(:,:,restT), 3);
    pre_hg   = mean(epochs_hg(:,:,preT), 3);
    fb_hg   = mean(epochs_hg(:,:,fbT), 3);
    
    [taskpH_hg, taskpP_hg, taskpT_hg] = epochStats(rest_hg, pre_hg, bads, 'bonf');
    [taskfH_hg, taskfP_hg, taskfT_hg] = epochStats(rest_hg, fb_hg, bads, 'bonf');
%     taskfH_hg(cchan) = 0; taskfP_hg(cchan) = .5; taskfT_hg(cchan) = 0;
    
    % perform statistical analyses
    [preH_hg, preP_hg, preT_hg] = epochStats(pre_hg(:, ups), pre_hg(:, ~ups), bads, 'bonf');    
    [fbH_hg, fbP_hg, fbT_hg] = epochStats(fb_hg(:, ups), fb_hg(:, ~ups), bads, 'bonf');
%     fbH_hg(cchan) = 0; fbP_hg(cchan) = .5; fbT_hg(cchan) = 0;
    
    save(resultsFilepath, '-append', 'pre*', 'fb*', 'task*', 'cchan');
    
    toc;   
end