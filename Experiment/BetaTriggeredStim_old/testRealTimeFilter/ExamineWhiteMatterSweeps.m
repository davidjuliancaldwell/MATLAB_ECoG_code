% 4-13-2018
% DJC - examine sweeps of white matter

DATA_DIR = "G:\My Drive\whiteMatterTestFunctions";

filesVec = [3:11];
fsVec = [12:20];
phaseVec = [];
degreesVec = [];

plotFFT = 1;

for ind = filesVec
    prefix = 'BetaStim-';
    filename = strcat(prefix,num2str(ind),'.mat');
    load(fullfile(DATA_DIR,filename))
    
    rawSignal = ECO1.data(:,1);
    fsRawSignal = ECO1.info.SamplingRateHz;
    
    mode = Wave.data(:,2)';
    ttype = Wave.data(:,2)';
    smon = SMon.data(:,2)';
    [bursts,stims] = build_stim_table(smon,ttype,mode);
    [condPtsPos,condPtsNeg] = extract_testPulse(stims);
    
    % get epochs 
    
                % set parameters for fit function
                plotIt = 1;
            f_range = [10 30];
            smooth_span = 13;
            phase_calculation(awinsPos,t,smooth_span,f_range,fsRawSignal,plotIt);
    
    if plotFFT
        figure
        p = nextpow2(length(rawSignal));
        NFFT = 2^p;
        X=fftshift(fft(rawSignal,NFFT));
        fVals=fsRawSignal*(-NFFT/2:NFFT/2-1)/NFFT;
        plot(fVals,abs(X),'b');
        title('Double Sided FFT - with FFTShift');
        xlabel('Frequency (Hz)')
        ylabel('|DFT Values|');
        xlim([0 100])
    end
    
    figure
    
    plot(rawSignal)
    filteredSignal = Wave.data(:,3);
    fsFiltered = Wave.info.SamplingRateHz;
    trigger = SMon.data(:,2);
    
    figure
    plot(filteredSignal)
    filteredSignalDecimated = decimate(filteredSignal,2); % decimate because it's stored at double the rate of Eco
    
    if plotFFT
        figure
        p = nextpow2(length(filteredSignal));
        NFFT = 2^p;
        X=fftshift(fft(filteredSignal,NFFT));
        fVals=fsFiltered*(-NFFT/2:NFFT/2-1)/NFFT;
        plot(fVals,abs(X),'b');
        title('Double Sided FFT - with FFTShift');
        xlabel('Frequency (Hz)')
        ylabel('|DFT Values|');
        xlim([0 100])
    end
    
    
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
    ylabel('amplitude')
    set(gca,'fontsize', 14)
    title('Operation of Real Time Filtering with Stimulation Blanking')
    fig1.Position = [447.6667 786.3333 1408 420];
    %xlim([1.0e5*0.9590 1.0e5*1.0268]);
    % ylim([-0.09 0.09]);
    
end