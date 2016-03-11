%% Extract neural data for screening CCEPs.
% modified from the Kurt script 1-10-2016 by DJC

%% Constants
close all;clear all;clc
% Z_ConstantsKurtConnectivity;

% changed 3-7-2016 by DJC for CCEP amath project
Z_Constants

addpath c:/users/david/desktop/research/raolab/matlab/code/experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%
sid = input('enter subject ID ','s');

%9ab7ab
switch(sid)
    case '9ab7ab'
        tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        chans = [1:64]; % want to look at all channels, DJC 8-28-2015
        
        % chans = [51 52 53 58 57]; % DJC 8-31-2015, look at channels that were deemed potentially interesting before by Miah/Jared to see if I can see anything
        % chans(ismember(chans, stims)) = []; want to look at stim channels too!
        %%
        %'ecb43e'
    case 'd5cd55'
        % sid = SIDS{2};
        tp = 'D:\Subjects\d5cd55\data\D8\d5cd55_BetaTriggeredStim';
        block = 'Block-49';
        stimChans = [54 62];
        %         chans = [53 61 63];
        chans = [1:64];
        
    case 'c91479'
        % sid = SIDS{3};
        tp = 'D:\Subjects\c91479\data\d7\c91479_BetaTriggeredStim';
        block = 'BetaPhase-14';
        stimChans = [55 56];
        %         chans = [64 63 48];
        chans = [1:64];
        
    case '7dbdec'
        % sid = SIDS{4};
        tp = 'D:\Subjects\7dbdec\data\d7\7dbdec_BetaTriggeredStim';
        block = 'BetaPhase-17';
        stimChans = [11 12];
        %         chans = [4 5 14];
        chans = [1:64];
        
    case '9ab7ab'
        %             sid = SIDS{5};
        tp = 'D:\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        %         chans = [51 52 53 58 57];
        chans = [1:64];
        
        % chans = 29;
    case '702d24'
        tp = 'D:\Subjects\702d24\data\d7\702d24_BetaStim';
        block = 'BetaPhase-4';
        stimChans = [13 14];
        %         chans = [4 5 21];
        chans = [1:64];
        %             chans = [36:64];
        
    case 'ecb43e'
        tp = 'D:\Subjects\ecb43e\data\d7\BetaStim';
        block = 'BetaPhase-3';
        stimChans = [56 64];
        chans = [1:64];
        %         chans = [47 55]; want to look at all channels
    case '0b5a2e' % added DJC 7-23-2015
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim';
        block = 'BetaPhase-2';
        stimChans = [22 30];
        chans = [1:64];
    case '0b5a2ePlayback' % added DJC 7-23-2015
        tp = 'D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim';
        block = 'BetaPhase-4';
        stimChans = [22 30];
        chans = [1:64];
        
end
%% load in the trigger data
if strcmp(sid,'0b5a2ePlayback')
    load(fullfile(META_DIR, ['0b5a2e' '_tables.mat']), 'bursts', 'fs', 'stims');
    
    % this was for discovering the delay, now it's known to be about
    % 577869
    %         tic;
    %         [smon, info] = tank.readWaveEvent('SMon', 2);
    %         smon = smon';
    %
    %         fs = info.SamplingRateHz;
    %
    %         stim = tank.readWaveEvent('SMon', 4)';
    %         toc;
    %
    %         tic;
    %         mode = tank.readWaveEvent('Wave', 2)';
    %         ttype = tank.readWaveEvent('Wave', 1)';
    %
    %         beta = tank.readWaveEvent('Blck', 1)';
    %
    %         raw = tank.readWaveEvent('Blck', 2)';
    %
    %         toc;
    
    delay = 577869;
else
    
    % below is for original miah style burst tables
    %         load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
    % below is for modified burst tables
    load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
end

% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];

% drop any probe stimuli without a corresponding pre-burst/post-burst
% still want to do this for selecting conditioning - DJC, as this in the
% next step ensures we only select conditioning up to last one before beta
% stim train    bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));

stims(:, bads) = [];


% adjust stim and burst tables for 0b5a2e playback case

