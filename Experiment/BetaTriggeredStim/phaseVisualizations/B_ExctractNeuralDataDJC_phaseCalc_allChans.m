%% Constants
close all; clear all;clc
% cd 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim'
Z_Constants;

SUB_DIR = fullfile(myGetenv('subject_dir'));
% OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));
CONV_DIR = 'C:\Users\djcald.CSENETID\Data\ConvertedTDTfiles';

%% parameters

for idx = 2:2
    sid = SIDS{idx};
    switch(sid)
        case '8adc5c'

            stims = [31 32];
            chans = [8 7 48];
        case 'd5cd55'

            stims = [54 62];
            chans = [53 61 63];
            chans = [1:64];
            
            block = 'Block-49';
            goods = sort([44 45 46 52 53 55 60 61 63]);
            betaChan = 53;
            
            % have to set t_min and t_max for each subject
            %t_min = 0.004833;
            % t_min of 0.005 would find the really early ones
            t_min = 0.008;
            t_max = 0.05;
            
            chans = [53 61 63 55];

        case 'c91479'
            block = 'BetaPhase-14';
            stims = [55 56];
            
            betaChan = 64;
            goods = sort([ 39 40 47 48 63 64]);
            t_min = 0.008;
            t_max = 0.035;
            
            chans = [ 48 63 64];

        case '7dbdec'
            block = 'BetaPhase-17';
            stims = [11 12];
            chans = [4 5 14];
            chans = [1:64];
            
            goods = sort([4 5 10 13]);
            betaChan = 4;
            t_min = 0.008;
            t_max = 0.04;
            
            chans = [ 5 14];

            
        case '9ab7ab'
            %             sid = SIDS{5};
            tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
            block = 'BetaPhase-3';
            stims = [59 60];
            chans = [51 52 53 58 57];
            chans = [1:64];
            
            betaChan = 51;
            
            goods = sort([42 43 49 50 51 52 53 57 58]);
            t_min = 0.005;
            t_max = 0.0425;
            
            chans = [ 52 53 58 57];

        case '702d24'
            tp = strcat(SUB_DIR,'\702d24\data\d7\702d24_BetaStim');
            block = 'BetaPhase-4';
            stims = [13 14];
            chans = [4 5 21];
            chans = [1:64];
            %            chans = [36:64];
            
            goods = [ 5 ];
            bads = [23 27 28 29 30 32];
            betaChan = 5;
            t_min = 0.008;
            t_max = 0.0425;
            
            
            chans = [4 5 21];

        case 'ecb43e' % added DJC 7-23-2015
            tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
            block = 'BetaPhase-3';
            stims = [56 64];
            
            betaChan = 55;
            goods = sort([55 63 54 47 48]);
            t_min = 0.008;
            t_max = 0.05;
            
            chans = [47 48 54 55 63];
            
        case '0b5a2e' % added DJC 7-23-2015
            block = 'BetaPhase-2';
            stims = [22 30];
            chans = [14 21 23 31];
            
            betaChan = 31;
            goods = sort([12 13 14 15 16 20 21 23 31 32 39 40]);
            % goods = [14 21 23 31];
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
            
            chans = [14 21 23 31];
            
 
        case '0b5a2ePlayback' % added DJC 7-23-2015
            block = 'BetaPhase-4';
            stims = [22 30];
            chans = [14 21 23 31];
            
            betaChan = 31;
            goods = sort([12 13 14 15 16 21 23 31 32 39 40]);
            bads = [20 24 28];
            t_min = 0.005;
            t_max = 0.05;
                        chans = [14 21 23 31];


        otherwise
            error('unknown SID entered');
    end
    
    chans(ismember(chans, stims)) = [];    
                load(fullfile(CONV_DIR,sid,block));

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
        
    end
    %%
    efs = ECO1.info.SamplingRateHz;

    %dataTotal = [ECO1.data ECO2.data ECO3.data ECO4.data];
    dataTotal = [ECO1.data ECO2.data];
    clearvars ECO1 ECO2
    dataTotal = [dataTotal ECO3.data];
    clearvars ECO3
   dataTotal = [dataTotal ECO4.data];
    clearvars ECO4;
    
    rereference_CAR_median(tempSignal,rerefMode,badChans,[1 2],channelReref);

    %% process each ecog channel individually
    for chan = chans
        
        
        %% load in ecog data for that channel
        fprintf('loading in ecog data for %s:\n',sid);
        fprintf('channel %d:\n',chan);
        tic;
        grp = floor((chan-1)/16);
        ev = sprintf('ECO%d', grp+1);
        achan = chan - grp*16;
        
        %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
        [eco, info] = tank.readWaveEvent(ev, achan);
        eco = eco';
        
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
        
        %         % DJC - 8-31-2015 - i believe this is messing with the resizing
        %         % in the figures
        %         %             subplot(8,8,chan);
        %         %             plot(foo);
        %         %             vline(ct);
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
        presamps = round(0.05*efs);
        postsamps = round(0.00*efs);
        
        if exist('ptsPos') & exist('ptsNeg')
            ptisPos = round(stims(2,ptsPos)/fac);
            ptisNeg = round(stims(2,ptsNeg)/fac);
        end
        if exist('pts')
            ptis = round(stims(2,pts)/fac);
        end
        
        t = (-presamps:postsamps)/efs;
        
        % 2/24/2016 - change CT so that if you pick different limits for
        % pre and post baseline, then you're ok for "blanking out" the
        % stimulation
        
        index = find(t==0);
        ct = index + ct - round(0.025*efs);
        
        
        % plot intermediate steps?
        plotIt = false;
        
        % set parameters for fit function
        f_range = [12 25]; % was 10 30
        smooth_span = 5; % was 13, try 19
        
        
        if (exist('ptsPos') & exist('ptsNeg'))
            
            winsPos = squeeze(getEpochSignal(eco', ptisPos-presamps, ptisPos+postsamps+1));
            winsNeg = squeeze(getEpochSignal(eco', ptisNeg-presamps, ptisNeg+postsamps+1));
            
            % median is subtracted off in function! dont do it twice!
            
            % normalize the windows to each other, using pre data
            %             awinsPos = winsPos-repmat(median(winsPos(t<0,:),1), [size(winsPos, 1), 1]);
            %            awinsNeg = winsNeg-repmat(median(winsNeg(t<0,:),1), [size(winsNeg, 1), 1]);
            
            %             % normalize windows with DC subtract for whole thing
            %             awinsPos = winsPos - repmat(median(winsPos,1), [size(winsPos,1),1]);
            %             awinsNeg = winsNeg - repmat(median(winsNeg,1), [size(winsNeg,1),1]);
            %
            
            awinsPos = winsPos;
            awinsNeg = winsNeg;
            
            %   % DJC 1-14-2017 - attempt to look at epoched acausal
            %    winsPos_caus = squeeze(getEpochSignal(causal_filt', ptisPos-presamps, ptisPos+postsamps+1));
            %   winsNeg_caus = squeeze(getEpochSignal(causal_filt', ptisNeg-presamps, ptisNeg+postsamps+1));
            
            %  awinsPos_caus = winsPos_caus;
            %   awinsNeg_caus = winsNeg_caus;
            
            winsPos_acaus = squeeze(getEpochSignal(acausal_filt', ptisPos-presamps, ptisPos+postsamps+1));
            winsNeg_acaus = squeeze(getEpochSignal(acausal_filt', ptisNeg-presamps, ptisNeg+postsamps+1));
            
            awinsPos_acaus = winsPos_acaus;
            awinsNeg_acaus = winsNeg_acaus;
            
            % do the fit on the mean signal
            
            
            % do it on different conditions
            
            % raw
            
            [phase_at_0_pos,f_pos,r_square_pos,fitline_pos] = phase_calculation(awinsPos,t,smooth_span,f_range,efs,plotIt);
            [phase_at_0_neg,f_neg,r_square_neg,fitline_neg] = phase_calculation(awinsNeg,t,smooth_span,f_range,efs,plotIt);
            
            % causal
            
            %  [phase_at_0_pos_caus,f_pos_caus,r_square_pos_caus,fitline_pos_caus] = phase_calculation(awinsPos_caus,t,smooth_span,f_range,efs,plotIt);
            %  [phase_at_0_neg_caus,f_neg_caus,r_square_neg_caus,fitline_neg_caus] = phase_calculation(awinsNeg_caus,t,smooth_span,f_range,efs,plotIt);
            
            if lookAtBetaChan
                betaPos = squeeze(getEpochSignal(filt_sig_decimate', ptisPos-presamps, ptisPos+postsamps+1));
                betaNeg = squeeze(getEpochSignal(filt_sig_decimate', ptisNeg-presamps, ptisNeg+postsamps+1));
                
                plotIt = true;
                [phase_at_0_pos_filt,f_pos_filt,r_square_pos_filt,fitline_pos_filt] = phase_calculation(betaPos,t,smooth_span,f_range,efs,plotIt);
                [phase_at_0_neg_filt,f_neg_filt,r_square_neg_filt,fitline_neg_filt] = phase_calculation(betaNeg,t,smooth_span,f_range,efs,plotIt);
            end
            
            % acausal
            [phase_at_0_pos_acaus,f_pos_acaus,r_square_pos_acaus,fitline_pos_acaus] = phase_calculation(awinsPos_acaus,t,smooth_span,f_range,efs,plotIt);
            [phase_at_0_neg_acaus,f_neg_acaus,r_square_neg_acaus,fitline_neg_acaus] = phase_calculation(awinsNeg_acaus,t,smooth_span,f_range,efs,plotIt);
            
            %%%%%%%%%%%%%%%%% hilbert
            
            fband = [12 25];
            
            [amp, phase] = hilbAmp(eco', fband, efs);
            wins_amp_pos = squeeze(getEpochSignal(amp,ptisPos-presamps,ptisPos+postsamps+1));
            wins_phase_pos = squeeze(getEpochSignal(phase,ptisPos-presamps,ptisPos+postsamps+1));
            
            wins_amp_neg = squeeze(getEpochSignal(amp,ptisNeg-presamps,ptisNeg+postsamps+1));
            wins_phase_neg = squeeze(getEpochSignal(phase,ptisNeg-presamps,ptisNeg+postsamps+1));
            
            hilbPhasePos0 = wins_phase_pos(end,:);
            hilbPhaseNeg0 = wins_phase_neg(end,:);
            
            %             figure
            %             plot(1e3*t,wins_amp_pos)
            %             hold on
            %             ave = mean(wins_amp_pos,2);
            %             plot(1e3*t,ave,'k','LineWidth',4)
            %             vline(0)
            %             title('Hilbert Amplitude - positive')
            %
            %             figure
            %             plot(1e3*t,wins_phase_pos)
            %             hold on
            %             ave = mean(wins_phase_pos,2);
            %             plot(1e3*t,ave,'k','LineWidth',4)
            %             vline(0)
            %             title('Hilbert Phase - positive ')
            %
            %             figure
            %             plot(1e3*t,wins_amp_neg)
            %             hold on
            %             ave = mean(wins_amp_neg,2);
            %             plot(1e3*t,ave,'k','LineWidth',4)
            %             vline(0)
            %             title('Hilbert Amplitude - negative ')
            %
            %             figure
            %             plot(1e3*t,wins_phase_neg)
            %             hold on
            %             ave = mean(wins_phase_neg,2);
            %             plot(1e3*t,ave,'k','LineWidth',4)
            %             vline(0)
            %             title('Hilbert Phase - negative ')
            
            % make fake vector for non pts
            if ~strcmp('ecb43e',sid)
                
                f = 0;
                phase_at_0= 0;
                r_square= 0;
                fitline = 0;
                
                %   f_caus = 0;
                %  phase_at_0_caus= 0;
                % r_square_caus= 0;
                % fitline_caus = 0;
                
                f_acaus=0;
                phase_at_0_acaus= 0;
                r_square_acaus = 0;
                fitline_acaus = 0;
                hilbPhase0 = 0;
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            %         % dont normalize for beta
            %         awinsPos = winsPos;
            %         awinsNeg = winsNeg;
            %
            %         pstimsPos = stims(:,ptsPos);
            %         pstimsneg = stims(:,ptsNeg);
            %
            %         figure
            %         plot(1e3*t,awinsPos)
            %         figure
            %         plot(1e3*t,awinsNeg)
            %
            %         figure
            %         plot(1e3*t,awinsPos)
            %         hold on
            %         ave = mean(awinsPos,2);
            %         plot(1e3*t,ave,'k','LineWidth',4)
            %         vline(0)
            %         title('beta filtered signal around positive conditioning stimuli')
            %
            %         figure
            %         plot(1e3*t,awinsNeg)
            %         hold on
            %         ave = mean(awinsNeg,2);
            %         plot(1e3*t,ave,'k','LineWidth',4)
            %         vline(0)
            %         title('beta filtered signal around negative conditioning stimuli')
            
            
            %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % try hilbert amp phase approach
            
            
        end
        
        if exist('pts')
            
            wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
            % subtract pre
            % awins =    wins-repmat(median(wins(t<0,:),1), [size(wins, 1), 1]);
            % DJC 1-14-2017 - attempt to look at epoched acausal
            
            wins_acaus = squeeze(getEpochSignal(acausal_filt', ptis-presamps, ptis+postsamps+1));
            % wins_caus = squeeze(getEpochSignal(causal_filt', ptis-presamps, ptis+postsamps+1));
            
            awins_acaus = wins_acaus;
            % awins_caus = wins_caus;
            
            awins = wins;
            % median is subtracted off in function! dont do it twice!
            
            % subtract whole thing
            % awins =    wins-repmat(mean(wins,1), [size(wins, 1), 1]);
            
            % DJC 1-23-2017 - add in sinfit
            
            
            % do the fit on the mean signal
            
            % plot intermediate steps?
            plotIt = false;
            
            %             % raw
            %
            [phase_at_0,f,r_square,fitline] = phase_calculation(awins,t,smooth_span,f_range,efs,plotIt);
            %             % causal
            %
            %             %[phase_at_0_caus,f_caus,r_square_caus,fitline_caus] = phase_calculation(awins_caus,t,smooth_span,f_range,efs,plotIt);
            %
            %             % acausal
            [phase_at_0_acaus,f_acaus,r_square_acaus,fitline_acaus] = phase_calculation(awins_acaus,t,smooth_span,f_range,efs,plotIt);
            %
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %
            %         figure
            %         plot(1e3*t,awins)
            %         hold on
            %         ave = mean(awins,2);
            %         plot(1e3*t,ave,'k','LineWidth',4)
            %         vline(0)
            %         title('beta filtered signal around conditioning stimuli')
            %
            %         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %         % try hilbert amp phase approach
            %
            
            fband = [12 25];
            
            [amp, phase] = hilbAmp(eco', fband, efs);
            wins_amp = squeeze(getEpochSignal(amp,ptis-presamps,ptis+postsamps+1));
            wins_phase = squeeze(getEpochSignal(phase,ptis-presamps,ptis+postsamps+1));
            wins_phase_unwrapped = unwrap(wins_phase);
            
            pstims = stims(:,pts);
            
            hilbPhase0 = wins_phase(end,:);
            
            %             figure
            %             plot(1e3*t,wins_amp)
            %             hold on
            %             ave = mean(wins_amp,2);
            %             plot(1e3*t,ave,'k','LineWidth',4)
            %             vline(0)
            %             title('Hilbert Amplitude')
            %
            %             figure
            %             plot(1e3*t,wins_phase)
            %             hold on
            %             ave = mean(wins_phase,2);
            %             plot(1e3*t,ave,'k','LineWidth',4)
            %             vline(0)
            %             title('Hilbert Phase')
            %             % make fake vector
            
            if ~strcmp('ecb43e',sid)
                
                f_pos=0;
                f_neg=0;
                phase_at_0_pos = 0;
                r_square_pos= 0;
                fitline_pos= 0;
                phase_at_0_neg= 0;
                r_square_neg= 0;
                fitline_neg= 0;
                
                % f_pos_caus = 0;
                % f_neg_caus = 0;
                
                % phase_at_0_pos_caus= 0;
                % r_square_pos_caus= 0;
                % fitline_pos_caus= 0;
                % phase_at_0_neg_caus= 0;
                % r_square_neg_caus= 0;
                % fitline_neg_caus= 0;
                
                f_pos_acaus = 0;
                f_neg_acaus = 0;
                phase_at_0_pos_acaus= 0;
                r_square_pos_acaus= 0;
                fitline_pos_acaus= 0;
                phase_at_0_neg_acaus= 0;
                r_square_neg_acaus= 0;
                fitline_neg_acaus= 0;
                
                hilbPhasePos0 = 0;
                hilbPhaseNeg0 = 0;
            end
            
        end
        
        
        
        %     awins = adjustStims(wins);
        
        
        % normalize windows using whole window!!! try to deal with DC offset?
        %     awins = wins-repmat(median(wins,1), [size(wins, 1), 1]);
        
        %         awins = wins;
        
        
        %%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% from a build stim tables - look
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% at raw and beta
        
        
        
        %     %
        %     % % visualize the triggers (this is slow)
        %     % figure
        %     % plot(smon)
        %     % hold all;
        %     % plot(mode, 'linew', 2)
        %     %
        %     % pts = stims(3,:)==0;
        %     % cts = stims(3,:)==1;
        %     %
        %     % plot(stims(2,pts), ones(sum(pts),1),'.');
        %     % plot(stims(2,cts), ones(sum(cts),1),'.');
        %     %
        %     % % visualize the distribution of stims per burst
        %     % figure
        %     % error('needs to be reworked for multiple conditioning types');
        %     % hist(bursts(4,:),100)
        %     %
        %     % visualize the average trigger signal
        %     figure
        %
        %     % modified by DJC 2-21-2016 to set figure to be the full size of the window
        %     %
        %     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
        %
        %     % presamp originally set to 0.020
        %     preSamp = round(0.020 * fs);
        %     postSamp = round(0.100 * fs);
        %
        %     utype = unique(ttype); %ttype is the trigger type, reports different unique types
        %
        %     cts = stims(3,:)==1; % Stims that are conditioning stimuli
        %
        %     dat = squeeze(getEpochSignal(beta', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of beta signals
        %     rdat = squeeze(getEpochSignal(raw', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of raw ECoG signals
        %
        %     % first eliminate those where storage was incorrect:
        %     % bads = sum(rdat==0,1)>10;
        %
        %     % dat(:, bads) = [];
        %     % rdat(:,bads) = [];
        %
        %     bdat = rdat - repmat(mean(rdat(1:100,:)), size(rdat, 1), 1);
        %
        %     t = (-preSamp:postSamp) / fs;
        %
        %     stimtypes = stims(8, cts);
        %
        %     for idx = 1:length(utype)
        %         mtype = utype(idx);
        %         subplot(length(utype),2,2*(idx-1)+1);
        %
        %         mdat = squeeze(dat(:, stimtypes==mtype));
        %         badmoment = diff(mdat,1,1)==0;
        %         badmoment = cat(1, false(1, size(badmoment, 2)), badmoment);
        %         mdat(badmoment) = NaN;
        %         %     bads = mean(diff(mdat,1,1)==0) > 0.05;
        %         plot(1e3*t, 1e6*mdat(:,1:10:end)','color', [0.5 0.5 0.5]);
        %         hold on;
        %
        %         plot(1e3*t, 1e6*nanmean(squeeze(mdat),2), 'r', 'linew', 2);
        %         xlabel('Time (msec)');
        %         ylabel('Trigger signal (uV)');
        %         title(sprintf('average \\beta trigger; cond type = %d', mtype));
        %         xlim([min(1e3*t) max(1e3*t)]);
        %
        %         %     ylim([-120 120]);
        %         vline(0, 'k:');
        %
        %         subplot(length(utype),2,2*(idx-1)+2);
        %         mrdat = squeeze(rdat(:, stimtypes==mtype));
        %         plot(1e3*t, 1e6*mrdat(:,1:10:end)','color', [0.5 0.5 0.5]);
        %         hold on;
        %
        %         plot(1e3*t, 1e6*mean(squeeze(mrdat),2), 'r', 'linew', 2);
        %         xlabel('Time (msec)');
        %         ylabel('Trigger signal (uV)');
        %         title(sprintf('average raw response; cond type = %d', mtype));
        %         xlim([min(1e3*t) max(1e3*t)]);
        %         ylim([-120 120]);
        %         vline(0, 'k:');
        %
        %
        %     end
        %
        %     % SaveFig(OUTPUT_DIR, sprintf('trigger-%s', sid), 'eps', '-r600'); % changed OUTPUT_DIR to allow figure to save
        %     % SaveFig(OUTPUT_DIR, sprintf('trigger-%s', sid), 'png', '-r600');
        %
        %     % %%
        %     % figure
        %     % for c = 1:1000
        %     %     plot(t, dat(:,1, c));
        %     %     pause
        %     % end
        %     %
        %     %
        %     % %%
        %     % res = [];
        %     %
        %     % for e = 1:4431
        %     % %     res(e) = any(find(diff(dat(:,1,e)) > 1e-6));
        %     %     res(e) = rdat(find(t>0,1,'first'),1,e)==0;
        %     %
        %     % end
        %     % %%
        %     % figure
        %     % for c = find(res)
        %     %     plot(t, rdat(:,1,c));
        %     %     pause
        %     % end
        %
        %     %     %% TEMP
        %     %     figure
        %     %     hist = find(mode ~= 0 & smon ~= 0);
        %     %     X = getEpochSignal(beta', hist-round(fs*0.1), hist+round(fs*.1));
        %     %     t= round(-fs*.1):round(fs*.1);
        %     %     t(end) = [];
        %     %     plot(t/fs, squeeze(X))
        %     %     vline(0)
        %     %     vline(-390/fs, 'k:')
        %     %     hold all
        %     %     plot(t/fs, mean(squeeze(X)'), 'k', 'linew', 3);
        %     %
        %     %
        %     %
        %
        
        
        if strcmp(sid,'0b5a2e')
            sid = '0b5a2e_mod';
        end
        
        %         save(fullfile(OUTPUT_DIR, [sid '_' num2str(chan) '_phaseDelivery_v2.mat']), 'sid','t','r_square','r_square_acaus','r_square_caus','r_square_neg_acaus','r_square_pos','r_square_neg','r_square_neg_caus',...
        %             'r_square_pos_acaus','r_square_pos_caus','phase_at_0_pos','fitline_pos','phase_at_0_neg','fitline_neg',...
        %             'phase_at_0_pos_caus','fitline_pos_caus','phase_at_0_neg_caus','fitline_neg_caus',...
        %             'phase_at_0_pos_acaus','fitline_pos_acaus','phase_at_0_neg_acaus','fitline_neg_acaus',...
        %             'phase_at_0','r_square','fitline','phase_at_0_caus','r_square_caus','fitline_caus','phase_at_0_acaus','r_square_acaus','fitline_acaus',...
        %             'f','f_caus','f_acaus','f_pos','f_neg','f_pos_caus','f_neg_caus','f_pos_acaus','f_neg_acaus');
        %
        save(fullfile(OUTPUT_DIR, [sid '_' num2str(chan) '_phaseDelivery_v3.mat']), 'sid','t','r_square','r_square_acaus','r_square_neg_acaus','r_square_pos','r_square_neg',...
            'r_square_pos_acaus','phase_at_0_pos','fitline_pos','phase_at_0_neg','fitline_neg',...
            'phase_at_0_pos_acaus','fitline_pos_acaus','phase_at_0_neg_acaus','fitline_neg_acaus',...
            'phase_at_0','r_square','fitline','phase_at_0_acaus','fitline_acaus',...
            'f','f_acaus','f_pos','f_neg','f_pos_acaus','f_neg_acaus',...
            'hilbPhase0','hilbPhasePos0','hilbPhaseNeg0');
        
        if strcmp(sid,'0b5a2e_mod')
            sid = '0b5a2e';
        end
        
        close all; clearvars -except idx SIDS OUTPUT_DIR META_DIR SUB_DIR chan chans sid tp block 'bursts' 'fs' 'stims'
    end
    
end
