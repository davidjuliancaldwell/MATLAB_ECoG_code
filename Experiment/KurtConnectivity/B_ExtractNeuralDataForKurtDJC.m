%% Extract neural data for Kurt Connectivity - start with subject 9ab7ab
% idea is to look at Beta-triggered stim data as starter, consider
% CONDITIONING pulses that are not after (which would be a test pulse
% anyways) Beta stimulation, nor the pulse right before a beta stim train

%% Constants
Z_ConstantsKurtConnectivity;
addpath ./experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%


tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
block = 'BetaPhase-3';
stims = [59 60];
chans = [1:64]; % want to look at all channels, DJC 8-28-2015

% chans = [51 52 53 58 57]; % DJC 8-31-2015, look at channels that were deemed potentially interesting before by Miah/Jared to see if I can see anything
% chans(ismember(chans, stims)) = []; want to look at stim channels too!

sid = '9ab7ab';

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
conditionStims = stims(:,stims(3,:)==1);

%% Trying to process ecog
%% process each ecog channel individually

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
    
    toc;
    
    %convert between the fs and efs of the beta recorded channel and the
    %grid recorded channels from the TDT
    fac = fs/efs;
    presamps = round(0.2 * efs); % pre time in sec
    postsamps = round(0.1 * efs); % post time in sec
    
    ptis = round(conditionStims(2,:)/fac); %sample point in time (relative to ECoG recording) where stimulation occured
    
    %% interpolate to get rid of stimulus artifact
    % linearly interpolate from (-5ms) before stimulus to 10 ms after (roughly
    % same as keller paper, similar to miah, so -0.005 to 0.010
    
    interp_start = (ptis-round(0.005*efs));
    interp_stop = (ptis+round(0.010*efs));
    
    
    for j = 1:length(interp_start)
        eco(interp_start(j):interp_stop(j)) = interp1(([(interp_start(j)-1) (interp_stop(j)+1)]),eco([(interp_start(j)-1) (interp_stop(j)+1)]),(interp_start(j):interp_stop(j)));
    end
    
    
    eco = bandpass(eco, 1, 40, efs, 4, 'causal');
    eco = toRow(notch(eco, 60, efs, 2, 'causal'));
    
    % filter the signal
    sig = squeeze(getEpochSignal(eco', ptis-presamps, ptis+postsamps+1));
    
    
    t = (-presamps:postsamps)/efs;
    
    % normalize the windows to each other, using pre data
    awins = sig-repmat(mean(sig(t<0,:),1), [size(sig, 1), 1]);
    
    mu = mean(awins,2);
    stdErr = (std(awins,0,2)/sqrt(size(awins,2)));
    
    %     sig_epoch_chan{chan} = awins;
    %     sig_epoch_chan_mu{chan} = mu;
    %     sig_epoch_chan_stdErr{chan} = stdErr;
    
    %% plot dat
    
    subplot(8,8,chan)
    
    plot(1e3*t, 1e6*mu);
    xlim(1e3*[min(t) max(t)]);
    yl = ylim;
    yl(1) = min(-10, max(yl(1),-120));
    yl(2) = max(10, min(yl(2),100));
    ylim(yl);
    hold on
    vline(0);
    
    hold on
    plot(1e3*t, 1e6*(mu+stdErr))
    hold on
    
    plot(1e3*t, 1e6*(mu-stdErr))
    
    xlabel('time (ms)');
    ylabel('ECoG (uV)');
    title(sprintf('EP By %s, %d', sid, chan))
    
    %
    %     %%
    %     subplot(8,8,chan)
    %     plot(sig_epoch_chan{chan})
    %     title(sprintf('electrode %d',chan))
    
    %% spectrogram plot
    
    figure
    
    [Cm, f, t] = spectrogram(mu, 80, 40, 1:200, efs, 'yaxis');
    Cmn = bsxfun(@rdivide, abs(Cm), mean(abs(Cm),2));
    imagesc(t,f,Cmn); axis xy
    colorbar
    set(gca,'clim',[0 4])
    set(gca,'clim',[0 3.5])
    
    %% time frequency wavelet analysis
    
%     fw = [1:3:200];
%     [C, ~, ~, ~] = time_frequency_wavelet(mu, fw, efs, 1, 1, 'CPUtest');
% %     normC=normalize_plv(C',C(t<0)');
%     
%     imagesc(t,fw,normC);
%     axis xy;
%     set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);
    
end


%looping through channels, and then each stimulation window for
%interpolation


% below doesn't work
% sig(:,(interp_start:interp_stop)) = interp1(([interp_start-1' interp_stop+1']),sig(:,[interp_start-1' interp_stop+1']),(interp_start:interp_stop));


%% break signal into epochs

for i = 1:length(Blck.info.ChannelNumbers)
    
    
    %     sig_epoch_chan{i} = sig_epoch_chan{i}';
    
end


%%
figure
plot(sig_epoch_chan{35})