if strcmp(sid,'0b5a2ePlayback')
    
    stims(2,:) = stims(2,:)+delay;
    bursts(2,:) = bursts(2,:) + delay;
    bursts(3,:) = bursts(3,:) + delay;
    
end


% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];



bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];

tank = TTank;
tank.openTank(tp);
tank.selectBlock(block);

% after load in the stim table, switch meta directory to where we will
% store stats table

META_DIR = 'D:\Output\AMATH582\meta';
%% find where conditioning pulses are

% 9-1-2015 - this all is based off of assumption that conditioning pulses
% are the ones between beta bursts, which is false! Conditioning pulses are
% the ones that fall in the beta stimulation trains

% % find out where stims are
% testIds = (stims(3,:)==0);
% % shift over all the testIds
% testIds(1) = [];
% % pad logical to be the same size as before
% testIds = logical([testIds 0]);
%
% % get rid of conditioning stimuli that are before a test pulse
% stims(:,testIds) = [];

% pick conditioning stimuli - 9/1/2015 - want to look at response around
% conditioning stimuli

% conditionStims = stims(:,stims(3,:)==1);


%% find test pulses that are not right after burst or right before


%% Trying to process ecog
%% process each ecog channel individually


significantChans = [];
zCell = cell(1,length(chans));
muCell = cell(1,length(chans));
stdErrCell = cell(1,length(chans));

% figure

