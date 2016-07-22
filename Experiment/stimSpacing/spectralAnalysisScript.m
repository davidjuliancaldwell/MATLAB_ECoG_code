%% 7/4/2016 - spectral analysis script DJC
%This is to plot the time series and do the FFT of Pre and Post

%% load a data file

% clear workspace
close all; clear all; clc
% to add paths to all the subfolders
addpath(genpath(pwd))

% load in the datafile of interest!
% have to have a value assigned to the file to have it wait to finish
% loading...mathworks bug
%uiimport('-file');

%SPECIFIC ONLY TO DJC DESKTOP RIGHT NOW
%load('C:\Users\djcald\Google Drive\GRIDLabDavidShared\StimulationSpacing\1sBefore1safter\stim_12_52.mat')

%SPECIFIC ONLY TO JAC DESKTOP RIGHT NOW
load('C:\Users\jcronin\Data\Subjects\3f2113\data\d6\Matlab\StimulationSpacing\1sBefore1safter\stim_constantV26_31.mat')

%%
% add in sid - 7-13-2016
sid = '3f2113';

% define stimulation channels
stimChan1 = stim_chans(1);
stimChan2= stim_chans(2);


% ui box for input
prompt = {'whats your channel of interest?','notch filter? input "y" or "n"'};
dlg_title = 'Input';
num_lines = 1;
defaultans = {'60','y'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
idx = str2num(answer{1});
filter_it = answer{2};



% pre time window
pre_begin = -450;
pre_end = 0;
% post time window
post_begin = 5;
post_end = (450+post_begin);


% extract pre
t_pre = t(t<pre_end & t>pre_begin);

% extract post
t_post = t(t>post_begin & t<post_end);

%%
% get the low signal
sig = mean(dataEpochedLow(:,idx,:),3);
sigPre = mean(dataEpoched(:,idx,:),3);


% filter it?
if strcmp(filter_it,'y')
    sig_pre = notch(sigPre(t<pre_end & t>pre_begin),[60 120 180 240],fs_data);
    sig_post = notch(sig(t>post_begin & t<post_end),[60 120 180 240],fs_data);
else
    sig_pre = sigPre(t>pre_begin & t<pre_end );
    sig_post = sig(t>post_begin & t<post_end);
    
end
figure

% plot pre
% plotting/etc is in spectralAnalysis function
[f_pre,P1_pre] = spectralAnalysis(fs_data,t_pre,sig_pre);


% and post
[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);

% get middle signal
sig = mean(dataEpochedMid(:,idx,:),3);

if strcmp(filter_it,'y')
    sig_post = notch(sig(t>post_begin & t<post_end),[60 120 180 240],fs_data);
else
    sig_post = sig(t>post_begin & t<post_end);
    
end

[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);


% get high signal

sig = mean(dataEpochedHigh(:,idx,:),3);

if strcmp(filter_it,'y')
    sig_post = notch(sig(t>post_begin & t<post_end),[60 120 180 240],fs_data);
else
    sig_post = sig(t>post_begin & t<post_end);
    
end

[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);

%% 7-19-2016 - look at zscore to threshold CCEps
% use function zscoreStimSpacing.m

% this is for internal calls to the peak finder for zscoring 
plotIt = false;

% ui box for input - pick zscore threshold 
prompt = {'whats the zscore threshold? e.g. 15'};
dlg_title = 'zthresh';
num_lines = 1;
defaultans = {'10'};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
zThresh = str2num(answer{1});


% get the data

zMat = {};
magMat = {};
latencyMat = {};

for idx = 1:size(dataEpochedHigh,2)
    
    sig = mean(dataEpochedHigh(:,idx,:),3);
    
    if strcmp(filter_it,'y')
        
        sig_pre = notch(sig(t<pre_end & t>pre_begin),[60 120 180 240],fs_data);
        sig_post = notch(sig(t>post_begin & t<post_end),[60 120 180 240],fs_data);
    else
        sig_pre = sig(t>pre_begin & t<pre_end );
        sig_post = sig(t>post_begin & t<post_end);
    end
    
    %[z_ave,mag_ave,latency_ave,w_ave,p_ave,zI,magI,latencyI,wI,pI] = zscoreStimSpacing(dataEpochedHigh,dataEpochedHigh,t,pre_begin,pre_end,...
    %post_begin,post_end,plotIt);
    
    [z_ave,mag_ave,latency_ave,w_ave,p_ave] = zscoreStimSpacing(sig_pre,sig_post,t,pre_begin,pre_end,...
        post_begin,post_end,plotIt);
    
    zMat{idx} = z_ave;
    magMat{idx} = mag_ave;
    latencyMat{idx} = latency_ave;
    
end

% plot it
figure

% colorbrewer

% color map
CT = cbrewer('seq','YlOrRd',9);

% flip it so red is increase, blue is down
%CT = flipud(CT);


zConverted = cell2mat(zMat);
zShape = reshape(zConverted(1:64),[8 8]);
imagesc(transpose(reshape(zShape,[8 8])));

axis off

colormap(CT);
colorbar;
caxis([0 max(zShape(:))])

title('z-score of CCEP peaks - average signal, relative to pre')
textStrings = num2str([1:length(zShape(:))]');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:8);   %# Create x and y coordinates for the strings

x = x';
y= y';
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
    'HorizontalAlignment','center');
colorbar
colorBar.Label.String = 'Zscore value relative to baseline';


% plot significant CCEPs

sigCCEPs = find(zConverted>zThresh);

sig = dataEpochedHigh;
plotSignificantCCEPsMap(sig,t,stim_chans,sigCCEPs, 'yes');


%% do them one at a time vs their own pre

% change this to be dataEpochedLow, Mid, Or High if desired - set legend
% accordingly
sigL = squeeze(dataEpochedHigh(:,idx,:));

for i = 1:size(sigL,2)
    
    if strcmp(filter_it,'y')
        sig_pre = notch(sigL((t<pre_end & t>pre_begin),i),[60 120 180 240],fs_data);
        sig_postL = notch(sigL((t>post_begin & t<post_end),i),[60 120 180 240],fs_data);
    else
        
        sig_pre = sigL((t<pre_end & t>pre_begin),i);
        sig_postL = (sigL((t>post_begin & t<post_end),i));
        
    end
    
    figure
    [f_pre,P1_pre] = spectralAnalysis(fs_data,t_pre,sig_pre);
    [f_postL,P1_postL] = spectralAnalysis(fs_data,t_post,sig_postL);
    
    legend({'pre','high'})
    % do some time frequency analysis
    figure
    timeFrequencyAnalWavelet(sig_pre,sig_postL,t_pre,t_post,fs_data)
    
    
    
end


%% do them one at a time, pre, low, middle, high (PRE BASELINE IS THE ONE PLOTTED)
% they would all have to be the same length

sigH = squeeze(dataEpochedHigh(:,idx,:));
sigM = squeeze(dataEpochedMid(:,idx,:));
sigL = squeeze(dataEpochedLow(:,idx,:));

for i = 1:size(sigH,2)
    
    if strcmp(filter_it,'y')
        sig_pre = notch(sigL((t<pre_end & t>pre_begin),i),[60 120 180 240],fs_data);
        sig_postL = notch(sigL((t>post_begin & t<post_end),i),[60 120 180 240],fs_data);
        sig_postM = notch(sigM((t>post_begin & t<post_end),i),[60 120 180 240],fs_data);
        sig_postH = notch(sigH((t>post_begin & t<post_end),i),[60 120 180 240],fs_data);
    else
        sig_pre = sigL((t<pre_end & t>pre_begin),i);
        sig_postL = (sigL((t>post_begin & t<post_end),i));
        sig_postM = (sigM((t>post_begin & t<post_end),i));
        sig_postH = (sigH((t>post_begin & t<post_end),i));
    end
    
    figure
    [f_pre,P1_pre] = spectralAnalysis(fs_data,t_pre,sig_pre);
    [f_postL,P1_postL] = spectralAnalysis(fs_data,t_post,sig_postL);
    [f_postM,P1_postM] = spectralAnalysis(fs_data,t_post,sig_postM);
    [f_postH,P1_postH] = spectralAnalysis(fs_data,t_post,sig_postH);
    
    
end


%% Plot all 10 stim pulses for the given trial
% change this to be dataEpochedLow, Mid, Or High if desired - set legend
% accordingly
sigL = squeeze(dataEpochedHigh(:,idx,:));
labels = cell(1, size(sigL,2));
figure
gcolor=1.0; % this is to control the color of the line
colorIncrement=0.1;
for i = 1:size(sigL,2)
    if strcmp(filter_it,'y')
        sig_pre = notch(sigL((t<pre_end & t>pre_begin),i),[60 120 180 240],fs_data);
        sig_postL = notch(sigL((t>post_begin & t<post_end),i),[60 120 180 240],fs_data);
    else
        sig_pre = sigL((t<pre_end & t>pre_begin),i);
        sig_postL = (sigL((t>post_begin & t<post_end),i));
    end
    [f,P1] = spectralAnalysisComp(fs_data,sig_postL);
    
    plot((f),(P1),'Color', [0.0 gcolor 1.0],'linewidth',2)
    hold on
    %
    %     [f,P1] = spectralAnalysisComp(fs_data,sig_pre);
    %     plot((f),(P1),'linewidth',[2])
    labels{i}=['high ', num2str(i)];
    gcolor=gcolor-colorIncrement;
end
title('Single-Sided Amplitude Spectrum of X(t) all pulses in trial')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0 100])
ylim([0 2e-5])
set(gca,'fontsize',14)
legend(labels)

