function [spectra, hz, avSpectra, avSpectraSem, sortedPeriods] = restingStimAnalysis(epochs, periods, fs, method)
    % argcheck
    if (~exist('method', 'var'))
        method = 'fft';
    end
    
    if (strcmpi(method, 'fft'))
        method = 'fft';
    elseif (strcmpi(method, 'pwelch'))
        method = 'pwelch';
    else
        error('unknown method specified');
    end
    
    
    % do the work
    switch (method)
        case 'fft'
            spectra = zeros(floor(size(epochs, 1) / 2)+1, size(epochs, 2), size(epochs, 3));

            for obs = 1:size(epochs, 3)
                [spectra(:,:,obs), hz] = mfft(epochs(:,:,obs), 1, fs); 
            end    

            spectra = abs(spectra);
        case 'pwelch'
            % assuming 500 msec windows with 250 msec overlap
            nfft = fs / 2;
            
            spectra = zeros(nfft/2+1, size(epochs, 2), size(epochs, 3));
                        
            for obs = 1:size(epochs, 3)
                for chan = 1:size(epochs, 2)
                    [spectra(:,chan,obs), hz] = pwelch(epochs(:,chan,obs), nfft, nfft/2, nfft, fs);
                end
            end
    end
    
    % spectra are on the log scale
    spectra = 20*log10(spectra);
    
    % drop the frequencies above 200 Hz
    droppable = hz > 200;
    spectra(droppable, :, :) = [];
    hz(droppable) = [];
    
    % break down by period
    sortedPeriods = unique(periods);
    
    avSpectra = zeros(length(hz), size(spectra, 2), length(sortedPeriods));
    avSpectraSem = zeros(length(hz), size(spectra, 2), length(sortedPeriods));
    
    for periodIdx = 1:length(sortedPeriods)
        spectraFromPeriod = spectra(:,:,periods==sortedPeriods(periodIdx));
        avSpectra(:,:,periodIdx) = mean(spectraFromPeriod, 3);
        avSpectraSem(:,:,periodIdx) = sem(spectraFromPeriod, 3);
    end    
end