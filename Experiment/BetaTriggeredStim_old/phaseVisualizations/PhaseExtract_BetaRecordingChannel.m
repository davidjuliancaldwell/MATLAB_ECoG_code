%% 11-9-2016
% script to look at signal pulled from beta recording channel as
% approximation to phase delivery at beta channel

%% Constants
close all; clear all;clc
% cd 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Code\Experiment\BetaTriggeredStim'
Z_Constants;
addpath ./scripts/ %DJC edit 7/20/2015;

SUB_DIR = fullfile(myGetenv('subject_dir'));
% OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

%% parameters

% need to be fixed to be nonspecific to subject
% SIDS = SIDS(2:end);
%SIDS = SIDS(2);

sid = input('input SID \n','s');
%DJC edited 7/20/2015 to fix tp paths
switch(sid)
    case '8adc5c'
        % sid = SIDS{1};
        tp = strcat(SUB_DIR,'\8adc5c\data\D6\8adc5c_BetaTriggeredStim');
        block = 'Block-67';
        stims = [31 32];
        chans = [8 7 48];
    case 'd5cd55'
        % sid = SIDS{2};
        tp = strcat(SUB_DIR,'\d5cd55\data\D8\d5cd55_BetaTriggeredStim');
        block = 'Block-49';
        stims = [54 62];
        chans = [53 61 63];
        chans = [1:64];
        
        
        goods = sort([44 45 46 52 53 55 60 61 63]);
        betaChan = 53;
        
        % have to set t_min and t_max for each subject
        %t_min = 0.004833;
        % t_min of 0.005 would find the really early ones
        t_min = 0.008;
        t_max = 0.05;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
%         
%         
%         beta = tank.readWaveEvent('Blck', 1)';
%         raw = tank.readWaveEvent('Blck', 2)';
%         mode = tank.readWaveEvent('Wave', 2)';
%         ttype = tank.readWaveEvent('Wave', 1)';

