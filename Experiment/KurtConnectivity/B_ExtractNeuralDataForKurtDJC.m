%% Extract neural data for Kurt Connectivity - start with subject 9ab7ab
% idea is to look at Beta-triggered stim data as starter, consider
% CONDITIONING pulses that are not after (which would be a test pulse
% anyways) Beta stimulation, nor the pulse right before a beta stim train

%% Constants
Z_ConstantsKurtConnectivity;
addpath ./experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%
sid = input('enter subject ID ','s');

%9ab7ab
switch(sid)
    case '9ab7ab'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        chans = [1:64]; % want to look at all channels, DJC 8-28-2015
        
        % chans = [51 52 53 58 57]; % DJC 8-31-2015, look at channels that were deemed potentially interesting before by Miah/Jared to see if I can see anything
        % chans(ismember(chans, stims)) = []; want to look at stim channels too!
        %%
        %'ecb43e'
    case 'ecb43e'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim';
        block = 'BetaPhase-3';
        stimChans = [56 64];
        chans = [1:64];
        %         chans = [47 55]; want to look at all channels
        
end
%% load in the trigger data
load(fullfile(META_DIR, [sid '_tables.mat']), 'bursts', 'fs', 'stims');
% drop any stims that happen in the first 500 milliseconds
stims(:,stims(2,:) < fs/2) = [];


% drop any probe stimuli without a corresponding pre-burst/post-burst
% still want to do this for selecting conditioning - DJC, as this in the
% next step ensures we only select conditioning up to last one before beta
% stim train
bads = stims(3,:) == 0 & (isnan(stims(4,:)) | isnan(stims(6,:)));
stims(:, bads) = [];

tank = TTank;
tank.openTank(tp);
tank.selectBlock(block);

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

figure

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
    
    for sti = 1:length(sts)
        win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
        
        % interpolation approach
        eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
    end
    %
    eco = toRow(bandpass(eco, 1, 40, efs, 4, 'causal'));
    eco = toRow(notch(eco, 60, efs, 2, 'causal'));
    
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
    
    % baselines picked to be ones greater 500 ms after beta burst AND more
    % than 500 ms before next beta burst
    
    % try 0.25, similar to Miah's baselines from other script
    keeper = ((pstims(5,:)>(0.25*fs))&(pstims(7,:)>(0.25*fs)));
    
    types = unique(bursts(5,pstims(4,:)));
    
    kwins = awins(:,keeper);
    
    preBegin = -0.2;
    preEnd = -0.005;
    preRange = find(t>=preBegin & t<=preEnd);
    
    peakBegin = 0.005;
    peakEnd = size(kwins,1);
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
    
    subplot(8,8,chan)
    
    plot(1e3*t, 1e6*mu);
    %     xlim(1e3*[min(t) max(t)]);
    xlim(1e3*[-0.025 0.2]);
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    ylim([-30 30]); % change this depending on the subject 
    hold on
    vline(0);
    
    hold on
    plot(1e3*t, 1e6*(mu+stdErr))
    hold on
    
    plot(1e3*t, 1e6*(mu-stdErr))
    
    %     xlabel('time (ms)');
    %     ylabel('ECoG (uV)');
    title(sprintf('Chan %d', chan))
    
    
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

hold on
xlabel('time (ms)');
ylabel('ECoG (uV)');

subtitle('Cortico-Cortical Evoked Potentials')

%% do plot of all significnat channels 

% figure
for i = significantChans
    mu = muCell{i};
    stdErr = stdErrCell{i};
    chan = i;
        figure
    
    plot(1e3*t, 1e6*mu);
    xlim(1e3*[-0.025 0.2]);
    %     xlim(1e3*[min(t) max(t)]);
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    ylim([-100 100])
    hold on
    vline(0);
    
    hold on
    plot(1e3*t, 1e6*(mu+stdErr))
    hold on
    
    plot(1e3*t, 1e6*(mu-stdErr))
    title(sprintf('Chan %d', chan))
    %
%     xlabel('time (ms)');
%     ylabel('ECoG (uV)');
%     
%     title(sprintf('CCEP, Channel %d', chan))

    

end


%% do a plot of all channels 

figure

for i = chans
    mu = muCell{i};
    stdErr = stdErrCell{i};
    chan = i;
    subplot(8,8,i)
    
    plot(1e3*t, 1e6*mu);
    xlim(1e3*[-0.025 0.2]);
    %     xlim(1e3*[min(t) max(t)]);
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
    ylim([-30 30])
    hold on
    vline(0);
    
    hold on
    plot(1e3*t, 1e6*(mu+stdErr))
    hold on
    
    plot(1e3*t, 1e6*(mu-stdErr))
    title(sprintf('Chan %d', chan))
    %
    %     xlabel('time (ms)');
    %     ylabel('ECoG (uV)');
    %
    %     title(sprintf('CCEP, Channel %d', chan))
    
    
    
end
%%
save(fullfile(META_DIR, [sid '_Stats.mat']), 'zCell', 'muCell','stdErrCell');

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