%% 7/4/2016 - spectral analysis script DJC


%% This is to plot the time series and do the FFT of Pre and Post

% add in sid - 7-13-2016
sid = '3f2113';

% define stimulation channels 
stimChan1 = stim_chans(1);
stimChan2= stim_chans(2);

% example channel for stims 28_29, 21.
% set IDX to be whatever we want to look at channel wise. Can extend to
% whole matrix/data set later

% channel of interest
idx = input('whats your channel of interest?');

% filter it
filter_it = input('notch filter? input "yes" or "no"','s');


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
if strcmp(filter_it,'yes')
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

if strcmp(filter_it,'yes')
    sig_post = notch(sig(t>post_begin & t<post_end),[60 120 180 240],fs_data);
else
    sig_post = sig(t>post_begin & t<post_end);
    
end

[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);


% get high signal

sig = mean(dataEpochedHigh(:,idx,:),3);

if strcmp(filter_it,'yes')
    sig_post = notch(sig(t>post_begin & t<post_end),[60 120 180 240],fs_data);
else
    sig_post = sig(t>post_begin & t<post_end);
    
end

[f_post,P1_post] = spectralAnalysis(fs_data,t_post,sig_post);



%% do them one at a time vs their own pre

% change this to be dataEpochedLow, Mid, Or High if desired - set legend
% accordingly
sigL = squeeze(dataEpochedHigh(:,idx,:));

for i = 1:size(sigL,2)
    
    if strcmp(filter_it,'yes')
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
    
    if strcmp(filter_it,'yes')
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
    if strcmp(filter_it,'yes')
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
% requires functions matrixDist.m and channelExtract.m
% also a fake trodes file for now 

if (strcmp(sid,'3f2113'))
    load('fakeTrodes.mat');
    locs = matrixSorted(:,(2:end));
else
end


[stim1_dist,stim2_dist] = distanceAnalysis(locs,stimChan1,stimChan2);


%% This is to stack the data so we can do SVD and DMD
% start with dataEpochedHigh

goodChans = [1:72];
dataStackedGood = dataStack(dataEpochedHigh,t,post_begin,post_end,goodChans,stimChan1,stimChan2,[],fs_data);

%% This is doing a SVD of our data matrix
% looks at the first 3 modes in space, time

% input stim channels
[u,s,v] = SVDanalysis(dataStackedGood,stim_chans);

% BELOW THIS IS CURRENTLY NOT FUN



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