for chan = chans
    %% load in ecog data for that channel
    fprintf('loading in ecog data:\n');
    tic;
    grp = floor((chan-1)/16);
    ev = sprintf('ECO%d', grp+1);
    achan = chan - grp*16;
    
    %         [eco, efs] = tdt_loadStream(tp, block, ev, achan);
    [eco, info] = tank.readWaveEvent(ev, achan);
    efs = info.SamplingRateHz;
    eco = eco';
    
    fac = fs/efs;
    
    toc;
    %% preprocess eco
    presamps = round(0.025 * efs); % pre time in sec
    postsamps = round(0.120 * efs); % post time in sec
    
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
    
    if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
        ct = max(last, last2);
    end
    
    % look at NON interpolated signal, DJC, 1-10-2016
    %     for sti = 1:length(sts)
    %         win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
    %
    %         % interpolation approach
    %         eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
    %     end
    %     %
    %     eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
    %     eco = toRow(notch(eco, 60, efs, 2, 'causal'));
    
    %% Process Triggers 9-3-2015
    
    pts = stims(3,:)==0;
    ptis = round(stims(2,pts)/fac);
    
    
    % change presamps and post samps to be what Kurt wanted to look at
    presamps = round(0.2 * efs); % pre time in sec
    postsamps = round(0.2 * efs); % post time in sec
    
    t = (-presamps:postsamps)/efs;
    wins = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    
    % normalize the windows to each other, using pre data
    awins = wins-repmat(mean(wins(t<0,:),1), [size(wins, 1), 1]);
    
    pstims = stims(:,pts);
    types = unique(bursts(5,pstims(4,:)));
    
    % using idea of probes from Extracting neural data, <250 ms after the end
    % of the beta burst, AND NOT EQUAL TO NULL
    
    if strcmp('0b5a2e',sid) || strcmp('0b5a2ePlayback',sid)
        
        % this is for 0b5a2e
        probes = pstims(5,:) < .250*fs & bursts(5,pstims(4,:))~=types(2);
    else
        % this is for 9ab7ab (and others)
        probes = pstims(5,:) < .250*fs;
    end
    
    %     keeper = ((pstims(5,:)>(0.25*fs))&(pstims(7,:)>(0.25*fs)));
    keeper = probes;
    
    types = unique(bursts(5,pstims(4,:)));
    
    kwins = awins(:,keeper);
    
    % added DJC 3/9/2016 to save individual responses, want signals x
    % observations x channels
    ECoGData(:,:,chan) = kwins;
    
    
    preBegin = -0.2;
    preEnd = -0.005;
    preRange = find(t>=preBegin & t<=preEnd);
    
    
    % peak begin at 10 ms
    peakBegin = 0.010;
    peakEnd = 0.080;
    peakRange = find(t>=peakBegin & t<=peakEnd);
    
    %for now, doing PEAK of average signal
    %     peaks = zeros(1, size(kwins,2));
    preStim = kwins((preRange),:);
    
    %     9-3-2015 - for now, doing peak of AVERAGE signal
    %     for c = 1:size(kwins,2)
    %
    %         peaks(1,c) = max(abs(kwins(peakRange,c)));
    %
    %     end
    
    %% 9-3-2015
    % Below is one method of looking at zscore, assuming we do zscore on a
    % trial by trial basis
    %     % Compute X's mean and sd, and standardize it
    %     dim = 1; % take mean along pre samples (vector column wise of data)
    %     flag = 0; % for use with StdDev function, means use N-1 normalization
    %     mu = mean(preStim,dim);
    %     sigma = std(preStim,flag,dim);
    %     sigma0 = sigma;
    %     sigma0(sigma0==0) = 1;
    %     z = bsxfun(@minus,peaks, mu);
    %     z = bsxfun(@rdivide, z, sigma0);
    %     z_avg = mean(z);
    %% This is more according to keller, where he did average signal, and THEN computed zscore against baseline points of AVERAGED signal
    %
    
    mu = mean(kwins,2);
    
    peakMax = max(abs(mu(peakRange)));
    
    baseAvg = mean(mu(preRange));
    
    sigma = std(mu(preRange),0,1);
    sigma0 = sigma;
    %     sigma0(sigma0==0) = 1; for a single calculation, do not believe this
    %     is neccessary
    z = (peakMax - baseAvg);
    z = z/sigma0;
    z_avg = z;
    
    stdErr = (std(kwins,0,2)/sqrt(size(kwins,2)));
    
    zCell{chan} = z_avg;
    muCell{chan} = mu;
    stdErrCell{chan} = stdErr;
    
    if z_avg>6 & ~any(chan==stimChans);
        
        significantChans = [significantChans chan];
        
    end
    
    
    %%
    %     %% DJC - 9-3-2015 For the time being, do what Miah did before (above), and consider code below as possible future work
    %
    %     %convert between the fs and efs of the beta recorded channel and the
    %     %grid recorded channels from the TDT
    %     fac = fs/efs;
    %     presamps = round(0.2 * efs); % pre time in sec
    %     postsamps = round(0.1 * efs); % post time in sec
    %
    %     ptis = round(conditionStims(2,:)/fac); %sample point in time (relative to ECoG recording) where stimulation occured
    %
    %     %% interpolate to get rid of stimulus artifact
    %     % linearly interpolate from (-5ms) before stimulus to 10 ms after (roughly
    %     % same as keller paper, similar to miah, so -0.005 to 0.010
    %
    %     interp_start = (ptis-round(0.005*efs));
    %     interp_stop = (ptis+round(0.010*efs));
    %
    %
    %     for j = 1:length(interp_start)
    %         eco(interp_start(j):interp_stop(j)) = interp1(([(interp_start(j)-1) (interp_stop(j)+1)]),eco([(interp_start(j)-1) (interp_stop(j)+1)]),(interp_start(j):interp_stop(j)));
    %     end
    %
    %
    %     eco = bandpass(eco, 1, 40, efs, 4, 'causal');
    %     eco = toRow(notch(eco, 60, efs, 2, 'causal'));
    %
    %     % filter the signal
    %     sig = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    %
    %
    %     t = (-presamps:postsamps)/efs;
    %
    %     % normalize the windows to each other, using pre data
    %     awins = sig-repmat(mean(sig(t<0,:),1), [size(sig, 1), 1]);
    
    %     sig_epoch_chan{chan} = awins;
    %     sig_epoch_chan_mu{chan} = mu;
    %     sig_epoch_chan_stdErr{chan} = stdErr;
    
    %% plot dat
    
%     subplot(8,8,chan)
%     
%     plot(1e3*t, 1e6*mu,'m','LineWidth',2);
%     %     xlim(1e3*[min(t) max(t)]);
%     xlim(1e3*[-0.025 0.08]);
%     %     yl = ylim;
%     %     yl(1) = min(-10, max(yl(1),-120));
%     %     yl(2) = max(10, min(yl(2),100));
%     %     ylim(yl);
%     ylim([-100 100]); % change this depending on the subject
%     hold on
%     vline(0);
%     
%     hold on
%     plot(1e3*t, 1e6*(mu+stdErr))
%     hold on
%     
%     plot(1e3*t, 1e6*(mu-stdErr))
%     
%     %     xlabel('time (ms)');
%     %     ylabel('ECoG (uV)');
%     title(sprintf('Chan %d', chan))
%     
    
    %%
    %     subplot(8,8,chan)
    %     plot(sig_epoch_chan{chan})
    %     title(sprintf('electrode %d',chan))
    
    %% spectrogram plot
    %
    %     figure
    %
    %     [Cm, f, t] = spectrogram(mu, 80, 40, 1:200, efs, 'yaxis');
    %     Cmn = bsxfun(@rdivide, abs(Cm), mean(abs(Cm),2));
    %     imagesc(t,f,Cmn); axis xy
    %     colorbar
    %     set(gca,'clim',[0 4])
    %     set(gca,'clim',[0 3.5])
    
    %% time frequency wavelet analysis
    
    %     fw = [1:3:200];
    %     [C, ~, ~, ~] = time_frequency_wavelet(mu, fw, efs, 1, 1, 'CPUtest');
    % %     normC=normalize_plv(C',C(t<0)');
    %
    %     imagesc(t,fw,normC);
    %     axis xy;
    %     set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);
    
