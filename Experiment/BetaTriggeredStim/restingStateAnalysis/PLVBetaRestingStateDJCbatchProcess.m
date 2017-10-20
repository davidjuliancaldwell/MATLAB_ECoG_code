%% 1-26-2016 - PLV for resting states, before and after, and within session -DJC
% modified for batch processing 2-9-2016
% modified 9-26-2017 to look at different frequency bands
%%
cd C:\Users\djcald.CSENETID\Code\Experiment\BetaTriggeredStim
close all;clear all;clc
Z_ConstantsRest
%there appears to be no montage for this subject currently - assume all are
%64 channel grids right now which is fine because it's from TDT recording

%%
% starting at 5 for DJC 2-10-2016,
for z = 7:length(SIDS)
    sid = SIDS{z};
    fprintf([sid '\n'])
    switch(sid)
        % this case isn't currelty considered
        case '8adc5c'
            subjid = sid;
            
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            Montage.BadChannels = [];
            
            
        case 'd5cd55'
            subjid = sid;
            
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            Montage.BadChannels = [];
            
            
        case 'c91479'
            subjid = sid;
            
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            Montage.BadChannels = [];
            
        case '7dbdec'
            subjid = sid;
            
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            Montage.BadChannels = [];
            
        case '9ab7ab'
            subjid = sid;
            
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            Montage.BadChannels = [];
            
        case '702d24'
            subjid = sid;
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            suffixPre = 'preStimRestDecimated';
            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            
            Montage.BadChannels = [];
            
            
            clear Blck;
            
        case 'ecb43e'
            % load pre
            subjid = 'ecb43e';
            load('ecb43e_PAC_prestim.mat')
            BlckPre = data;
            clear data
            
            % load post
            load('ecb43e_PAC_poststim.mat')
            BlckPost = data;
            clear data
            sid = 'ecb43e';
            
            Montage.BadChannels = [54];
            
            % this case isn't currently considered
        case '0b5a2e'
            subjid = '0b5a2e';
            suffixPost = 'postStimRestDecimated';
            load(strcat(subjid, '_', suffixPost), 'fs', 'Blck')
            BlckPost = Blck;
            clear Blck;
            
            % pre load
            %suffixPre = 'preStimRestDecimated';
            suffixPre = 'preStimRestDecimated_v2';

            load(strcat(subjid,'_',suffixPre), 'fs', 'Blck')
            BlckPre = Blck;
            clear Blck;
            
            Montage.BadChannels = [25 29];
    end
    
    
    Montage.Montage = 64;
    Montage.MontageTokenized = {'Grid(1:64)'};
    Montage.MontageString = Montage.MontageTokenized{:};
    Montage.MontageTrodes = zeros(64, 3);
    %     Montage.BadChannels = [];
    Montage.Default = true;
    
    % get electrode locations
    locs = trodeLocsFromMontage(sid, Montage, false);
    
    %% some more preprocessing if desired, NEED MONTAGE LOADED
    
    
    bads = Montage.BadChannels;
    
    % common average rereference
    BlckPreCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPre);
    BlckPostCAR = ReferenceCAR(Montage.Montage,Montage.BadChannels,BlckPost);
    clear BlckPre;
    clear BlckPost;
    
    % notch filter at 60, 120, 180  - DJC 9-26-2017
    BlckPreCARnotch = notch(BlckPreCAR,[60 120 180],fs);
    BlckPostCARnotch = notch(BlckPostCAR,[60 120 180],fs);
    clear BlckPreCAR;
    clear BlckPostCAR;
    
    % high pass filter at 0.5
    BlckPreCARfiltered = highpass(BlckPreCARnotch,0.5,fs);
    BlckPostCARfiltered = highpass(BlckPostCARnotch,0.5,fs);
    clear BlckPreCARnotch;
    clear BlckPostCARnotch;
    
    %% post state - 2-8-2016
    post_trimmed_sig = BlckPostCARfiltered;
    trimmed_sig = post_trimmed_sig;
    
    % 12-25 or 13-30? Kaitlyn started with 13-30, i did 12-25 to match Jared -
    % DJC 2-8-2016
    %beta = hilbAmp(trimmed_sig, [12 25], fs).^2;
    
    
    fprintf('extracting HG power\n');
    HG = hilbAmp(trimmed_sig, [70 200], fs).^2;
    fprintf('extracting Beta power\n');
    beta = hilbAmp(trimmed_sig, [12 25], fs).^2;
    fprintf('extracting Alpha power\n');
    alpha = hilbAmp(trimmed_sig, [8 12], fs).^2;
    fprintf('extracting theta power\n');
    theta = hilbAmp(trimmed_sig, [4 8], fs).^2;
    fprintf('extracting delta power\n');
    delta = hilbAmp(trimmed_sig, [0 4], fs).^2;
        fprintf('extracting gamma power\n');
    gamma = hilbAmp(trimmed_sig, [30 70], fs).^2;
    
    %     fprintf('extracting second order HG features\n');
    %     ifsHG = infraslowBandpass(HGPower); %infraslow HG fluctuation 0.1-1hz
    
    % for comparison
    post_beta = hilbAmp(post_trimmed_sig, [12 25], fs).^2;
    
    numReps = 100;
    
    windowSize = round(8 * fs);
    
    
    fprintf('beta \n');
    [betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);
    fprintf('hg \n');
    [hgBlvs, signif_hg_plvs, hg_pmax] = segmentedShuff_stats_oneband(HG, windowSize, numReps);
    fprintf('alpha \n');
    [alphaBlvs, signif_alpha_plvs, alpha_pmax] = segmentedShuff_stats_oneband(alpha, windowSize, numReps);
    fprintf('theta \n');
    [thetaBlvs, signif_theta_plvs, theta_pmax] = segmentedShuff_stats_oneband(theta, windowSize, numReps);
    fprintf('delta \n');
    [deltaBlvs, signif_delta_plvs, delta_pmax] = segmentedShuff_stats_oneband(delta, windowSize, numReps);
     fprintf('gamma \n');
    [gammaBlvs, signif_gamma_plvs, gamma_pmax] = segmentedShuff_stats_oneband(gamma, windowSize, numReps);
