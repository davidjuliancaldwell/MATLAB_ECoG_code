%%  12-4-2015 DJC - attempt to use coherent modulation to look at amHG
% starting using fca96e data from Kaitlyn
% using modulation toolbox from les atlas

%% load in data - start with

load('D:\BigDataFiles\amHG_example.mat');

banded = bandpass(trimmed_sig,70,200,fs);

banded5 = banded(:,5);

modspectrum(banded5,fs,'cog',20)

% HG power via MIah's old quickscreen, Kaitlyn says not log
HGpower = (hilbAmp(trimmed_sig, [70 200], fs).^2);

yCOG5 = modfilter(HGPower(:,5),fs,[0.1 1], 'pass','cog',20);

%% plot ifs vs. yCOG5

figure
subplot(2,1,1)
plot(ifsHG(:,5))
xlim([0 5e4])
title('ifsHG')
subplot(2,1,2)
plot(yCOG5)
title('Coherent Demodulation')
xlim([0 5e4])

%% plot all the channels

load('D:\BigDataFiles\amHG_example.mat');
HGpower = (hilbAmp(trimmed_sig, [70 200], fs).^2);
numPlots = size(HGpower,2);

yCOG = zeros(size(HGpower,1),size(HGpower,2));
for i = 1:numPlots
    yCOG(:,i) = modfilter(HGPower(:,i),fs,[0.1 1], 'pass','cog',20)'  ;
end

%% plot modulating filtered
figure

p = numSubplots(numPlots);


for i = 1:numPlots
    subplot(p(1),p(2),i)
    plot(yCOG(1:3e5,i));
end

%% plot Kaitlyn ifsHG 

figure

p = numSubplots(numPlots);

for i = 1:numPlots
    subplot(p(1),p(2),i)
    plot(ifsHG(1:3e5,i));
end