end

%% put subtitle on graph, units
% 
% hold on
% xlabel('time (ms)');
% ylabel('ECoG (uV)');
% 
% subtitle('Cortico-Cortical Evoked Potentials')

%% do plot of all significnat channels

% figure
% for i = significantChans
%     mu = muCell{i};
%     stdErr = stdErrCell{i};
%     chan = i;
%     figure
%     
%     plot(1e3*t, 1e6*mu);
%     xlim(1e3*[-0.025 0.2]);
%     %     xlim(1e3*[min(t) max(t)]);
%     %     yl = ylim;
%     %     yl(1) = min(-10, max(yl(1),-120));
%     %     yl(2) = max(10, min(yl(2),100));
%     %     ylim(yl);
%     ylim([-100 100])
%     hold on
%     vline(0);
%     
%     hold on
%     plot(1e3*t, 1e6*(mu+stdErr))
%     hold on
%     
%     plot(1e3*t, 1e6*(mu-stdErr))
%     title(sprintf('Chan %d', chan))
%     %
%     %     xlabel('time (ms)');
%     %     ylabel('ECoG (uV)');
%     %
%     %     title(sprintf('CCEP, Channel %d', chan))
%     
%     
%     
% end


%% do a plot of all channels

% figure
% 
% for i = chans
%     mu = muCell{i};
%     stdErr = stdErrCell{i};
%     chan = i;
%     subplot(8,8,i)
%     
%     plot(1e3*t, 1e6*mu);
%     xlim(1e3*[-0.025 0.2]);
%     %     xlim(1e3*[min(t) max(t)]);
%     %     yl = ylim;
%     %     yl(1) = min(-10, max(yl(1),-120));
%     %     yl(2) = max(10, min(yl(2),100));
%     %     ylim(yl);
%     ylim([-30 30])
%     hold on
%     vline(0);
%     
%     hold on
%     plot(1e3*t, 1e6*(mu+stdErr))
%     hold on
%     
%     plot(1e3*t, 1e6*(mu-stdErr))
%     title(sprintf('Chan %d', chan))
%     %
%     %     xlabel('time (ms)');
%     %     ylabel('ECoG (uV)');
%     %
%     %     title(sprintf('CCEP, Channel %d', chan))
%     
%     
%     
% end
%% do a plot of all channels one by one

% figure
% 
% for i = chans
%     mu = muCell{i};
%     stdErr = stdErrCell{i};
%     chan = i;
%     
%     plot(1e3*t, 1e6*mu);
%     xlim(1e3*[-0.025 0.08]);
%     %     xlim(1e3*[min(t) max(t)]);
%     %     yl = ylim;
%     %     yl(1) = min(-10, max(yl(1),-120));
%     %     yl(2) = max(10, min(yl(2),100));
%     %     ylim(yl);
%     ylim([-100 100])
%     hold on
%     vline(0);
%     
%     hold on
%     plot(1e3*t, 1e6*(mu+stdErr))
%     hold on
%     
%     plot(1e3*t, 1e6*(mu-stdErr))
%     title(sprintf('Chan %d', chan))
%     %
%     %     xlabel('time (ms)');
%     %     ylabel('ECoG (uV)');
%     %
%     %     title(sprintf('CCEP, Channel %d', chan))
%     pause(1)
%     clf
%     
%     
% end
% %%
muMat = cell2mat(muCell);

