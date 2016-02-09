%% Simulated stim pulses for time/ frequency analysis 

Wp = 200;% microseconds per pulse 
Wps = 4; % pulse width in samples
Fs = 24414; % sampling rate (check with system to make sure that this is correct)
Fp = 200; % frequency of pulse train
locsStim = 1:((1/Fp)*Fs):Fs;
locsStim = int16(locsStim);
amp = 1; % stim amplitude

% build the stim train

stim = zeros (1,Fs);

clear idx
for idx = 1:length(locsStim)
    stim (locsStim(idx):(locsStim(idx)+Wps-1)) = amp;
    stim ((locsStim(idx)+ Wps):(locsStim(idx)+((2*Wps)-1))) = -amp;
end

figure; plot (stim)
xlabel('Seconds');
ylabel('Amplitude');

%% Take FFT and plot

T=1/Fs;
L= length(stim);

t = (0:L-1)*T;

NFFT = 2^nextpow2(L);

Y = fft(stim.*hanning(length(stim))',NFFT)/L;
f = Fs/2*linspace(0,1,NFFT/2+1);
% Plot single-sided amplitude spectrum.
figure;
semilogy(f,2*abs(Y(1:NFFT/2+1)))

figure;
loglog(f,2*abs(Y(1:NFFT/2+1)))

title('Single-Sided Amplitude Spectrum of y(t)')
xlabel('Frequency (Hz)')
ylabel('|Y(f)|')

%% Waveform generation techniques
Y(1:200) = Y(1:200) *1e-25 + 0i; %determines amplitude of attenuated 1-200 Hz
figure;
plot(f,2*abs(Y(1:NFFT/2+1)));
title('Single-Sided Amplitude Spectrum of y(t)');
xlabel('Frequency (Hz)');
ylabel('|Y(f)|');
inverse = ifft(Y, 'symmetric');
figure; plot (inverse)

figure;
loglog(f,2*abs(Y(1:NFFT/2+1)))