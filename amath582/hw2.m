%% David Caldwell - AMATH 582 - Homework 2

% get a clean workspace
close all;clear all;clc

% change to directory where files are located
cd C:/Users/David/Desktop/Research/RaoLab/MATLAB/Code/amath582

%% PART 1
% provided code to plot portions of music to be analyzed
load handel
v = y'/2;
plot((1:length(v))/Fs,v);
xlabel('Time [sec]');
ylabel('Amplitude');
title('Time series of Handel''s Messiah');

%% to play back music
% p8 = audioplayer(v,Fs);
% playblocking(p8);

%% Fourier analysis

% time vector is 1:length of the signal/frequency of sampling
t = ((1:length(v))/Fs);

% fs is 8192, start with number of points for the FFT being the next power
% of 2 from the length of the signal
npow2 = nextpow2(length(v));
n = 2^npow2;


% scale by Fs/n to get appropriate bounds on frequencies, and to get the
% frequency in Hz
k = (Fs/n)*[0:(n/2)-1 -n/2:-1];
ks = fftshift(k);

% Fourier transform it
vt = fft(v,n);

figure(1)

% time domain
subplot(2,1,1)
plot(t,v,'b')
set(gca,'Fontsize',[14]),
xlabel('Time [sec]'), ylabel('Amplitude')
title('Time series')

% Fourier domain
subplot(2,1,2) % Fourier domain
plot(ks,abs(fftshift(vt))/max(abs(vt)),'b');
set(gca,'Fontsize',[14])
xlabel('Frequency (Hz)'),ylabel('Normalized FFT Magnitude')
title('Frequency Spectrum')

subtitle('Time and Frequency Plots of Handel''s Messiah')

%% different filters
% domain goes from 0-> t(end) approx 8.9

figure(3)
offset = 4;
% start with gaussian centered at 4
subplot(2,2,1)
spread = 100;
g = exp(-spread*(t-offset).^2);
plot(t,v,'k',t,g,'r','Linewidth',[2])
xlabel('Time [sec]'), ylabel('Amplitude')
title('Gaussian Window')


% super gaussian?
subplot(2,2,2)
spread = 15000;
gs = exp(-spread*(t-offset).^10);
plot(t,v,'k',t,gs,'r','Linewidth',[2])
xlabel('Time [sec]'), ylabel('Amplitude')
title('Super Gaussian Window')

% mexican hat wavelet
subplot(2,2,3)
spread = 0.1;
m = (1-(t-offset).^2).*exp(-((t-offset).^2)/2);
m = (2/((pi^(1/4)).*sqrt(3*spread))).*(1-(((t-offset).^2)/(spread.^2))).*exp(-((t-offset).^2)/(2*(spread.^2)));
plot(t,v,'k',t,m,'r','Linewidth',[2])
xlabel('Time [sec]'), ylabel('Amplitude')
title('Mexican Hat Wavelet Window')

% step function (shannon)
subplot(2,2,4)
width = 2000;
nonZero = ones(width,1);
s = zeros(length(t),1);
s((t+round(offset*Fs)):(t+width+round(offset*Fs))) = 1;
plot(t,v,'k',t,s,'r','Linewidth',[2])
xlabel('Time [sec]'), ylabel('Amplitude')
title('Shannon (Step Function) Window')
subtitle(sprintf('Time Domain Plots of Windowing Functions'))

%%
% slide and filter!
close all;
figure(1)

Spec = [];

% change this here for over and  undersampling

slide = input('oversample, undersample, normalsample   ','s');
switch (slide)
    case 'oversample'
        slideStep = 0.05;
    case 'normalsample'
        slideStep = 0.1;
    case 'undersample'
        slideStep = 1;
end

tslide = 0:slideStep:t(end);
filterChoice = input('Pick your filter! Options are Gaussian, SuperGaussian, Mexican, Shannon    ','s');

