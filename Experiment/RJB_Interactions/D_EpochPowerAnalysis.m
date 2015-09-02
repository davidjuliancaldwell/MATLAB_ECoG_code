%%
Z_Constants;
addpath ./scripts;

RESPONSE_TIME = 0.500; % response time in seconds
FORGET_TIME = 0;

%% perform analyses

for zid = SIDS
    sid = zid{:};
    
    fprintf('working on subject %s\n', sid);
    
    %% set up to work on this subject
    fprintf(' loading data: ');    
    tic;
    load(fullfile(META_DIR, [sid '_epochs']));
    bas = basFromMontage(sid, montage);
    hmats = hmatsFromMontage(sid, montage);    
    tlocs = trodeLocsFromMontage(sid, montage, true);
    hmat_key = hmatKey();
    
    %% perform analyses for mean activation by trial type in the fb phase        
    fprintf(' performing epoch-based analyses: ');
    tic;
    
    restT = t < -preDur;
    fbT = t > (0+RESPONSE_TIME) & t <= fbDur;
    
    % aggregate the samples from each epoch
    rest_hg = mean(epochs_hg(:,~all(bad_marker),restT), 3);
    fb_hg   = mean(epochs_hg(:,~all(bad_marker),fbT), 3);
      
    [snr_e, snr_l, groupRes, regRes] = calculateSNRs(epochs_hg, bad_marker, bad_channels, tgts, t, preDur, fbDur, RESPONSE_TIME);

    mtit(sid)
    SaveFig(pwd,['reg-' sid], 'eps', '-r300');
    SaveFig(pwd,['reg-' sid], 'png', '-r300');
    close;
    
    % perform statistical analyses
    [fH, fP, fT] = epochStats(fb_hg, rest_hg, bad_channels, 'fdr');
    [fuH, fuP, fuT] = epochStats(fb_hg(:, tgts(~all(bad_marker))==1), rest_hg, bad_channels, 'fdr');    

    % determine whether there was a big change for up targets during fb
    fb_up_hg = fb_hg(:, tgts(~all(bad_marker))==1);
    early = false(1, size(fb_up_hg, 2));
    early(1:round(length(early)/2)) = true;
    
    [fluH, fluP, fluT] = epochStats(fb_up_hg(:, early), fb_up_hg(:, ~early), bad_channels, 'fdr');
    
    % perform electrode classification
    %   class = NaN -> 'bad'
    %   class = 0 -> 'non-modulated'
    %     ~(fH | fuH)
    %   class = 1 -> 'control-related'
    %     fuH & ~fH
    %   class = 2 -> 'effort-related'
    %     fH
    
    class = -1*ones(size(rest_hg, 1), 1); % set to negative ones so we see if we've screwed up
    class(~(fH | fuH)) = 0;
    class(fuH & ~fH) = 1;
    class(fH) = 2;
    class(bad_channels) = NaN;
    
    if (any(class==-1))
        error('misclassified electrodes');
    end
    
    save(fullfile(META_DIR, [sid '_results']), 'tlocs', 'bas', 'hmats', 'class', 'fH', 'fP', 'fT', 'fuH', 'fuP', 'fuT', 'rest_hg', 'fb_hg', 'hmat_key', 'flu*', 'snr*', 'groupRes', 'regRes');
    
%     % if DBG
%     figure
%     PlotDotsDirect(sid, montage.MontageTrodes, class, hemi, [-1 2], 10, 'recon_colormap', [], false);
%     load('recon_colormap');
%     colormap(cm);
%     colorbar;
%     TouchDir(fullfile(OUTPUT_DIR, sid));
%     SaveFig(fullfile(OUTPUT_DIR, sid), 'subj_class', 'png');
%     close
%     % endif DBG
    
    toc;   
end