%% DJC - 7-13-2016 Added in distance


if (strcmp(sid,'3f2113'))
    load('trodes.mat');
    locs = Grid;
else
end

% - fakeTrodes.mat is deprecated now that Nile has put up the real trodes
% file!

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% requires functions matrixDist.m and channelExtract.m
% also a fake trodes file for now

% if (strcmp(sid,'3f2113'))
%     load('fakeTrodes.mat');
%     locs = matrixSorted(:,(2:end));
% else
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[stim1_dist,stim2_dist] = distanceAnalysis(locs,stimChan1,stimChan2);


%% This is to stack the data so we can do SVD and DMD
% start with dataEpochedHigh

prompt = {'what is the list of channels to stack ? e.g. 1:8,12 '};
dlg_title = 'StackChans';
num_lines = 1;
defaultans = {'1:64'};
answerChans = inputdlg(prompt,dlg_title,num_lines,defaultans);
chansToStack = str2num(answerChans{1});

%dataStackedGood = dataStack(dataEpochedHigh,t,post_begin,post_end,goodChans,stimChan1,stimChan2,[],fs_data,filter_it);
dataStackedGood = dataStack(dataEpochedHigh,t,post_begin,post_end,chansToStack,[],[],[],fs_data,filter_it);

%% This is doing a SVD of our data matrix
% looks at the first 3 modes in space, time