% switch (filterChoice)
%     case 'Gaussian'
%         filter = @(j) exp(-20*(t-tslide(j)).^2);
%     case 'SuperGaussian'
%         filter = @(j) exp(-20*(t-tslide(j)).^10);
%     case 'Mexican'
%         filter = @(j) (1-(t-tslide(j)).^2).*exp(-((t-tslide(j)).^2)/2);
%     case 'Shannon'
%         width = 20000;
%         nonZero = ones(width,1);
%         s = zeros(length(t),1);
%         s((t+tslide(j)*Fs):(t+width+tslide(j)*Fs)) = 1;
% end



for j=1:length(tslide)
    
    switch (filterChoice)
        case 'Gaussian'
            % 100 was used for first plots
            % try 1 for too little time resolution
            % 0.1 for REALLY wide
            % too narrow  = 20000
            tau = 100;
            filter = exp(-tau*(t-tslide(j)).^2);
        case 'SuperGaussian'
            tau = 1500000;
            filter =  exp(-tau*(t-tslide(j)).^10);
        case 'Mexican'
            spread = 0.08;
            filter =  (2/((pi^(1/4)).*sqrt(3*spread))).*(1-(((t-tslide(j)).^2)/(spread.^2))).*exp(-((t-tslide(j)).^2)/(2*(spread.^2)));
            %             filter =  (1-((t-tslide(j)).^2)/(spread.^2)).*exp(-(((t-tslide(j)).^2))/(2*(spread.^2)));
            
        case 'Shannon'
            width = 0.1;
            s = zeros(length(t),1);
            s(t>tslide(j) & t<(tslide(j)+width)) = 1;
            filter = s';
    end
    
    subplot(3,1,1)
    plot(t,v,'k',t,filter,'r','Linewidth',[2])
    axis([0 9 -1 1])
    xlabel('Time [sec]'), ylabel('Time Domain Amplitude')
    Sf = filter.*v;
    
    % this here is the frequency content for a given window!
    Sft = fftshift(fft(Sf,n));
    Spec = [Spec; Sft];
    
    subplot(3,1,2)
    plot(t,Sf,'Linewidth',[2])
    xlabel('Time [sec]'), ylabel('Time Domain Amplitude')
    axis([0 9 -1 1])
    
    subplot(3,1,3)
    plot(ks,abs(Sft)/max(abs(Sft)),'Linewidth',[2]),
    xlabel('Frequency [Hz]'), ylabel('Normalized FFT Magnitude')
    
    subtitle('Short Time Fourier Transform of Signal')
    drawnow
    
end

