%% 9-21-2015 - this is a script to calculate the phase slope index based off of Nolte 2008 "Robustly estimating the flow direction of information in complex physical systems. Physical Review Letters
% uses data2psi.m file from that paper 

%% pre stim

load('D:\BigDataFiles\ecb43e_PAC_prestim.mat')

preStim = data;

%% calculate phase slope index 

seglength = input('How long do you want the window to be? (in seconds) ');
seglength = seglength*fs; % start off with segment length of approximately 1 second
freqbins = [12 25]; % start off looking at beta band of frequencies 

freqbins = input('Which frequency band would you like to look at? (beta, gamma, etc) ','s');
switch freqbins
    case 'beta'
        freqbins = [12 25];
    case 'gamma'
        freqbins = [70 200];
end

[psi,stdpsi,psisum,stdpsium] = data2psi(preStim,seglength,[],freqbins);

psiPre = psi;

% % flip sign below diagonal 
% lowerMask = tril(ones(size(psiPre(1),size(psiPre(1)))),-1);
chansInt = [48,39,47,55,63,62,54,46]; % channels of interest around beta recording electrode 

psiPre55 = psiPre(55,:);

psiPre56 = psiPre(56,:);
psiPre64 = psiPre(64,:);

%% post stim
load('D:\BigDataFiles\ecb43e_PAC_poststim.mat')

postStim = data;

%% calculate phase slope index 

seglength = input('How long do you want the window to be? (in seconds) ');
seglength = seglength*fs; % start off with segment length of approximately 1 second
freqbins = [12 25]; % start off looking at beta band of frequencies 

freqbins = input('Which frequency band would you like to look at? (beta, gamma, etc) ','s');
switch freqbins
    case 'beta'
        freqbins = [12 25];
    case 'gamma'
        freqbins = [70 200];
end

[psi,stdpsi,psisum,stdpsium] = data2psi(postStim,seglength,[],freqbins);

psiPost = psi; 

chansInt = [48,39,47,55,63,62,54,46];
psiPost55 = psiPost(55,:);
psiPost56 = psiPost(56,:);
psiPost64 = psiPost(64,:);

%% Plot bar graphs

figure

subplot(2,3,1)
bar(psiPre55)
title('PSI Pre Chan 55')

subplot(2,3,2)
bar(psiPre56)
title('PSI Pre Chan 56')

subplot(2,3,3)
bar(psiPre64)
title('PSI Pre Chan 64')

subplot(2,3,4)
bar(psiPost55)
title('PSI Post Chan 55')

subplot(2,3,5)
bar(psiPost56)
title('PSI Post Chan 56')

subplot(2,3,6)
bar(psiPost64)
title('PSI Post Chan 64')




