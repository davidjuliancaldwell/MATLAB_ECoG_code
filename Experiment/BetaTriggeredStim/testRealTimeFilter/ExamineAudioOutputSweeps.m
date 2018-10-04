% 4-18-2018
% DJC - examine sweeps of white matter

DATA_DIR = "G:\My Drive\whiteMatterTestFunctions\4-17-2018-Test-AudioOutput\Matlab";

filesVec = [1:9];
fsVec = [12:20];

phaseVecPosRaw = [];
degreesVecPosRaw = [];
phaseVecNegRaw = [];
degreesVecNegRaw = [];

phaseVecPosFilt = [];
degreesVecPosFilt = [];
phaseVecNegFilt = [];
degreesVecNegFilt = [];

plotFFT = 0;
plotTime = 0;
plotFit = 0;

for ind = filesVec
    ind
    prefix = 'BetaStim-';
    filename = strcat(prefix,num2str(ind),'.mat');
    load(fullfile(DATA_DIR,filename))
    
    rawSignal = ECO1.data(:,1);
    fsRawSignal = ECO1.info.SamplingRateHz;
    pre = 50; % pre signal time ms
    post = 0;
    preSamps = round(fsRawSignal * pre/1e3);
    postSamps = round(fsRawSignal * post/1e3);
    
    mode = Wave.data(:,2)';
    ttype = Wave.data(:,1)';
    smon = SMon.data(:,2)';
    [bursts,stims] = build_stim_table(smon,ttype,mode);
    
    knownStimDelay = round(fsRawSignal*0.2867/1e3);
    
    
    [condPtsPos,condPtsNeg,testPts] = extract_testPulse(stims);
    fac = SMon.info.SamplingRateHz/fsRawSignal;
    % get epochs
    
    endsPos = round(stims(2,condPtsPos)/fac)+knownStimDelay + postSamps;
    beginsPos = round(stims(2,condPtsPos)/fac+knownStimDelay) - preSamps;
    endsNeg = round(stims(2,condPtsNeg)/fac)+knownStimDelay + postSamps;
    beginsNeg = round(stims(2,condPtsNeg)/fac)+knownStimDelay - preSamps;
    
    signalPos = squeeze(getEpochSignal(rawSignal,beginsPos,endsPos));
    signalNeg = squeeze(getEpochSignal(rawSignal,beginsNeg,endsNeg));
    
    t = (-preSamps+1:postSamps)*1e3/fsRawSignal;
    
    if plotTime
        figure
        subplot(2,1,1)
        plot(t,signalPos)
        set(gca,'fontsize',14)
        title(['Positive and negative segments on raw signal for frequency = ' num2str(fsVec(ind)) ' Hz'])
        
        subplot(2,1,2)
        plot(t,signalNeg)
        xlabel('time (ms)')
        set(gca,'fontsize',14)
        ylabel('signal (V)');
    end
    
    % set parameters for fit function
    f_range = [8 25];
    smooth_span = 13;
    [phase_at_0_posRaw,f,Rsquare,FITLINE] = phase_calculation(signalPos,t,smooth_span,f_range,fsRawSignal,plotFit);
    [phase_at_0_negRaw,f,Rsquare,FITLINE] = phase_calculation(signalNeg,t,smooth_span,f_range,fsRawSignal,plotFit);
    
    if plotFFT
        figure
        [f,P1] = fft_compute(fsRawSignal,rawSignal);
        plot(f,P1,'b');
        xlim([0 100])
        title('Double Sided FFT - with FFTShift');
        xlabel('Frequency (Hz)')
        ylabel('|DFT Values|');
        xlim([0 100])
        
        %         figure
        %         p = nextpow2(length(rawSignal));
        %         NFFT = 2^p;
        %         X=fftshift(fft(rawSignal,NFFT));
        %         fVals=fsRawSignal*(-NFFT/2:NFFT/2-1)/NFFT;
        %         plot(fVals,abs(X),'b');
        %         title('Double Sided FFT - with FFTShift');
        %         xlabel('Frequency (Hz)')
        %         ylabel('|DFT Values|');
        %                 xlim([0 100])
        
    end
    
    filteredSignal = Wave.data(:,3);
    fsFiltered = Wave.info.SamplingRateHz;
    trigger = SMon.data(:,2);
    
    if plotTime
        figure
        
        plot(rawSignal)
        
        
        figure
        plot(filteredSignal)
        
        xlabel('time (samples)')
        set(gca,'fontsize',14)
        ylabel('signal (V)');
        legend('raw signal','filtered signal')
    end
    
    filteredSignalDecimated = decimate(filteredSignal,2); % decimate because it's stored at double the rate of Eco
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    signalPos = squeeze(getEpochSignal(filteredSignalDecimated ,beginsPos,endsPos));
    signalNeg = squeeze(getEpochSignal(filteredSignalDecimated ,beginsNeg,endsNeg));
    
    t = (-preSamps+1:postSamps)*1e3/fsRawSignal;
    
    if plotTime
        figure
        subplot(2,1,1)
        plot(t,signalPos)
        title(['Positive and negative segments on filtered signal for frequency = ' num2str(fsVec(ind)) ' Hz'])
        
        set(gca,'fontsize',14)
        
        subplot(2,1,2)
        plot(t,signalNeg)
        xlabel('time (ms) ')
        set(gca,'fontsize',14)
        ylabel('signal (V)');
    end
    
    % set parameters for fit function
    f_range = [8 25];
    smooth_span = 13;
    [phase_at_0_posFilt,f,Rsquare,FITLINE] = phase_calculation(signalPos,t,smooth_span,f_range,fsRawSignal,plotFit);
    [phase_at_0_negFilt,f,Rsquare,FITLINE] = phase_calculation(signalNeg,t,smooth_span,f_range,fsRawSignal,plotFit);
    
    % compare raw and filtered
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    phaseDiffPos = rad2deg(phase_at_0_posRaw-phase_at_0_posFilt);
    phaseDiffNeg = rad2deg(phase_at_0_negRaw-phase_at_0_negFilt);
    
    phaseVecPos{ind} = phaseDiffPos;
    phaseVecNeg{ind} = phaseDiffNeg;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if plotFFT
        figure
        [f,P1] = fft_compute(fsFiltered/2,filteredSignalDecimated);
        plot(f,P1,'b');
        xlim([0 100])
        title('Double Sided FFT - with FFTShift');
        xlabel('Frequency (Hz)')
        ylabel('|DFT Values|');
        xlim([0 100])
        
        %         figure
        %         p = nextpow2(length(filteredSignal));
        %         NFFT = 2^p;
        %         X=fftshift(fft(filteredSignal,NFFT));
        %         fVals=fsFiltered*(-NFFT/2:NFFT/2-1)/NFFT;
        %         plot(fVals,abs(X),'b');
        %         title('Double Sided FFT - with FFTShift');
        %         xlabel('Frequency (Hz)')
        %         ylabel('|DFT Values|');
        %         xlim([0 100])
    end
    
    if plotTime
        if length(rawSignal)>length(filteredSignalDecimated)
            rawSignal = rawSignal(1:length(filteredSignalDecimated));
        end
        
        t1 = 1e3*[0:length(filteredSignalDecimated)-1]/fsRawSignal;
        fig1 = figure;
        plot(t1,rawSignal,'linewidth',2)
        hold on
        plot(t1,filteredSignalDecimated,'linewidth',2)
        timeStamps = find(trigger>0);
        timeStamps = 1e3*((timeStamps/2)/fsRawSignal);
        vline([timeStamps],'k:');
        
        legend({'Raw Signal','Filtered Signal','Stimulation Trigger'})
        xlabel('time (ms)')
        ylabel('amplitude (V)')
        set(gca,'fontsize', 14)
        title(['Operation of Real Time Filtering with Stimulation Blanking - frequency input = ' num2str(fsVec(ind))])
        fig1.Position = [447.6667 786.3333 1408 420];
        %xlim([1.0e5*0.9590 1.0e5*1.0268]);
        % ylim([-0.09 0.09]);
    end
    