% djc 5-10-2017 ? 
         raw = tank.readWaveEvent('Wave', 2)';

         beta = tank.readWaveEvent('Wave', 1)';
        
         ttype = 0*beta;
        
        
        %     % these three lines will get rid of the large simuli at the beginning
        %     % of the record
        %     mode(1:4.5e6) = [];
        %     beta(1:4.5e6) = [];
        %     smon(1:4.5e6) = [];
        
        %     % these three lines will get rid of all stimuli until we reset the
        %     % threshold value
        %     mode(1:36536266) = [];
        %     beta(1:36536266) = [];
        %     smon(1:36536266) = [];
        
        %     % these lines will get rid of all stimuli after we reset the threshold
        %     % value
        %     mode(36536266:end) = [];
        %     beta(36536266:end) = [];
        %     smon(36536266:end) = [];
        %     mode(1:4.5e6) = [];
        %     beta(1:4.5e6) = [];
        %     smon(1:4.5e6) = [];
        
        
        
    case 'c91479'
        % sid = SIDS{3};
        tp = strcat(SUB_DIR,'\c91479\data\d7\c91479_BetaTriggeredStim');
        block = 'BetaPhase-14';
        stims = [55 56];
        chans = [64 63 48];
        chans = [1:64];
        
        betaChan = 64;
        goods = sort([ 39 40 47 48 63 64]);
        t_min = 0.008;
        t_max = 0.035;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
        % these lines will get rid of the time period at the end of the record
        % where we were trying a lower max stim frequency
        mode(64507402:end) = 0;
        ttype(64507402:end) = 0;
        beta(64507402:end) = 0;
        raw(64507402:end) = 0;
        
        % these lines will get rid of the time period at the beginning of
        % the record where we were changing parameter settings
        mode(1:2e7) = 0;
        ttype(1:2e7) = 0;
        beta(1:2e7) = 0;
        raw(1:2e7) = 0;
        
        
    case '7dbdec'
        % sid = SIDS{4};
        tp = strcat(SUB_DIR,'\7dbdec\data\d7\7dbdec_BetaTriggeredStim');
        block = 'BetaPhase-17';
        stims = [11 12];
        chans = [4 5 14];
        chans = [1:64];
        
        goods = sort([4 5 10 13]);
        betaChan = 4;
        t_min = 0.008;
        t_max = 0.04;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
        
    case '9ab7ab'
        %             sid = SIDS{5};
        tp = strcat(SUB_DIR,'\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
        block = 'BetaPhase-3';
        stims = [59 60];
        chans = [51 52 53 58 57];
        chans = [1:64];
        
        % chans = 29;
        
        % chans = 29;
        betaChan = 51;
        
        goods = sort([42 43 49 50 51 52 53 57 58]);
        t_min = 0.005;
        t_max = 0.0425;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
        ttype = 0*mode;
        
        
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
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
        [smon, info] = tank.readWaveEvent('SMon', 2);

        
        
    case 'ecb43e' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\ecb43e\data\d7\BetaStim');
        block = 'BetaPhase-3';
        stims = [56 64];
        chans = [47 55];
        chans = [1:64];
        
        betaChan = 55;
        goods = sort([55 63 54 47 48]);
        t_min = 0.008;
        t_max = 0.05;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
        
    case '0b5a2e' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        block = 'BetaPhase-2';
        stims = [22 30];
        chans = [23 31];
        
        betaChan = 31;
        goods = sort([12 13 14 15 16 20 21 23 31 32 39 40]);
        % goods = [14 21 23 31];
        bads = [20 24 28];
        t_min = 0.005;
        t_max = 0.05;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
    case '0b5a2ePlayback' % added DJC 7-23-2015
        tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        block = 'BetaPhase-4';
        stims = [22 30];
        chans = [23 31];
        
        betaChan = 31;
        goods = sort([12 13 14 15 16 21 23 31 32 39 40]);
        bads = [20 24 28];
        t_min = 0.005;
        t_max = 0.05;
        
        tank = TTank;
        tank.openTank(tp);
        tank.selectBlock(block);
        
        
        beta = tank.readWaveEvent('Blck', 1)';
        raw = tank.readWaveEvent('Blck', 2)';
        mode = tank.readWaveEvent('Wave', 2)';
        ttype = tank.readWaveEvent('Wave', 1)';
        
    otherwise
        error('unknown SID entered');
end

chans(ismember(chans, stims)) = [];

%% load in the trigger data
% 9-2-2015 DJC added mod DJC
% below is for original miah style burst tables

load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
% below is for modified burst tables
%         load(fullfile(META_DIR, [sid '_tables_modDJC.mat']), 'bursts', 'fs', 'stims');

% below is for EXTRA modified burst table of d5cd55, leaving out the
% ones that miah and jared said 2-22-2016

%     load(fullfile(META_DIR, [sid '_tables_modDJC_2_22_2016.mat']), 'bursts', 'fs', 'stims');




% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];


%%

