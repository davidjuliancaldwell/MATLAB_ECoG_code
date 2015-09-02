function signal = SimulateBroadband(lengthOfSignal, samplingRate, frequencyRange, numberOfSignalsToAdd, randomPhaseOffset, falloffExponent, subFreqDecimation)


    if nargin < 3
        error('Matlab:SimulateBroadband', 'Usage: SimulateBroadband(lengthOfSignal, samplingRate,frequencyRange, numberOfSignalsToAdd=5, randomPhaseOffset=true, falloffExponent=2,subFreqDecimation=1)');
        return;
    end
    
    if ~exist('numberOfSignalsToAdd','var')
        numberOfSignalsToAdd = 5;
    end
    if ~exist('randomPhaseOffset','var')
        randomPhaseOffset = 1;
    end
    if ~exist('falloffExponent','var')
        falloffExponent = 2;
    end
    if ~exist('subFreqDecimation','var')
        subFreqDecimation = 1;
    end
    
    samples = 1:lengthOfSignal;
    
        %PARAMS
%     randomPhaseOffset = 1;
%     samples = 1:50000;
%     samplingRate = 1000;
%     falloffExponent = 1;
%     frequencyRange = 70:200;
%     numberOfSignalsToAdd = 2;
    if subFreqDecimation == 0
        subFreqDecimation = 1;
        randomizeFreqs = 1;
    else
        randomizeFreqs = 0;
    end


    %Generate signal
    signal = zeros(size(samples));
    for i=1:numberOfSignalsToAdd
        for freq=frequencyRange(1):subFreqDecimation:frequencyRange(2);
            
            freq = freq + rand(1,1) * randomizeFreqs;

            % Apply randon phase offset if needed
            phaseOffset = (rand(1,1) * 2 * pi) * (randomPhaseOffset > 0);

            scale = samplingRate * freq * 2 * pi;
            % generate sin wave
            out = sin(samples/samplingRate * freq * 2 * pi + phaseOffset);

            %scale by 1/f^x
            out = out / (freq.^falloffExponent);

            signal = signal + out;
        end
    end
return

% figure;
% pwelch(signal,fs/4,fs/10,[],fs);
% figure;
% hold on;
% plot(signal);
% plot(abs(hilbert(signal)),'r');