% sigCCEPs only?
prompt = {'SVD with only the sigCCEPs? (y or n) '};
dlg_title = 'sigCCEPs?';
num_lines = 1;
defaultans = {'n'};
answerChans = inputdlg(prompt,dlg_title,num_lines,defaultans);
use_sigCCEPs = answerChans{1};

defaultGood = 1:64;

if strcmp(use_sigCCEPs,'y')
    temp = zeros(size(defaultGood));
    temp(sigCCEPs(~(sigCCEPs>64))) = 1;
    goodChans = defaultGood(logical(temp));
else
    % bad channels
    prompt = {'what is the list of channels to IGNORE? e.g. 1:8,12 '};
    dlg_title = 'BadChannels';
    num_lines = 1;
    defaultans = {num2str(stim_chans)};
    answerChans = inputdlg(prompt,dlg_title,num_lines,defaultans);
    badChans = str2num(answerChans{1});
    
    prompt = {'what is the list of channels to USE? e.g. 1:8,12 '};
    dlg_title = 'GoodChannels';
    num_lines = 1;
    temp = ones(size(defaultGood));
    temp(stim_chans) = 0;
    temp(badChans) = 0;
    defaultans = {num2str(defaultGood(logical(temp)))}; % everything but the stim channels
    answerChans = inputdlg(prompt,dlg_title,num_lines,defaultans);
    goodChans = defaultGood(logical(temp));