%     fprintf('ifsHg \n');
%     [ifsHGBlvs, signif_ifsHG_plvs, ifsHG_pmax] = segmentedShuff_stats_oneband(ifsHG, windowSize, numReps);
%     
%     
    
    shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.
    
    post_beta = beta;
    post_alpha = alpha;
    post_HG = HG;
    post_theta = theta;
    post_delta = delta;
    post_gamma = gamma;
    %post_ifsHG = ifsHG;
    
    clear 'alpha' 'beta' 'HG' 'theta' 'delt' 'ifsHG' 'gamma';
    
    save(fullfile(META_DIR, [sid '_postSegmentedShuffled_v2']), 'betaBlvs', 'fs', 'signif_beta_plvs','beta_pmax','hgBlvs',...
        'signif_hg_plvs', 'hg_pmax','alphaBlvs', 'signif_alpha_plvs', 'alpha_pmax','thetaBlvs', 'signif_theta_plvs', 'theta_pmax',...
        'deltaBlvs', 'signif_delta_plvs', 'delta_pmax','gammaBlvs', 'signif_gamma_plvs', 'gamma_pmax');
    
    %% pre state 2-8-2016
    
    clear 'betaBlvs' 'beta_pmax' 'signif_beta_plvs' 'trimmed_sig'
    trimmed_sig = BlckPreCARfiltered;
    
    
    fprintf('extracting HG power\n');
    HG = hilbAmp(trimmed_sig, [70 200], fs).^2;
    fprintf('extracting Beta power\n');
    beta = hilbAmp(trimmed_sig, [12 25], fs).^2;
    fprintf('extracting Alpha power\n');
    alpha = hilbAmp(trimmed_sig, [8 12], fs).^2;
    fprintf('extracting theta power\n');
    theta = hilbAmp(trimmed_sig, [4 8], fs).^2;
    fprintf('extracting delta power\n');
    delta = hilbAmp(trimmed_sig, [0 4], fs).^2;
            fprintf('extracting gamma power\n');
    gamma = hilbAmp(trimmed_sig, [30 70], fs).^2;
    
    %     fprintf('extracting second order HG features\n');
    %     ifsHG = infraslowBandpass(HGPower); %infraslow HG fluctuation 0.1-1hz
    %
    
    numReps = 100;
    
    windowSize = round(8 * fs);
    
     fprintf('beta \n');
    [betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);
    fprintf('hg \n');
    [hgBlvs, signif_hg_plvs, hg_pmax] = segmentedShuff_stats_oneband(HG, windowSize, numReps);
    fprintf('alpha \n');
    [alphaBlvs, signif_alpha_plvs, alpha_pmax] = segmentedShuff_stats_oneband(alpha, windowSize, numReps);
    fprintf('theta \n');
    [thetaBlvs, signif_theta_plvs, theta_pmax] = segmentedShuff_stats_oneband(theta, windowSize, numReps);
    fprintf('delta \n');
    [deltaBlvs, signif_delta_plvs, delta_pmax] = segmentedShuff_stats_oneband(delta, windowSize, numReps);
         fprintf('gamma \n');
    [gammaBlvs, signif_gamma_plvs, gamma_pmax] = segmentedShuff_stats_oneband(gamma, windowSize, numReps);
