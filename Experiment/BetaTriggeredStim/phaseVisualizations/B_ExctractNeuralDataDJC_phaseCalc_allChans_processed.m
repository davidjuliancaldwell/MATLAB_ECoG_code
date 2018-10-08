%% Constants
close all; clear all;clc

addpath(genpath('/gscratch/gridlab/djcald/MATLAB_ECoG_code/Experiment/BetaTriggeredStim'))
addpath(genpath('/gscratch/gridlab/djcald/MATLAB_ECoG_code/DataPrep'))
addpath(genpath('/gscratch/gridlab/djcald/MATLAB_ECoG_code/SigAnal'))
addpath(genpath('/gscratch/gridlab/djcald/MATLAB_ECoG_code/Experiment/Subdermal_QuickScreen'))

Z_Constants;
SUB_DIR = META_DIR;
%% parameters
numCores = feature('numcores');
parpool(numCores);
idxVec = [4 6 7];

addpath('/gscratch/gridlab/djcald/MATLAB_ECoG_code/Experiment/Subdermal_QuickScreen')
for idx = idxVec
    sid = SIDS{idx};
    
    switch(sid)
        
        case 'd5cd55'
            stims = [54 62];
            block = 'Block-49';
            bads = [1 49 58 59];
            
        case 'c91479'
            block = 'BetaPhase-14';
            stims = [55 56];
            bads = [2 3 31 57];
            
        case '7dbdec'
            
            block = 'BetaPhase-17';
            stims = [11 12];
            bads = [57];
            
        case '9ab7ab'
            block = 'BetaPhase-3';
            stims = [59 60];
            bads = [1 9 10 35 43];
        case '702d24'
            block = 'BetaPhase-4';
            stims = [13 14];
            bads = [23 27 28 29 30 32 44 52 60];
            
        case 'ecb43e' % added DJC 7-23-2015
            block = 'BetaPhase-3';
            stims = [56 64];
            bads = [57:64];
            
        case '0b5a2e' % added DJC 7-23-2015
            
            block = 'BetaPhase-2';
            stims = [22 30];
            bads = [24 25 29];
            
        case '0b5a2ePlayback' % added DJC 7-23-2015
            
            block = 'BetaPhase-4';
            stims = [22 30];
            bads = [24 25 29];
            
        otherwise
            error('unknown SID entered');
    end
    
    badsTotal = [stims bads];
    
    chans = [1:64];
    chans(ismember(chans, badsTotal)) = [];
    
    
    %% load in the trigger data
    % 9-2-2015 DJC added mod DJC
    % below is for original miah style burst tables
    
    % below is for modified burst tables
    %         load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    
    % below is for EXTRA modified burst table of d5cd55, leaving out the
    % ones that miah and jared said 2-22-2016
    
    %     load(fullfile(META_DIR, [sid '_tables_modDJC_2_22_2016.mat']), 'bursts', 'fs', 'stims');
    
    if strcmp(sid,'0b5a2ePlayback')
        load(fullfile(META_DIR, ['0b5a2e' '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
        
        delay = 577869;
    elseif strcmp(sid,'0b5a2e')
        
        % below is for original miah style burst tables
        %         load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
        % below is for modified burst tables
        load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    elseif strcmp(sid,'ecb43e')
        load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');
    else
        load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
    end
    
    
    % drop any stims that happen in the first 500 milliseconds
    stims(:,stims(2,:) < fs/2) = [];
    
    % drop any probe stimuli without a corresponding pre-burst/post-burst
    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
    stims(:, bads) = [];
    
    if strcmp(sid,'0b5a2ePlayback')
        stims(2,:) = stims(2,:)+delay;
        bursts(2,:) = bursts(2,:) + delay;
        bursts(3,:) = bursts(3,:) + delay;
        sid = '0b5a2e';
    end
    
    % add in delay between stim command time sent and registration on the ECoG channels
    % try 7 samples @ 12 khz
    stims(2,:) = stims(2,:) + 14;
    %
    
    %% process each ecog channel individually
    for chan = chans
        
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data for %s:\n',sid);
        fprintf('channel %d:\n',chan);
        tic;
        
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d',grp+1);
        achan = chan - grp*16;
        
        if achan==1 || achan == 2
            load(fullfile(SUB_DIR,sid,[block '.mat']),ev);
            dataStruct = eval(ev);
        end
        eco = dataStruct.data(:,achan);
        eco = 4*eco';
        efs = dataStruct.info.SamplingRateHz;
        
        toc;
        
        fac = fs/efs;
        
        %% preprocess eco
        %             presamps = round(0.050 * efs); % pre time in sec
        presamps = round(0.025 * efs); % pre time in sec
        
        % miah had 0.120
        postsamps = round(0.120 * efs); % post time in sec, % modified DJC to look at up to 300 ms after
        
        sts = round(stims(2,:) / fac);
        edd = zeros(size(sts));
        temp = squeeze(getEpochSignal(eco', sts-presamps, sts+postsamps+1));
        foo = mean(temp,2);
        lastsample = round(0.040 * efs);
        foo(lastsample:end) = foo(lastsample-1);
        
        last = find(abs(zscore(foo))>1,1,'last');
        last2 = find(abs(diff(foo))>30e-6,1,'last')+1;
        
        zc = false;
        
        if (isempty(last2))
            if (isempty(last))
                error ('something seems wrong in the triggered average');
            else
                ct = last;
            end
        else
            if (isempty(last))
                ct = last2;
            else
                ct = max(last, last2);
            end
        end
        
        while (~zc && ct <= length(foo))
            zc = sign(foo(ct-1)) ~= sign(foo(ct));
            ct = ct + 1;
        end
        % DJC - changed this to 0.015
        if (ct > max(last, last2) + 0.015 * efs) % marched along more than 10 msec, probably gone to far
            ct = max(last, last2);
        end
        
        %         %
        for sti = 1:length(sts)
            win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %interpolation approach
            eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
        end
        acausal_filt = bandpass(eco,12,20,efs,4,'acausal'); % was 20,12 ? should be 12 20!
        %  causal_filt = bandpass(eco,12,20,efs,4,'causal');
        
        %% process triggers
        
        if (strcmp(sid, '8adc5c'))
            pts = stims(3,:)==1;
        elseif (strcmp(sid, 'd5cd55'))
            %         pts = stims(3,:)==0 & (stims(2,:) > 4.5e6);
            pts = stims(3,:)==1 & (stims(2,:) > 4.5e6) & (stims(2, :) > 36536266);
        elseif (strcmp(sid, 'c91479'))
            ptsPos = stims(3,:)==1 & stims(8,:)==1;
            ptsNeg = stims(3,:)==1 & stims(8,:)==0;
        elseif (strcmp(sid, '7dbdec'))
            pts = stims(3,:)==1;
        elseif (strcmp(sid, '9ab7ab'))
            pts = stims(3,:)==1;
        elseif (strcmp(sid, '702d24'))
            ptsPos = stims(3,:)==1 & stims(8,:)==1;
            ptsNeg = stims(3,:)==1 & stims(8,:)==0;
            
            %modified DJC 7-27-2015
        elseif (strcmp(sid, 'ecb43e'))
            
            ptsPos = stims(3,:)==1 & stims(8,:)==0;
            ptsNeg = stims(3,:)==1 & stims(8,:)==1;
            pts = stims(3,:)==1 & stims(8,:)==3;
        elseif (strcmp(sid, '0b5a2e'))
            ptsPos = stims(3,:)==1 & stims(8,:)==1;
            ptsNeg = stims(3,:)==1 & stims(8,:)==0;
            
        elseif (strcmp(sid, '0b5a2ePlayback'))
            ptsPos = stims(3,:)==1 & stims(8,:)==1;
            ptsNeg = stims(3,:)==1 & stims(8,:)==0;
            
        else
            error 'unknown sid';
        end
        
        % changing presamps - DJC - 2/24/2016
        presamps = round(0.06*efs);
        postsamps = round(0.00*efs);
        
        if exist('ptsPos','var') & exist('ptsNeg','var')
            ptisPos = round(stims(2,ptsPos)/fac);
            ptisNeg = round(stims(2,ptsNeg)/fac);
        end
        if exist('pts','var')
            ptis = round(stims(2,pts)/fac);
        end
        
        t = (-presamps:postsamps)/efs;
        
        % 2/24/2016 - change CT so that if you pick different limits for
        % pre and post baseline, then you're ok for "blanking out" the
        % stimulation
        
        % plot intermediate steps?
        plotIt = false;
        
        % set parameters for fit function
        f_range = [12 20]; % was 10 30, then 12 25, changed back 8.28.2018
        smooth_span = 51; % was 13, try 19, then 5, now try 17 8.28.2018
        % try 51 9.20.2018
        
        if (exist('ptsPos','var') & exist('ptsNeg','var'))
            
            winsPos = squeeze(getEpochSignal(eco', ptisPos-presamps, ptisPos+postsamps+1));
            winsNeg = squeeze(getEpochSignal(eco', ptisNeg-presamps, ptisNeg+postsamps+1));
            
            % median is subtracted off in function! dont do it twice!
            awinsPos = winsPos;
            awinsNeg = winsNeg;
            winsPos_acaus = squeeze(getEpochSignal(acausal_filt', ptisPos-presamps, ptisPos+postsamps+1));
            winsNeg_acaus = squeeze(getEpochSignal(acausal_filt', ptisNeg-presamps, ptisNeg+postsamps+1));
            
            winsPos_total_unref(:,:,chan) = winsPos;
            winsNeg_total_unref(:,:,chan) = winsNeg;
            winsPos_acaus_total_unref(:,:,chan) = winsPos_acaus;
            winsNeg_acaus_total_unref(:,:,chan) = winsNeg_acaus;
            
        end
        
        if exist('pts','var')
            
            wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
            wins_acaus = squeeze(getEpochSignal(acausal_filt', ptis-presamps, ptis+postsamps+1));
            
            wins_total_unref(:,:,chan) = wins;
            wins_acaus_total_unref(:,:,chan) = wins_acaus;
        end
        
    end
    
    %% now common average rereference
    rerefMode = 'median';
    
    if exist('pts','var')
        wins_total = rereference_CAR_median(wins_total_unref,rerefMode,badsTotal,[1 3 2]);
        wins_acaus_total = rereference_CAR_median(wins_acaus_total_unref,rerefMode,badsTotal,[1 3 2]);
    end
    if (exist('ptsPos','var') & exist('ptsNeg','var'))
        winsPos_total = rereference_CAR_median(winsPos_total_unref,rerefMode,badsTotal,[1 3 2]);
        winsNeg_total = rereference_CAR_median(winsNeg_total_unref,rerefMode,badsTotal,[1 3 2]);
        winsPos_acaus_total = rereference_CAR_median(winsPos_acaus_total_unref,rerefMode,badsTotal,[1 3 2]);
        winsNeg_acaus_total = rereference_CAR_median(winsNeg_acaus_total_unref,rerefMode,badsTotal,[1 3 2]);
    end
    
    fprintf('rereferencing done');
    %% now do the fitting
    
    for chan = chans
        
        fprintf('fitting ecog data for %s:\n',sid);
        fprintf('channel %d:\n',chan);
        tic;
        
        % perform the fitting on conditions where there were
        % multiple set to be delivered
        if (exist('ptsPos','var') & exist('ptsNeg','var'))
            
            awinsPos = winsPos_total(:,:,chan);
            awinsNeg = winsNeg_total(:,:,chan);
            awinsPos_acaus = winsPos_acaus_total(:,:,chan);
            awinsNeg_acaus = winsNeg_acaus_total(:,:,chan);
            
            % do the fit on the mean signal
            % do it on different conditions
            
            % raw signal
            
            [phase_at_0_pos_ind,f_pos_ind,r_square_pos_ind,fitline_pos_ind] = phase_calculation(awinsPos,t,smooth_span,f_range,efs,plotIt);
            [phase_at_0_neg_ind,f_neg_ind,r_square_neg_ind,fitline_neg_ind] = phase_calculation(awinsNeg,t,smooth_span,f_range,efs,plotIt);
            
            phase_at_0_pos(:,chan) = phase_at_0_pos_ind;
            f_pos(:,chan) = f_pos_ind;
            r_square_pos(:,chan) = r_square_pos_ind;
            fitline_pos(:,:,chan) = fitline_pos_ind;
            
            phase_at_0_neg(:,chan) = phase_at_0_neg_ind;
            f_neg(:,chan) = f_neg_ind;
            r_square_neg(:,chan) = r_square_neg_ind;
            fitline_neg(:,:,chan) = fitline_neg_ind;
            
            % acausal filtered signal
            [phase_at_0_pos_acaus_ind,f_pos_acaus_ind,r_square_pos_acaus_ind,fitline_pos_acaus_ind] = phase_calculation(awinsPos_acaus,t,smooth_span,f_range,efs,plotIt);
            [phase_at_0_neg_acaus_ind,f_neg_acaus_ind,r_square_neg_acaus_ind,fitline_neg_acaus_ind] = phase_calculation(awinsNeg_acaus,t,smooth_span,f_range,efs,plotIt);
            
            phase_at_0_pos_acaus(:,chan) = phase_at_0_pos_acaus_ind;
            f_pos_acaus(:,chan) = f_pos_acaus_ind;
            r_square_pos_acaus(:,chan) = r_square_pos_acaus_ind;
            fitline_pos_acaus(:,:,chan) = fitline_pos_acaus_ind;
            
            phase_at_0_neg_acaus(:,chan) = phase_at_0_neg_acaus_ind;
            f_neg_acaus(:,chan) = f_neg_acaus_ind;
            r_square_neg_acaus(:,chan) = r_square_neg_acaus_ind;
            fitline_neg_acaus(:,:,chan) = fitline_neg_acaus_ind;
            %%%%%%%%%%%%%%%%% hilbert
            
            % make fake vector for non pts
            if ~strcmp('ecb43e',sid)
                
                f(:,chan) = 0;
                phase_at_0(:,chan)= 0;
                r_square(:,chan)= 0;
                fitline(:,:,chan) = 0;
                
                f_acaus(:,chan)=0;
                phase_at_0_acaus(:,chan)= 0;
                r_square_acaus(:,chan) = 0;
                fitline_acaus(:,:,chan) = 0;
                
            end
        end
        
        if exist('pts','var')
            awins = wins_total(:,:,chan);
            awins_acaus = wins_acaus_total(:,:,chan);
            
            % do the fit on the mean signal
            
            % plot intermediate steps?
            plotIt = false;
            
            % raw signal
            %
            [phase_at_0_ind,f_ind,r_square_ind,fitline_ind] = phase_calculation(awins,t,smooth_span,f_range,efs,plotIt);
            phase_at_0(:,chan) = phase_at_0_ind;
            f(:,chan) = f_ind;
            r_square(:,chan) = r_square_ind;
            fitline(:,:,chan) = fitline_ind;
            
            % acausal filtered signal
            [phase_at_0_acaus_ind,f_acaus_ind,r_square_acaus_ind,fitline_acaus_ind] = phase_calculation(awins_acaus,t,smooth_span,f_range,efs,plotIt);
            %
            phase_at_0_acaus(:,chan) = phase_at_0_acaus_ind;
            f_acaus(:,chan) = f_acaus_ind;
            r_square_acaus(:,chan) = r_square_acaus_ind;
            fitline_acaus(:,:,chan) = fitline_acaus_ind;
            
            if ~strcmp('ecb43e',sid)
                
                f_pos(:,chan)=0;
                f_neg(:,chan)=0;
                phase_at_0_pos(:,chan) = 0;
                r_square_pos(:,chan)= 0;
                fitline_pos(:,:,chan)= 0;
                phase_at_0_neg(:,chan)= 0;
                r_square_neg(:,chan)= 0;
                fitline_neg(:,:,chan)= 0;
                f_pos_acaus(:,chan) = 0;
                f_neg_acaus(:,chan) = 0;
                phase_at_0_pos_acaus(:,chan)= 0;
                r_square_pos_acaus(:,chan)= 0;
                fitline_pos_acaus(:,:,chan)= 0;
                phase_at_0_neg_acaus(:,chan)= 0;
                r_square_neg_acaus(:,chan)= 0;
                fitline_neg_acaus(:,:,chan)= 0;
                
                
            end
            
        end
        
        
        toc;
    end
    if idx == 9
        sid = '0b5a2ePlayBack';
    end
    %%
    save(fullfile(OUTPUT_DIR, [sid '_phaseDelivery_allChans_51samps_12_20_60ms_randomStart.mat']), 'sid','t','r_square','r_square_acaus','r_square_neg_acaus','r_square_pos','r_square_neg',...
        'r_square_pos_acaus','phase_at_0_pos','fitline_pos','phase_at_0_neg','fitline_neg',...
        'phase_at_0_pos_acaus','fitline_pos_acaus','phase_at_0_neg_acaus','fitline_neg_acaus',...
        'phase_at_0','r_square','fitline','phase_at_0_acaus','fitline_acaus',...
        'f','f_acaus','f_pos','f_neg','f_pos_acaus','f_neg_acaus','-v7.3');
    
    close all; clearvars -except idx SIDS OUTPUT_DIR META_DIR SUB_DIR chan chans sid tp block 'bursts' 'fs' 'stims'
end
