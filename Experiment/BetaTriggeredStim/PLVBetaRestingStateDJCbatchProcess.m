%% 1-26-2016 - PLV for resting states, before and after, and within session -DJC
% modified for batch processing 2-9-2016

%%
cd c:\users\david\desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim
close all;clear all;clc
Z_ConstantsRest
%there appears to be no montage for this subject currently - assume all are
%64 channel grids right now which is fine because it's from TDT recording

%%
% starting at 5 for DJC 2-10-2016,
for z = 6:length(SIDS)
    sid = SIDS{z};
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
            suffixPre = 'preStimRestDecimated';
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
    
    % notch filter at 60
    BlckPreCARnotch = notch(BlckPreCAR,60,fs);
    BlckPostCARnotch = notch(BlckPostCAR,60,fs);
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
    beta = hilbAmp(trimmed_sig, [12 25], fs).^2;
    
    % for comparison
    post_beta = hilbAmp(post_trimmed_sig, [12 25], fs).^2;
    
    numReps = 100;
    
    windowSize = round(8 * fs);
    
    
    fprintf('beta \n');
    [betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);
    
    shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.
    
    clear 'alpha' 'beta' 'HG' 'theta' 'delt' 'ifsHG';
    
    save(fullfile(META_DIR, [sid '_postSegmentedShuffled']), 'betaBlvs', 'fs', 'signif_beta_plvs','beta_pmax');
    
    %% pre state 2-8-2016
    
    clear 'betaBlvs' 'beta_pmax' 'signif_beta_plvs' 'trimmed_sig'
    trimmed_sig = BlckPreCARfiltered;
    
    beta = hilbAmp(trimmed_sig, [12 25], fs).^2;
    
    numReps = 100;
    
    windowSize = round(8 * fs);
    
    
    fprintf('beta \n');
    [betaBlvs, signif_beta_plvs, beta_pmax] = segmentedShuff_stats_oneband(beta, windowSize, numReps);
    
    shuffleMethod = '95th percentiles averaged across each permutation, segmented shuffling procedure'; %verify if you edit script.
        
    save(fullfile(META_DIR, [sid '_preSegmentedShuffled']), 'betaBlvs', 'fs', 'signif_beta_plvs','beta_pmax');
    
    
    %% comparison between pre and post state
    
    % DJC 2-9-2016, change windowsize from round(10*fs) to round(8*fs) to match
    % single session?
    
    windowSize = round(8 * fs);
    numChans = 64;
    
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
    
    save(fullfile(META_DIR, [sid '_PreVsPost']), 'diff_beta_plv', 'beta_pmin', 'beta_pmax', 'fs', 'masked_beta_plvdiff', 'masked_beta_plvdiff2');
    
    clearvars -except SIDS z META_DIR OUTPUT_DIR
    
end

