
% read in CSF from Oscilloscope
%data = csvread('aawFile0.csv',2,0); % 14 Hz beta

filesVec = [1:9];
fsVec = [12:20];
phaseVec = [];
degreesVec = [];
plotFFT = 1;

for ind = filesVec
    
    prefix = 'NewFile';
    filename = strcat(prefix,num2str(ind-1),'.csv');
    data = csvread(filename,2,0);
    freq = fsVec(1);
    time = data(:,1);
    fs = 1/(time(2)-time(1));
    
    % channel 1 is the beta signal
    channel1 = data(:,2);
    % channel 2 is the stimulator
    channel2 = data(:,3);
    
    %
    % plot raw signals
    figure
    plot(time,channel1)
    hold on
    plot(time,channel2)
    legend('beta generated signal','stimulation registered')
    
    
    %%
    % get rid of noise
    channel2(abs(channel2)<0.5)=0;
    figure
    plot(time,channel1)
    hold on
    plot(time,channel2)
    legend('beta generated signal','stimulation registered')
    
    %%
    figure
    % use diff of signal to find onsets
    diffChannel2 = [diff(channel2); 0];
    plot(diffChannel2)
    inds = find(diffChannel2>0.1);
    diffOfInds = diff(inds);
    indsFirst = inds([diffOfInds<100]);
    indsFirst = indsFirst(indsFirst > 200);
%     hold on
    % plot vline for first stim in train
    vline(indsFirst);
    
    %%
    timeBefore = 83.33; % ms before
    timeAfter = 0;
    timeBeforeSamps = timeBefore*fs/1e3;
    timeAfterSamps = timeAfter*fs/1e3;
    startInds = round(indsFirst-timeBeforeSamps);
    endInds = round(indsFirst+timeAfterSamps);
    tEpoch = round(-timeBeforeSamps:timeAfterSamps-1)*1e3/fs;
    epochedBeta = squeeze(getEpochSignal(channel1,startInds,endInds));
    figure
    plot(tEpoch,epochedBeta)
    
    %% fit it
    
    % set parameters for fit function
    fRange = [10 30];
    smoothSpan = 13;
    plotFit = 0;
    [phaseAt0,f,Rsquare,FITLINE] = phase_calculation(epochedBeta,tEpoch,smoothSpan,fRange,fs,plotFit);
    
    phaseDeg = rad2deg(phaseAt0);
    diffs = 90 - phaseDeg;
    phaseDiffs = 1e3*(phase_diff(deg2rad(diffs),freq));
    
    phaseDiffsVec(ind) = phaseDiffs(1);
    diffsVec(ind) = diffs(1); 
    
    
end

%%
figure
xlabel('frequency (Hz)')

yyaxis left
plot(fsVec,diffsVec,'linewidth',2)
ylabel('Phase Difference (Degrees)')

yyaxis right
plot(fsVec,abs(phaseDiffsVec)','linewidth',2)
ylabel('Difference (ms)')
title('Phase difference and time delay as registered on an oscilloscope')
set(gca,'fontsize',14)
%%%%%%%%%


% compare raw and filtered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%phaseDiff = rad2deg(phase_at_0-phase_at_0);

%phaseVec{ind} = phaseDiff;