end



% if we want to plot it spatially, we need to use at least the 64 channels
% in the grid!

% etither give it SVDanalysis(.....,[],goodChans);
%or SVDanalysis(.......,badChans,[]);

fullData = true;
%[u,s,v] = SVDanalysis(dataStackedGood,stim_chans,fullData,badChans,[]);
modes = 1:3;
[u,s,v, dataSVD, goods] = SVDanalysis(dataStackedGood,stim_chans,fullData,[],goodChans, modes);

%% If you want to plot some other modes
modes = [2:4];
SVDplot(u,s,v, fullData, goods, modes);

%% parametric plot (mode 1 vs. mode 2 vs. mode 3)
% use the v values from the SVDanalysis function from above
prompt = {'plot first cycle of modes, or all of time? "1st" or "all" '};
dlg_title = 'BadChannels';
num_lines = 1;
defaultans = {'1st'};
answerChans = inputdlg(prompt,dlg_title,num_lines,defaultans);
cycles = answerChans{1};

parametricPlotSVD(v,post_begin,post_end,fs_data,cycles)


%% Reconstruction with the first few dominant modes (columns of U) 
% First project the svd'd data onto the modes
modes=1:3;
dataR=u(:,modes)*s(modes, modes)*v(:,modes)';

% Add rows back in for the stim channels, so that we have 64 channels total
dataR_withStim = zeros(64, size(dataR,2));
temp = zeros(64,1);
temp(goodChans) = 1;
dataR_withStim(logical(temp),:) = dataR;

% Now I see two ways of plotting this projected data:
% 1) Get back to a matrix with epochs and average (in
% plotSignificantCCEPsMap function), or
% 2) just plot the entire data_proj rows which should show some
% periodicity since the original data was stacked which yields the peaks at
% every epoch start.

% Method 1:
% Get back to a matrix with epochs (like dataEpochedHigh)
% Since we stacked 10 stim pulses of equal size
L = size(dataR,2)/10;

% Want:  time(which should be L)*channels*epochs
sig = reshape(dataR_withStim, [64, L, 10]);
sig = permute(sig, [2 1 3]);

plotSignificantCCEPsMap(sig,t_post,stim_chans,sigCCEPs, 'no');