%     fprintf('ifsHg \n');
%     [ifsHGBlvs, signif_ifsHG_plvs, ifsHG_pmax] = segmentedShuff_stats_oneband(ifsHG, windowSize, numReps);
%     
    
    shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.
    
    save(fullfile(META_DIR, [sid '_preSegmentedShuffled_v2']), 'betaBlvs', 'fs', 'signif_beta_plvs','beta_pmax','hgBlvs',...
        'signif_hg_plvs', 'hg_pmax','alphaBlvs', 'signif_alpha_plvs', 'alpha_pmax','thetaBlvs', 'signif_theta_plvs', 'theta_pmax',...
        'deltaBlvs', 'signif_delta_plvs', 'delta_pmax','gammaBlvs', 'signif_gamma_plvs', 'gamma_pmax');
    
    
    %% comparison between pre and post state
    
    % DJC 2-9-2016, change windowsize from round(10*fs) to round(8*fs) to match
    % single session?
    
    windowSize = round(8 * fs);
    numChans = 64;
    
    fprintf('alpha\n');
    [diff_alpha_plv, alpha_pmin, alpha_pmax] = changeTScoreWithStats(alpha, post_alpha, windowSize);
    masked_alpha_plvdiff = NaN(numChans, numChans);
    for i = 1:numChans;
        for j=1:numChans;
            if alpha_pmax(i,j)<=0.025 || alpha_pmin(i,j)<0.025;
                masked_alpha_plvdiff(i,j) = diff_alpha_plv(i,j);
            end
        end
    end
    
    
    fprintf('beta\n');
    [diff_beta_plv, beta_pmin, beta_pmax] = changeTScoreWithStats(beta, post_beta, windowSize);
    masked_beta_plvdiff = NaN(numChans, numChans);
    for i = 1:numChans;
        for j=1:numChans;
            if beta_pmax(i,j)<=0.025 || beta_pmin(i,j)<0.025;
                masked_beta_plvdiff(i,j) = diff_beta_plv(i,j);
            end
        end
    end
    
    fprintf('theta\n');
    [diff_theta_plv, theta_pmin, theta_pmax] = changeTScoreWithStats(theta, post_theta, windowSize);
    masked_theta_plvdiff = NaN(numChans, numChans);
    for i = 1:numChans;
        for j=1:numChans;
            if theta_pmax(i,j)<=0.025 || theta_pmin(i,j)<0.025;
                masked_theta_plvdiff(i,j) = diff_theta_plv(i,j);
            end
        end
    end
    
    fprintf('HG\n');
    [diff_HG_plv, HG_pmin, HG_pmax] = changeTScoreWithStats(HG, post_HG, windowSize);
    masked_HG_plvdiff = NaN(numChans, numChans);
    for i = 1:numChans;
        for j=1:numChans;
            if HG_pmax(i,j)<=0.025 || HG_pmin(i,j)<0.025;
                masked_HG_plvdiff(i,j) = diff_HG_plv(i,j);
            end
        end
    end
    
    windowSize = round(20 * fs); %sliding window will be 20 second long segments - these are too slow for 10
    
    fprintf('delta\n');
    [diff_delta_plv, delta_pmin, delta_pmax] = changeTScoreWithStats(delta, post_delta, windowSize);
    masked_delta_plvdiff = NaN(numChans, numChans);
    for i = 1:numChans;
        for j=1:numChans;
            if delta_pmax(i,j)<=0.025 || delta_pmin(i,j)<0.025;
                masked_delta_plvdiff(i,j) = diff_delta_plv(i,j);
            end
        end
    end
    
        fprintf('gamma\n');
    [diff_gamma_plv, gamma_pmin, gamma_pmax] = changeTScoreWithStats(gamma, post_gamma, windowSize);
    masked_gamma_plvdiff = NaN(numChans, numChans);
    for i = 1:numChans;
        for j=1:numChans;
            if gamma_pmax(i,j)<=0.025 || gamma_pmin(i,j)<0.025;
                masked_gamma_plvdiff(i,j) = diff_gamma_plv(i,j);
            end
        end
    end
    