% spectrogram plot
figure(2)
pcolor(tslide,ks,abs(Spec).'), shading interp
colormap('parula')
h = colorbar;
ylabel(h,'Magnitude of FFT')
xlabel('Time [sec]'), ylabel('Frequency [Hz]')
title('Spectrogram of Handel''s Messiah')
set(gca,'Fontsize',[14])
ylim([0 max(ks)])
%% spectogram to compare 4 in one subplot

close all;
figure(1)

% change this here for over and  undersampling

slide = input('oversample, undersample, normalsample   ','s');
switch (slide)
    case 'oversample'
        slideStep = 0.05;
    case 'normalsample'
        slideStep = 0.1;
    case 'undersample'
        slideStep = 1;
end

tslide = 0:slideStep:t(end);
Spec = [];

for i = 1:4
    Spec = [];
    filterChoice = input('Pick your filter! Options are Gaussian, SuperGaussian, Mexican, Shannon    ','s');
    
    for j=1:length(tslide)
        
        switch (filterChoice)
            case 'Gaussian'
   
                tau = 1000;
                filter = exp(-tau*(t-tslide(j)).^2);
            case 'SuperGaussian'
                tau = 1500000;
                filter =  exp(-tau*(t-tslide(j)).^10);
            case 'Mexican'
                spread = 0.01;
                filter =  (2/((pi^(1/4)).*sqrt(3*spread))).*(1-(((t-tslide(j)).^2)/(spread.^2))).*exp(-((t-tslide(j)).^2)/(2*(spread.^2)));
                %             filter =  (1-((t-tslide(j)).^2)/(spread.^2)).*exp(-(((t-tslide(j)).^2))/(2*(spread.^2)));
                
            case 'Shannon'
                width = 0.1;
                s = zeros(length(t),1);
                s(t>tslide(j) & t<(tslide(j)+width)) = 1;
                filter = s';
        end
        
        Sf = filter.*v;
        % this here is the frequency content for a given window!
        Sft = fftshift(fft(Sf,n));
        Spec = [Spec; Sft];
        
        
    end
    
    subplot(2,2,i)
    pcolor(tslide,ks,abs(Spec).'), shading interp
    colormap('parula')
    colorbar
    h = colorbar;
    if i == 1
        xlabel('Time [sec]')
        ylabel('Frequency [Hz]')
        ylabel(h,'Magnitude of FFT')
    end
    ylim([0 2000])
    set(gca,'Fontsize',[14])
    title(sprintf('%s Window',filterChoice));
end



subtitle(sprintf('Spectograms of Different Window Functions'));



%% PART 2

%% piano

close all;clear all;clc

source = input('piano or recorder?   ','s');

switch (source)
    case 'piano'
        tr_piano = 16; % record time in seconds
        y = wavread('music1'); Fs = length(y)/tr_piano;
        plot((1:length(y))/Fs,y);
        xlabel('Time [sec]'); ylabel('Amplitude');
        title('mary had a little lamb (piano)'); drawnow
        %                 p8 = audioplayer(y,Fs); playblocking(p8);
    case 'recorder'
        figure(2)
        tr_rec=14; % record time in seconds
        y = wavread('music2'); Fs = length(y)/tr_rec;
        plot((1:length(y))/Fs,y);
        xlabel('Time [sec]'); ylabel('Amplitude');
        title('Mary had a little lamb (recorder)');
        %                 p8 = audioplayer(y,Fs); playblocking(p8);
end


t = ((1:length(y))/Fs);
% fs is 8192, which is 2^13, start using double this as the number of points for
% the FFT to go from -Fs to +Fs
npow2 = nextpow2(length(y));
n = 2^npow2;

L = t(end);
% scale wavenumbers by Fs/n
k = (Fs/n)*[0:(n/2)-1 -n/2:-1];
ks = fftshift(k);

yt = fft(y,n);

figure(1)

% time domain
subplot(2,1,1)
plot(t,y,'b')
set(gca,'Fontsize',[14]),
ylim([-0.5 0.5])
xlabel('Time [sec]'), ylabel('y(t)')
title('Time Domain')

% Fourier domain
subplot(2,1,2) % Fourier domain
plot(ks,abs(fftshift(yt))/max(abs(yt)),'b');
set(gca,'Fontsize',[14])
xlabel('Frequency (Hz)'),ylabel('FFT(y)')
title('Frequency Domain')

switch (source)
    case 'piano'
        subtitle('Piano Recording')
    case 'recorder'
        subtitle('Recorder Recording')
end


% looks really over sampled, downsample?
% try downsampling by a factor of 20 for piano
% recorder seems to have more overtones than piano, but for first pass, try
% downsampling by factor of 20
% use matlab decimate function to use low pass filter to avoid aliasing

downSampleFac = 10;

yD = decimate(y,downSampleFac);
FsNew = Fs/downSampleFac;
tNew = ((1:length(yD))/FsNew);

npow2 = nextpow2(length(y));
n = 2^npow2;

yt = fft(y,n);

ytD = fft(yD,n);


L = t(end);
% scale wavenumbers by Fs/n
k = (FsNew/n)*[0:(n/2)-1 -n/2:-1];
ks = fftshift(k);


figure(2)
% time domain
subplot(2,1,1)
plot(tNew,yD,'r')
set(gca,'Fontsize',[14]),
xlabel('Time [sec]'), ylabel('yD(t)')
title('Time Domain')
ylim([-0.5 0.5])


% Fourier domain
subplot(2,1,2) % Fourier domain
plot(ks,abs(fftshift(ytD))/max(abs(ytD)),'r');
set(gca,'Fontsize',[14])
xlabel('Frequency (Hz)'),ylabel('FFT(yD)')
title('Frequency Domain')

switch (source)
    case 'piano'
        subtitle('Downsampled Piano Recording')
    case 'recorder'
        subtitle('Downsampled Recorder Recording')
end



%%
% slide and filter!

t = tNew;
y = yD;
Fs = FsNew;

% change the FFT to be over the window that we are sliding

npow2 = nextpow2(length(y));
n = 2^npow2;

L = t(end);
% scale wavenumbers by Fs/n
k = (Fs/n)*[0:(n/2)-1 -n/2:-1];
ks = fftshift(k);

close all;
figure(1)

Spec = [];
maxVec = [];
tslide = 0:0.1:t(end);
filterChoice = input('Pick your filter! Options are Gaussian, SuperGaussian, Mexican, Shannon  ','s');


for j=1:length(tslide)
    
    switch (filterChoice)
        case 'Gaussian'
            % started with tau 15
            tau = 40;
            filter = exp(-tau*(t-tslide(j)).^2);
    end
    
    subplot(3,1,1)
    plot(t,y,'k',tNew,filter,'r','Linewidth',[2])
    axis([0 16 -1 1])
    Sf = filter.*y';
    
    
    subplot(3,1,2)
    plot(t,Sf,'Linewidth',[2])
    axis([0 16 -1 1])
    
    % this here is the frequency content for a given window!
    Sft = fftshift(fft(Sf,n));
    
    % filter the Sft around point of maximum peak 
    SftTemp = Sft';
    SftTemp(1:(length(Sft)/2)) = 0;
    [maxVal,maxInd] = max((abs(SftTemp)));
%     
    %0.001 works 
    filterFreq = exp(-0.05*(ks-ks(maxInd)).^2);
    plot(ks,filterFreq)
    SftFilt = Sft.*filterFreq;
    Spec = [Spec; SftFilt];
    maxVec = [maxVec; maxVal];
    
    subplot(3,1,3)
    plot(ks,abs(SftFilt)/max(abs(SftFilt)),'Linewidth',[2]),
    axis([-ks(end) ks(end) 0 1])
    
    drawnow
end

% spectrogram plot
figure(2)
pcolor(tslide,ks,abs(Spec).'), shading interp
colormap('parula')
h = colorbar;
ylabel(h,'Magnitude of FFT')
title(['Spectogram of ',source])
xlabel('Time (seconds)')
ylabel('Frequency (Hz)')
set(gca,'Fontsize',[14])

switch (source)
    case 'piano'
        ylim([0 400])
    case 'recorder'
        ylim([700 1100])
end
    
%%

%Recorder spectrogram intensity
% 1029, 918 , 817, 918, 1029, 1029, 1029, 918 918 918 1029 1029 1029 1029
% 918 817 918 1029 1029 1029 1029 918 918 1029 918 816 816

% G - 783.99
% Aflat - 830.1
% A - 880.000
% B - 987.77
% C - 1046.5
% D - 1174

% B A G




%Piano
%  320 285 255

% E - 329.63
% D - 293.66
% C - 261.63

%% to check if frequencies calculated match pure tones made by MATLAB
% inspired by the post at http://www.mathworks.com/matlabcentral/newsreader/view_thread/136160

% Choose a sampling rate fs, e.g. 8000 Hz. (You'll need a higher rate if
% you want sounds above 4000 Hz).
fs = 8000;

% Generate time values from 0 to T seconds at the desired rate.
T = 1; % 2 seconds duration
t = 0:(1/fs):T;

% Generate a sine wave of the desired frequency f at those times.
f = 300;
a = 0.5;
y = a*sin(2*pi*f*t);
sound(y, fs);

% recorder hot cross buns
recorder = [987.77 880 783.99 880 987.77 987.77 987.77 987.77 987.77 880 783.99 880 987.77 987.77 987.77 987.77 880 880 987.77 880 783];
for i = 1:length(recorder)
    
    f = recorder(i);
    a = 0.5;
    y = a*sin(2*pi*f*t);
    sound(y, fs);
    pause(1)
end

% piano hot cross buns
piano = [329.63 293.66 261.63 293.66 329.63 329.63 329.63 293.66 293.66 293.66 329.63 329.63 329.63 329.63 293.66 261.63 293.66 329.63 329.63 329.63 329.63 293.66 293.66 329.63 293.66 261.63];

for i = 1:length(piano)
    
    f = piano(i);
    a = 0.5;
    y = a*sin(2*pi*f*t);
    sound(y, fs);
    pause(1)
end