% Method 2:
% Don't reshape, want: time*channels
plotSignificantCCEPsMap(dataR_withStim',(0:size(dataR_withStim,2)-1)/fs_data*1000,stim_chans,sigCCEPs, 'no');

%% Again plot reconstructions onto first first few dominant modes
% but, rather than averaging all of the epochs, just plot an epoch of
% interest
epoch = 1;
plotSignificantCCEPsMap(sig(:,:,epoch), t_post,stim_chans,sigCCEPs, 'no');

%% Compute projection of each data matrix (response after a single stim pulse)
% onto the dominant modes
% Change time to use the stacked or unstacked data
modes=[1:3];
% channels = [1:length(goodChans)]; % max of 62, since this doens't include the stim channels
channels = 2;
% time = 1:size(A_proj,2); % All stims/epochs
epoch = 2;

A_proj = zeros(size(dataSVD, 1), size(dataSVD, 2), 3);
time = (epoch-1)*size(A_proj,2)/10+1:epoch*size(A_proj,2)/10; % Just a single epoch

for i=modes
    A_proj(:,:,i)=u(:,i)*s(i,i)*v(:,i)';
end

figure
plot3(A_proj(channels,time,1), A_proj(channels,time,2), A_proj(channels,time,3))
title('Data projected onto some dominant modes of U');
xlabel(['Mode ', num2str(modes(1))]);
ylabel(['Mode ', num2str(modes(2))]);
zlabel(['Mode ', num2str(modes(3))]);

%% Again, projections of each data matrix, but plot each channel separately on grid

% Add in the stim channels 
sig = zeros(64, size(dataR,2),3);
temp = zeros(64,1);
temp(goodChans) = 1;
sig(logical(temp),:,:) = A_proj;

% sig in 3D: time*channels*epochs
sig = permute(sig, [2, 1, 3]);

plotSignificantCCEPsMap(sig, (0:size(dataR_withStim,2)-1)/fs_data*1000, stim_chans,sigCCEPs, 'plot3');
%% Local SVD... NOT DONE!!!!!!!!!!!!!!!!!!!!!!!!!!
% So what we already did u, v, and s are the global modes
% Now calculate some 'local' modes
epoch=1; % choose epoch number
sig = reshape(dataSVD, [62, L, 10]);
[uL,sL,vL] = svd(sig(:,:,epoch), 'econ');

% for i=2:4
%     a(i) = u(:,i).'*uL(:,i); % this is what Nathan wrote, but it's just a
%     % scalar
% end

% for a projection...
for i=2:4
    a(:,:,i) = u(:,i)*uL(:,i)'; 
end

figure
plot3(a(:,:,1), a(:,:,2), a(:,:,3))



%% BELOW THIS IS CURRENTLY NOT FUN

%% dmd - this is trying to do DMD - I don't think there's much useful from here until we talk to them
Xraw = dataStackedGood';
dt = 1/fs_data;


% added in dt optional argument, dt is our sampling frequency
% added in number of stacks. Using 5 for right now. The paper talks about
% hn > 2m, where h is the stack number, n is the number of channels, and m
% is time snapshots

% r sets rank truncation
[Phi, mu, lambda, diagS, x0] = DMD(Xraw,'dt',dt,'nstacks',50);

% look at modes from SVD augmented data matrix
% look at diagonal of matrix S - singular values

figure
plot(diagS(1:5),'ko','Linewidth',[2])

% to get percentage in mode
subplot(2,1,1) % plot normal
plot(diagS(1:5)/sum(diagS(1:5)),'ko','Linewidth',[2])
title('singular values, fractions')
set(gca,'fontsize',14)

subplot(2,1,2) % plot semilog
semilogy(diagS(1:5)/sum(diagS(1:5)),'ko','Linewidth',[2])
title('singular values, fractions, semilog plot')
set(gca,'fontsize',14)

%% more DMD reconstruction - similarly, not of much utility yet.

t = length(Xraw');

% M is number of points to reconstrunct
M = t;

% add in time delay of 10 ms for plotting correctly
t2 = [1:M]/fs_data;

[Xhat z0] = DMD_recon(Phi, lambda, x0, M);

figure
x = [1:min(size(Xraw))];

% only plot 1:numChans of Xhat, there rest are redundant?
XhatUnique = Xhat([1:min(size(Xraw))],:);
surf(x,t2,1e6*real(XhatUnique).'), shading interp, colormap('parula')
title({'Reconstruction and Projection of Signal' 'with Dynamic Mode Decomposition'})
set(gca,'Fontsize',[14])
xlabel('Channel')
ylabel('Time s')
zlabel('Magnitude (\muV)');
%ylim(1e3*[0.01 max(t2)])


% optional argument plotit, either a 0 or a 1 , 1 plots the spectrum
[f P] = DMD_spectrum(Phi, mu, 'plotit',[1]);
set(gca,'fontsize',[14])
title('DMD Spectrum')

[f P] = DMD_spectrum(Phi, mu, 'plotit',[1]);
set(gca,'fontsize',[14])
title({'DMD Spectrum','Limited Frequency range'})
xlim([0 200])
% add in polarplot

if exist('polarplot')
    figure
    polarplot(mu,'*');
    title('Polar plot of \omega values from DMD')
    set(gca,'fontsize',[14])
end
