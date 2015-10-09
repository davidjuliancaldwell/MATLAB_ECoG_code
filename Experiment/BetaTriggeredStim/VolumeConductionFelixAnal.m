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

% look at 10 ms after until end of signal, so
% presamps+1+round(10*efs/1000)

sigsTrim = sigs((presamps+1+round(10*efs/1000)):end,:);

tTemp = t';
tTrim = tTemp((presamps+1+round(10*efs/1000)):end,:);
tTrim = tTrim';
%% plot muCell


figure
plot(1e3*tTrim,sigsTrim);
hold on
title('Average CCEP values for each channel')
xlabel('time in ms')
ylabel('amplitude in uV')

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
    
   [C,lag] = xcorr(sigs(:,chan),sigs(:,i));
   corrsCell{i} = C;
   lagsCell{i} = lag;
   
   subplot(8,8,i)
   plot(lag/efs,C);
   
   title(sprintf('Channel %d',i))
   
   
   
    
end
subtitle('Cross correlation for CCEPs between channels in grid and Beta-Triggered Channel')