if (strcmp(sid,'0b5a2ePlayback') | strcmp(sid,'0b5a2e'))
    figure
    
    preSamp = round(0.020 * fs);
    postSamp = round(0.100 * fs);
    
    utype = unique(ttype); %ttype is the trigger type, reports different unique types
    
    % DJC 1-11-2016 to account for
    if strcmp(sid,'0b5a2ePlayback')
        
        utype = [0 1 2];
        
    end
    
    
    cts = stims(3,:)==1; % Stims that are conditioning stimuli
    
    dat = squeeze(getEpochSignal(beta', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of beta signals
    rdat = squeeze(getEpochSignal(raw', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of raw ECoG signals
    
    % first eliminate those where storage was incorrect:
    % bads = sum(rdat==0,1)>10;
    
    % dat(:, bads) = [];
    % rdat(:,bads) = [];
    
    bdat = rdat - repmat(mean(rdat(1:100,:)), size(rdat, 1), 1);
    
    t = (-preSamp:postSamp) / fs;
    
    stimtypes = stims(8, cts);
    
    
    suffix = cell(1,3);
    suffix{1} = 'Negative phase of Beta';
    suffix{2} = 'Positive phase of Beta';
    suffix{3} = 'Null Condition';
    
    
    for idx = 1:length(utype)-1 % modified to discount null condition for 0b5a2e, which is utype(3)
        mtype = utype(idx);
        subplot(length(utype)-1,2,2*(idx-1)+1);
        
        mdat = squeeze(dat(:, stimtypes==mtype));
        badmoment = diff(mdat,1,1)==0;
        badmoment = cat(1, false(1, size(badmoment, 2)), badmoment);
        mdat(badmoment) = NaN;
        %     bads = mean(diff(mdat,1,1)==0) > 0.05;
        plot(1e3*t, 1e6*mdat(:,1:10:end)','color', [0.5 0.5 0.5]);
        hold on;
        
        plot(1e3*t, 1e6*nanmean(squeeze(mdat),2), 'r', 'linew', 2);
        xlabel('Time (msec)');
        ylabel('Trigger signal (uV)');
        title(sprintf('average \\beta trigger; cond type = %s', suffix{idx}));
        xlim([min(1e3*t) max(1e3*t)]);
        
        %     ylim([-120 120]);
        vline(0, 'k:');
        
        subplot(length(utype)-1,2,2*(idx-1)+2);
        mrdat = squeeze(rdat(:, stimtypes==mtype));
        plot(1e3*t, 1e6*mrdat(:,1:10:end)','color', [0.5 0.5 0.5]);
        hold on;
        
        plot(1e3*t, 1e6*mean(squeeze(mrdat),2), 'r', 'linew', 2);
        xlabel('Time (msec)');
        ylabel('Trigger signal (uV)');
        title(sprintf('average raw response; cond type = %s', suffix{idx}));
        xlim([min(1e3*t) max(1e3*t)]);
        ylim([-120 120]);
        vline(0, 'k:');
        
         f_range = [10 30];
        t_range = 1./f_range;
        t_range = t_range.*fs;
        smooth_span = 1;
        
        % do the fit on the mean signal
                blah = figure;

        sig_ave = nanmean(squeeze(mdat),2);
        [pha_a,T_a,amp_a,rsquare_a,~] = sinfit(1e6*sig_ave,smooth_span,t_range);
                f = 1/(T_a/fs);
            a = amp_a.*sin(pha_a+(2*pi*t*f));
            plot(t,a,t,1e6*sig_ave)
        
        
    end
    
    
    
    subtitle(sprintf('%s',sid))
    %
    
else
    fig1 = figure;
            fig2 = figure;

    % modified by DJC 2-21-2016 to set figure to be the full size of the window
    %
    %set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    
    % presamp originally set to 0.020
    preSamp = round(0.050 * fs);
    postSamp = round(0.100 * fs);
    
    utype = unique(ttype); %ttype is the trigger type, reports different unique types
    
    cts = stims(3,:)==1; % Stims that are conditioning stimuli
    
    dat = squeeze(getEpochSignal(beta', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of beta signals
    rdat = squeeze(getEpochSignal(raw', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of raw ECoG signals
    
    % first eliminate those where storage was incorrect:
    % bads = sum(rdat==0,1)>10;
    
    % dat(:, bads) = [];
    % rdat(:,bads) = [];
    
    bdat = rdat - repmat(mean(rdat(1:100,:)), size(rdat, 1), 1);
    
    t = (-preSamp:postSamp) / fs;
    
    stimtypes = stims(8, cts);
    
    for idx = 1:length(utype)
        mtype = utype(idx);
        figure(fig1)
        subplot(length(utype),2,2*(idx-1)+1);
        
        mdat = squeeze(dat(:, stimtypes==mtype));
        badmoment = diff(mdat,1,1)==0;
        badmoment = cat(1, false(1, size(badmoment, 2)), badmoment);
        mdat(badmoment) = NaN;
        %     bads = mean(diff(mdat,1,1)==0) > 0.05;
        plot(1e3*t, 1e6*mdat(:,1:10:end)','color', [0.5 0.5 0.5]);
        hold on;
        
        plot(1e3*t, 1e6*nanmean(squeeze(mdat),2), 'r', 'linew', 2);
        xlabel('Time (msec)');
        ylabel('Trigger signal (uV)');
        title(sprintf('average \\beta trigger; cond type = %d', mtype));
        xlim([min(1e3*t) max(1e3*t)]);
        
        %     ylim([-120 120]);
        vline(0, 'k:');
        
        % DJC - 11/9/2016
        
        f_range = [10 30];
        t_range = 1./f_range;
        t_range = t_range.*fs;
        smooth_span = 1;
        
%         % do the fit on the mean signal
%                 figure
% 
%         sig_ave = nanmean(squeeze(mdat),2);
%         [pha_a,T_a,amp_a,rsquare_a,~] = sinfit(1e6*sig_ave,smooth_span,t_range);
%                 f = 1/(T_a/fs);
%             a = amp_a.*sin(pha_a+(2*pi*t*f));
%             plot(t,a,t,1e6*sig_ave)
%         
%         
        %figure
%         
%         for i = 1:size(mdat,2)
%             
%             signal = mdat(:,i);
%             % find contiguous stretch of nan
%             
%             %https://www.mathworks.com/matlabcentral/newsreader/view_thread/257862
%             F = find(isnan([NaN,signal',NaN]));
%             D = diff(F)-2;
%             [M,L] = max(D);
%             sigInterest = signal(F(L):F(L)+M); % The longest block
%             tInterest = t(F(L):F(L)+M);
%             [pha(i),T(i),amp(i),rsquare(i),~] = sinfit(sigInterest,smooth_span,t_range);
%             
%             f = 1/(T(i)/fs);
%             a = amp(i).*sin(pha(i)+(2*pi*tInterest*f));
%             plot(tInterest,a,tInterest,sigInterest)
%             pause;
%         end
%         
%         
        
        figure(fig1)
        subplot(length(utype),2,2*(idx-1)+2);
        mrdat = squeeze(rdat(:, stimtypes==mtype));
        plot(1e3*t, 1e6*mrdat(:,1:10:end)','color', [0.5 0.5 0.5]);
        hold on;
        
        plot(1e3*t, 1e6*mean(squeeze(mrdat),2), 'r', 'linew', 2);
        xlabel('Time (msec)');
        ylabel('Trigger signal (uV)');
        title(sprintf('average raw response; cond type = %d', mtype));
        xlim([min(1e3*t) max(1e3*t)]);
        ylim([-120 120]);
        vline(0, 'k:');
        
        figure(fig2)
        plot(nanmean(mdat,2))
        hold on
        plot(mean(mrdat,2));
        ylim([-10e-5 10e-5])
%         
        
    end
    
    % SaveFig(OUTPUT_DIR, sprintf('trigger-%s', sid), 'eps', '-r600'); % changed OUTPUT_DIR to allow figure to save
    % SaveFig(OUTPUT_DIR, sprintf('trigger-%s', sid), 'png', '-r600');
    
    % %%
    % figure
    % for c = 1:1000
    %     plot(t, dat(:,1, c));
    %     pause
    % end
    %
    %
    % %%
    % res = [];
    %
    % for e = 1:4431
    % %     res(e) = any(find(diff(dat(:,1,e)) > 1e-6));
    %     res(e) = rdat(find(t>0,1,'first'),1,e)==0;
    %
    % end
    % %%
    % figure
    % for c = find(res)
    %     plot(t, rdat(:,1,c));
    %     pause
    % end
end