% added DJC 3-9-2016, for stacking the individual traces 
% subselect t, ECoGData, ECoGdata Stacked to make it more managable ,
% otherwise it was 1.27 GB!

ECoGData = ECoGData((t>-0.01 & t < 0.120),:,:);
t = t(t>-0.01 & t< 0.120);

ECoGDataStacked = reshape(ECoGData,[size(ECoGData,1)*...
    size(ECoGData,2),size(ECoGData,3)]);

save(fullfile(META_DIR, [sid '_IndividualCCEPs.mat']), 't','ECoGData','ECoGDataStacked');

% save(fullfile(META_DIR, [sid '_StatsCCEPhuntNOTNULL.mat']), 'zCell', 't','muCell','muMat','stdErrCell');

%% plot cortex

switch(sid)
    case '9ab7ab'
        load('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d4\9ab7ab_baseline8001\9ab7ab_baseline8S001R01_montage.mat')
        
        locs = trodeLocsFromMontage(sid, Montage, false);
        
        % use significant channels
        zVec = cell2mat(zCell);
        zVec(zVec < 6) = NaN;
        
        % now plot the weights on the subject specific brain. PlotDotsDirect has a
        % bunch of input arguments
        figure;
        
        clims = [6 40];
        PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
            locs, ... % the location of the electrodes
            zVec, ... % the weights to use for coloring
            'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
            clims, ... % the color limits for the weights
            15, ... % the size of the dots, in points I believe
            'recon_colormap', ... % the colormap to use for dot coloration
            1:64, ... % labels for the electrodes, I think this can be a cell array
            true, ... % a boolean switch as to whether or not to draw the labels
            false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
        % calls to PlotDotsDirect where you don't want to keep
        % re-drawing the brain over itself
        
        % very often, after plotting the brain and dots, I add a colorbar for
        % reference as to what the dot colors mean
        load('recon_colormap'); % needs to be the same as what was used in the function call above
        colormap(cm);
        colorbar;
        
    case 'ecb43e'
        
        %there appears to be no montage for this subject currently
        Montage.Montage = 64;
        Montage.MontageTokenized = {'Grid(1:64)'};
        Montage.MontageString = Montage.MontageTokenized{:};
        Montage.MontageTrodes = zeros(size(eco,2), 3);
        Montage.BadChannels = [];
        Montage.Default = true;
        
        % get electrode locations
        locs = trodeLocsFromMontage(sid, Montage, false);
        
        % use significant channels
        zVec = cell2mat(zCell);
        zVec(zVec < 6) = NaN;
        
        % now plot the weights on the subject specific brain. PlotDotsDirect has a
        % bunch of input arguments
        figure;
        
        clims = [6 40];
        PlotDotsDirect(sid, ... % the subject on who's brain the electrodes will be drawn
            locs, ... % the location of the electrodes
            zVec, ... % the weights to use for coloring
            'l', ... % the hemisphere of the brain to draw (can be 'l', 'r', or 'b')
            clims, ... % the color limits for the weights
            10, ... % the size of the dots, in points I believe
            'recon_colormap', ... % the colormap to use for dot coloration
            1:64, ... % labels for the electrodes, I think this can be a cell array
            true, ... % a boolean switch as to whether or not to draw the labels
            false); % a boolean switch as to whether or not to redraw the cortex, used for multiple
        % calls to PlotDotsDirect where you don't want to keep
        % re-drawing the brain over itself
        
        % very often, after plotting the brain and dots, I add a colorbar for
        % reference as to what the dot colors mean
        load('recon_colormap'); % needs to be the same as what was used in the function call above
        colormap(cm);
        colorbar;
        
        
end