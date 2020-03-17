close all; clear all; clc

for ii = 1:3
    fs = 12000;
    dur = 2.5;
    freq = 60*ii;
    amp = 1;
    phase = 0;
    t = linspace(0,dur-1/fs,dur*fs);
    phase = 0;
    sig(:,ii) = amp * sin(2 * pi * freq .* t + phase);
end

timeRes = 0.01; % ms
[powerout,f,t] = analyFunc.morletprocess(sig, fs, timeRes);

totalFig = figure;
totalFig.Units = 'inches';
totalFig.Position = [1 1 4 6];
for ii = 1:3
    subplot(1,3,ii)
    s = surf(1e3*t,f,powerout(:,:,ii),'edgecolor','none');
    view(0,90);
    
end