%     
%     fprintf('ifs\n');
%     [diff_ifs_plv, ifs_pmin, ifs_pmax] = changeTScoreWithStats(ifsHG, post_ifsHG, windowSize);
%     masked_ifs_plvdiff = NaN(numChans, numChans);
%     for i = 1:numChans;
%         for j=1:numChans;
%             if ifs_pmax(i,j)<=0.025 || ifs_pmin(i,j)<0.025;
%                 masked_ifs_plvdiff(i,j) = diff_ifs_plv(i,j);
%             end
%         end
%     end
%     
%     fprintf('rs\n');
%     [diff_rs_plv, rs_pmin, rs_pmax] = changeTScoreWithStats(rsHG, post_rsHG, windowSize);
%     masked_rs_plvdiff = NaN(numChans, numChans);
%     for i = 1:numChans;
%         for j=1:numChans;
%             if rs_pmax(i,j)<=0.025 || rs_pmin(i,j)<0.025;
%                 masked_rs_plvdiff(i,j) = diff_rs_plv(i,j);
%             end
%         end
%     end
    
    
    % 2-9-2016 DJC
    switch (sid)
        case '0b5a2e'
            bads = Montage.BadChannels;
            bads = [25 28 29];
        case 'ecb43e'
            bads = Montage.BadChannels;
            bads = [54];
            
    end
    masked_beta_plvdiff2 = masked_beta_plvdiff;
    masked_beta_plvdiff2(bads,:) = NaN;
    masked_beta_plvdiff2(:,bads) = NaN;
    
        masked_alpha_plvdiff2 = masked_alpha_plvdiff;
    masked_alpha_plvdiff2(bads,:) = NaN;
    masked_alpha_plvdiff2(:,bads) = NaN;
    
        masked_theta_plvdiff2 = masked_theta_plvdiff;
    masked_theta_plvdiff2(bads,:) = NaN;
    masked_theta_plvdiff2(:,bads) = NaN;
    
        masked_delta_plvdiff2 = masked_delta_plvdiff;
    masked_delta_plvdiff2(bads,:) = NaN;
    masked_delta_plvdiff2(:,bads) = NaN;
    
        masked_HG_plvdiff2 = masked_HG_plvdiff;
    masked_HG_plvdiff2(bads,:) = NaN;
    masked_HG_plvdiff2(:,bads) = NaN;
    
        
        masked_gamma_plvdiff2 = masked_gamma_plvdiff;
    masked_gamma_plvdiff2(bads,:) = NaN;
    masked_gamma_plvdiff2(:,bads) = NaN;
    
    save(fullfile(META_DIR, [sid '_PreVsPost_v2']), 'diff_beta_plv', 'beta_pmin', 'beta_pmax', 'fs', 'masked_beta_plvdiff', 'masked_beta_plvdiff2',...
        'diff_alpha_plv', 'alpha_pmin', 'alpha_pmax', 'masked_alpha_plvdiff', 'masked_alpha_plvdiff2',...
        'diff_theta_plv', 'theta_pmin', 'theta_pmax', 'masked_theta_plvdiff', 'masked_theta_plvdiff2',...
        'diff_delta_plv', 'delta_pmin', 'delta_pmax', 'masked_delta_plvdiff', 'masked_delta_plvdiff2',...
        'diff_HG_plv', 'HG_pmin', 'HG_pmax', 'masked_HG_plvdiff', 'masked_HG_plvdiff2',...
        'diff_gamma_plv', 'gamma_pmin', 'gamma_pmax', 'masked_gamma_plvdiff', 'masked_gamma_plvdiff2');
    
    clearvars -except SIDS z META_DIR OUTPUT_DIR
    
end

