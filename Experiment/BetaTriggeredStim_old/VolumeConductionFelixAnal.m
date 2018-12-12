%% 9-17-2015 - DJC - This script is an attempt to characterize the issues of phase coherence and volume conduction for the beta triggered stimulation work

%% Constants
Z_ConstantsKurtConnectivity;
addpath ./experiment/BetaTriggeredStim/scripts/ %DJC edit 8/14/2015

%%
sid = input('enter subject ID ','s');

%9ab7ab
switch(sid)
    case '9ab7ab'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim';
        block = 'BetaPhase-3';
        stimChans = [59 60];
        chans = [1:64]; % want to look at all channels, DJC 8-28-2015
        
        % chans = [51 52 53 58 57]; % DJC 8-31-2015, look at channels that were deemed potentially interesting before by Miah/Jared to see if I can see anything
        % chans(ismember(chans, stims)) = []; want to look at stim channels too!
        %%
        %'ecb43e'
    case 'ecb43e'
        tp = 'C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim';
        block = 'BetaPhase-3';
        stimChans = [56 64];
        chans = [1:64];
        %         chans = [47 55]; want to look at all channels
        
end

%% load in the data from Kurt files

switch(sid)
    case 'ecb43e'
        % want to look at the Mu signal characterized around the
        load('c:\users\david\desktop\Research\RaoLab\MATLAB\Code\Output\KurtConnectivity\meta\ecb43e_Stats.mat')
    case '9ab7ab'
        load('c:\users\david\desktop\Research\RaoLab\MATLAB\Code\Output\KurtConnectivity\meta\9ab7ab_Stats.mat')
        
end
fs = 2.441406250000000e+04;
efs = 1.220703125000000e+04;

presamps = round(0.2 * efs); % pre time in sec
postsamps = round(0.2 * efs); % post time in sec

t = (-presamps:postsamps)/efs;

sigs = cell2mat(muCell);
stdError = cell2mat(stdErrCell);
%% Below is for 20 ms before until end of stimulus 10-23-2015
% look at 20 ms before stimuli until end of signal, so
% presamps+1+round(10*efs/1000)

sigsTrim = sigs((presamps-round(0.02*efs)):end,:);
stdErrorTrim = stdError((presamps-round(0.02*efs)):end,:);

tTemp = t';
tTrim = tTemp((presamps-round(0.02*efs)):end,:);
tTrim = tTrim';

%% Here is for at stim until end of stim 10-23-2015

sigsTrim = sigs(presamps:end,:);
stdErrorTrim = stdError(presamps:end,:);


tTemp = t';
tTrim = tTemp(presamps:end,:);
tTrim = tTrim';
%% plot muCell


figure
plot(1e3*tTrim,sigsTrim);
hold on
title('Average CCEP values for each channel')
xlabel('time in ms')
ylabel('amplitude in uV')
xlim([-20 200])
ylim([-10e-5 10e-5])
vline([0])

%% look at MuCell from 10 ms after stimulation to 200 ms
% covariance, singular value decomposition

CovMatSig = cov(sigsTrim);
[U,S,V] = svd(CovMatSig);
figure
bar(diag(S));


%% pca

[coeff,score,latent,tsquared,explained,mu] = pca(sigsTrim);
figure
bar(explained)
title('Contribution (percent) of each principal component to explaining variance in CCEPs')

%%
% % biplot(coeff(:,1:3),'scores',score(:,1:3))


%% cross correlation volume conduction with channel of interest

chan = input('enter electrode of interest to compare against ');

corrsCell = cell(1,size(sigsTrim,2));
lagsCell = cell(1,size(sigsTrim,2));

figure
hold on

for i = 1:size(sigs,2)
    
   [C,lag] = xcorr(sigsTrim(:,chan),sigsTrim(:,i));
   corrsCell{i} = C;
   lagsCell{i} = lag;
   
   subplot(8,8,i)
   plot(1e3*lag/efs,C);
   
   title(sprintf('%d',i))
   
   if i == 64
      xlabel('Time in ms') 
   end
   
    
end

hold on
subtitle(sprintf('Cross correlation for CCEPs between channel %d and all other channels',chan))

%% 10-23-2015 - CCEP map for larry

%% do a plot of all channels 

betaChan = input('What was the beta triggered channel?  ');

figure

for i = chans
    mu = sigsTrim(:,i);
    stdErr = stdErrorTrim(:,i);
    chan = i;
    subplot(8,8,i)
    
    plot(1e3*tTrim, 1e6*mu);
    xlim(1e3*[-0.02 0.2]);
    %     xlim(1e3*[min(t) max(t)]);
    %     yl = ylim;
    %     yl(1) = min(-10, max(yl(1),-120));
    %     yl(2) = max(10, min(yl(2),100));
    %     ylim(yl);
%     ylim([-30 30])
    hold on
    vline(0);
    
    hold on
    plot(1e3*tTrim, 1e6*(mu+stdErr))
    hold on
    
    plot(1e3*tTrim, 1e6*(mu-stdErr))
    title(sprintf('Chan %d', chan))
    %
    %     xlabel('time (ms)');
    %     ylabel('ECoG (uV)');
    %
    %     title(sprintf('CCEP, Channel %d', chan))
    
    if i == 64
        xlabel('Time in ms')
        ylabel('Voltage in \muV')
    end
    
end

subtitle(sprintf('CCEP map for subject %s, Beta-Trigger Channel %d',sid,betaChan));



