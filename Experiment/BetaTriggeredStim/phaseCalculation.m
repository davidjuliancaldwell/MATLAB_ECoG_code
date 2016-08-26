 %% 8-26-2016 - function calculate phase of stimulation delivery 
% FROM STAVROS
% instantaneous phase
% 50 ms before, up to stim 
% 
% sinfit(data_to_fit,smoothing variable, range of period of sinusoid (30 - 70 ms), samples (not equal spacing of samples))
% at fs = 24414, 30-70 ms range period -> 366->854 samples 
% 
% return phase (initial phase), period, amplitude, R^2, 
% 	Know phase of first sample, find phase of second 

preSamp = round(0.025 * fs);
postSamp = round(0.100 * fs);

utype = unique(ttype); %ttype is the trigger type, reports different unique types

cts = stims(3,:)==1; % Stims that are conditioning stimuli

dat = squeeze(getEpochSignal(beta', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of beta signals
rdat = squeeze(getEpochSignal(raw', stims(2, cts)-preSamp, stims(2, cts)+postSamp+1)); %getting segments of raw ECoG signals

% first eliminate those where storage was incorrect:
% bads = sum(rdat==0,1)>10;

% dat(:, bads) = [];
% rdat(:,bads) = [];

t = (-preSamp:postSamp) / fs;

stimtypes = stims(8, cts);

figure
for idx = 1:length(utype)
    mtype = utype(idx);
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
    
  
    
end