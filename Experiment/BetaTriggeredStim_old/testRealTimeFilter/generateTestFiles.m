%% 3-30-2018 - DJC generate sine waves to test TDT filtering abilities
% using white matter (c) output to bnc
% generate sine waves between 12 and 20

Fs = 12207; % sampling rate Hz


% time each frequency 
timeFreq = 2;
tTotal = timeFreq*Fs;

t=0:1/Fs:timeFreq;
t = t(1:end-1);
fVec = [12:20];
ampVec = [0.5,1]; % amplitude
ampVecLong = zeros(size(t));
ampVecLong(1:length(ampVecLong)/2) = ampVec(1);
ampVecLong(length(ampVecLong)/2+1:end) = ampVec(2);

%y=sin(2*pi*f*t);
reppedT = repmat(t,length(fVec),1)';
reppedF = repmat(fVec,tTotal,1);
reppedAmp = repmat(ampVecLong,length(fVec),1)';
%
y = reppedAmp.*sin(2*pi.*reppedF.*reppedT);
%
figure
plot(t,y)
%%
%y = y(t>32)
figure
p = nextpow2(length(y));
NFFT = 2^p;
X=fftshift(fft(y,NFFT));         
fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;        
plot(fVals,abs(X),'b');      
title('Double Sided FFT - with FFTShift');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([0 30])

%%
tTotal = 0:1/Fs:(timeFreq*length(fVec));
tTotal = tTotal(1:end-1);
yTotal = reshape(y,1,[]);

figure
plot(tTotal,yTotal)
%%
%y = y(t>32)
figure
p = nextpow2(length(yTotal));
NFFT = 2^p;
X=fftshift(fft(y,NFFT));         
fVals=Fs*(-NFFT/2:NFFT/2-1)/NFFT;        
plot(fVals,abs(X),'b');      
title('Double Sided FFT - with FFTShift');       
xlabel('Frequency (Hz)')         
ylabel('|DFT Values|');
xlim([0 30])

%%

figure
spectrogram(yTotal,[],[],[],Fs,'yaxis')
colormap bone
view(-45,65)
ylim([0 30e-3])

%%
audiowrite('sampleBeta.wav',yTotal,Fs)
