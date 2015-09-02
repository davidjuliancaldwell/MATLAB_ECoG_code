%%
Z_Constants;

CLEAR_OLD_FILES = true;

%%

for zid = SIDS
    sid = zid{:};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');
    
    tic
    load(fullfile(META_DIR, [sid '_epochs']));
    load(fullfile(META_DIR, [sid '_behavior']), 'outcomeMap', 'finalDistance', 'hitrate', 'hitrateByType', 'successProbabilities');
    toc
    
    resultsFilepath = fullfile(META_DIR, [sid '_neural']);

    if (exist(resultsFilepath, 'file'))
        delete(resultsFilepath);
    end
    
    hits = (tgts == ress);
    
    %% Generate time series of successful and failed trials
    fprintf(' performing timeseries analyses: ');
    
    tic
    
    % generate mean and sem values for all non-bad electrodes, based on
    % hits vs misses
    muHit_hg   = squeeze(mean(epochs_hg(:, hits, :), 2));
    muHit_beta = squeeze(mean(epochs_beta(:, hits, :), 2));
    muHit_lf   = squeeze(mean(epochs_lf(:, hits, :), 2));

    muMiss_hg   = squeeze(mean(epochs_hg(:, ~hits, :), 2));
    muMiss_beta = squeeze(mean(epochs_beta(:, ~hits, :), 2));
    muMiss_lf   = squeeze(mean(epochs_lf(:, ~hits, :), 2));
    
    semHit_hg   = squeeze(sem(epochs_hg(:, hits, :), 2));
    semHit_beta = squeeze(sem(epochs_beta(:, hits, :), 2));
    semHit_lf   = squeeze(sem(epochs_lf(:, hits, :), 2));

    semMiss_hg   = squeeze(sem(epochs_hg(:, ~hits, :), 2));
    semMiss_beta = squeeze(sem(epochs_beta(:, ~hits, :), 2));
    semMiss_lf   = squeeze(sem(epochs_lf(:, ~hits, :), 2));
        
    % save them to the results file
    if (exist(resultsFilepath, 'file'))
        save(resultsFilepath, '-append', 'mu*', 'sem*');
    else
        save(resultsFilepath, 'mu*', 'sem*');
    end
    
    toc
    
    %% perform analyses for mean activation by band before and after trial end
    fprintf(' performing epoch-based analyses: ');
    tic
    
    % aggregate the samples from each epoch
    preT = t > (fbDur - .5) & t < fbDur; % 500 msec before fb ends
    postT = t > (fbDur) & t < fbDur + .5; % 500 msec after fb ends
    
    pre_hg   = mean(epochs_hg(:,:,preT), 3);
    pre_beta   = mean(epochs_beta(:,:,preT), 3);
    pre_lf   = mean(epochs_lf(:,:,preT), 3);

    post_hg   = mean(epochs_hg(:,:,postT), 3);
    post_beta   = mean(epochs_beta(:,:,postT), 3);
    post_lf   = mean(epochs_lf(:,:,postT), 3);
    
    % perform statistical analyses
    [preH_hg, preP_hg, preT_hg] = epochStats(pre_hg(:, hits), pre_hg(:, ~hits), bads, 'fdr');
    [preH_beta, preP_beta, preT_beta] = epochStats(pre_beta(:, hits), pre_beta(:, ~hits), bads, 'fdr');
    [preH_lf, preP_lf, preT_lf] = epochStats(pre_lf(:, hits), pre_lf(:, ~hits), bads, 'fdr');
    
    [postH_hg, postP_hg, postT_hg] = epochStats(post_hg(:, hits), post_hg(:, ~hits), bads, 'fdr');
    [postH_beta, postP_beta, postT_beta] = epochStats(post_beta(:, hits), post_beta(:, ~hits), bads, 'fdr');
    [postH_lf, postP_lf, postT_lf] = epochStats(post_lf(:, hits), post_lf(:, ~hits), bads, 'fdr');
        
    save(resultsFilepath, '-append', 'pre*', 'post*');
    
    toc
    
    %% Stratify these values by error severity (after trial end)
    fprintf(' performing error severity analyses: ');
    tic

    % we are correlating epoch average neural features with the severity of
    % error when the trial ends
    [sevRho_hg, sevP_hg] = corr(post_hg(:, ~hits)', finalDistance(~hits)');
    [~, sevH_hg] = fdr(sevP_hg, 0.05);
    
    [sevRho_beta, sevP_beta] = corr(post_beta(:, ~hits)', finalDistance(~hits)');
    [~, sevH_beta] = fdr(sevP_beta, 0.05);
    
    [sevRho_lf, sevP_lf] = corr(post_lf(:, ~hits)', finalDistance(~hits)');
    [~, sevH_lf] = fdr(sevP_lf, 0.05);
    
    save(resultsFilepath, '-append', 'sev*');

    toc
    
    %% Or correlate with outcome probability (before trial end)
    fprintf(' performing outcome probability analyses: ');
    tic
    
    return;
    fbt = t(t > 0 & t <= fbDur);
    pTemp = successProbabilities{2};
    pHit = pTemp(:, find(fbt > (fbDur - 0.5), 1));
    
    
    %
    
    toc
    
    return;
end