end
%%

phaseVecMeanPos = cellfun(@mean,phaseVecPos);
phaseVecMeanNeg = cellfun(@mean,phaseVecNeg);
phaseVecStdPos = cellfun(@std,phaseVecPos);
phaseVecStdNeg = cellfun(@std,phaseVecNeg);

% measured stim delay is 7 samples , 0.2867 ms

for ind = filesVec
    phaseVecMeanPosSecs(ind) = 1e3*abs(mean(phase_diff(deg2rad(phaseVecPos{ind}),fsVec(ind))));
    phaseVecMeanNegSecs(ind) = 1e3*abs(mean(phase_diff(deg2rad(phaseVecNeg{ind}),fsVec(ind))));
    phaseVecStdPosSecs(ind) = 1e3*std(phase_diff(deg2rad(phaseVecPos{ind}),fsVec(ind)));
    phaseVecStdNegSecs(ind) = 1e3*std(phase_diff(deg2rad(phaseVecNeg{ind}),fsVec(ind)));
    
end


figure
subplot(1,2,1)
xlabel('frequency (Hz)')

yyaxis left
errorbar(fsVec,phaseVecMeanPos,phaseVecStdPos,'linewidth',2)
ylabel('Phase Difference (Degrees)')

yyaxis right
errorbar(fsVec,phaseVecMeanPosSecs,phaseVecStdPosSecs,'linewidth',2)
ylabel('Difference (ms)')
title('positive')
set(gca,'fontsize',14)
%%%%%%%%%


subplot(1,2,2)
xlabel('frequency (Hz)')

yyaxis left
errorbar(fsVec,phaseVecMeanNeg,phaseVecStdNeg,'linewidth',2)
ylabel('Phase Difference (Degrees)')

yyaxis right
errorbar(fsVec,phaseVecMeanNegSecs,phaseVecStdNegSecs,'linewidth',2)
xlabel('frequency (Hz)')
ylabel('Difference (ms)')
title('negative')
set(gca,'fontsize',14)



set(gca,'fontsize',14)
