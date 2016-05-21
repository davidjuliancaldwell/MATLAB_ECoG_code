%% 1/14/2016 - File by DJC to look at 3x3 stim data

% load in data

close all;clear all;clc

sid = input('What is the subject SID?    ','s');

SUB_DIR = fullfile(myGetenv('subject_dir'));

tp = strcat(SUB_DIR,'\0b5a2e\data\d8\0b5a2e_otherStim\0b5a2e_otherStim\3x3-2\3x3-2.mat');
switch sid
    case '0b5a2e'
        load(tp)
end

%% plot stim data 

figure

n = size(Stim.data,2);
l = size(Stim.data,1);


fs = Stim.info.SamplingRateHz;
fs_stim = fs;
t = (0:l-1)/fs;

for i = 1:size(Stim.data,2)
    ax(i+1) = subplot(n,1,i);
    plot(t,Stim.data(:,i))
    title(sprintf('Channel %d',i))
    maxChan = max(abs(Stim.data(:,i)));
    sprintf('Maximum voltage for Channel %d is %d',i,maxChan)
end

linkaxes(ax,'xy')
ylabel('Voltage (V)')
xlabel('Time (S)')

%%

bursts = [];

Sing1 = Sing.data(:,1);
fs_sing = Sing.info.SamplingRateHz;

samplesOfPulse = round(2*fs_stim/1e3);



% trying something like A_BuildStimTables from BetaStim


Sing1Mask = Sing1~=0;
dmode = diff([0 Sing1Mask' 0 ]);


dmode(end-1) = dmode(end);


bursts(2,:) = find(dmode==1);
bursts(3,:) = find(dmode==-1);

stims = squeeze(getEpochSignal(Sing1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (1:size(stims,1))/fs_sing;
t = t*1e3;
figure
plot(t,stims)
xlabel('Time (ms');

%%

%% Plot stims with info from above

stim1 = Stim.data(:,1);
stim1Epoched = squeeze(getEpochSignal(stim1,(bursts(2,:)-1),(bursts(3,:))+1));
t = (1:size(stim1Epoched,1))/fs_stim;
t = t*1e3;
figure
plot(t,stim1Epoched)
xlabel('Time (ms');

% hold on
%
% plot(t,stims)

delay = round(0.3277*fs_stim/1e3);
%%
fs_data = Wave.info.SamplingRateHz
stimTimes = bursts(2,:)-1+delay;
presamps = round(0.1 * fs_data); % pre time in sec
postsamps = round(0.30 * fs_data); % post time in sec, % modified DJC to look at up to 300 ms after



fac = fs_stim/fs_data;

sts = round(stimTimes / fac);

%%
data = Wave.data;

for i = 1:size(data,2)
    % modified DJC 4-20-2016 to think about stuff for Larry
    presamps = round(0.05 * fs_data); % pre time in sec
    postsamps = round(0.15 * fs_data); % post time in sec, % modified DJC to look at up to 300 ms after
    eco = data(:,i);
    
    edd = zeros(size(sts));
    efs = fs_data;
    
    temp = squeeze(getEpochSignal(eco, sts-presamps, sts+postsamps+1));
    foo = mean(temp,2);
    lastsample = round(0.040 * efs);
    foo(lastsample:end) = foo(lastsample-1);
    
    last = find(abs(zscore(foo))>1,1,'last');
    last2 = find(abs(diff(foo))>30e-6,1,'last')+1;
    
    zc = false;
    
    if (isempty(last2))
        if (isempty(last))
            error ('something seems wrong in the triggered average');
        else
            ct = last;
        end
    else
        if (isempty(last))
            ct = last2;
        else
            ct = max(last, last2);
        end
    end
    
    while (~zc && ct <= length(foo))
        zc = sign(foo(ct-1)) ~= sign(foo(ct));
        ct = ct + 1;
    end
    
    if (ct > max(last, last2) + 0.10 * efs) % marched along more than 10 msec, probably gone to far
        ct = max(last, last2);
    end
    
    % DJC - 8-31-2015 - i believe this is messing with the resizing
    % in the figures
    %             subplot(8,8,chan);
    %             plot(foo);
    %             vline(ct);
    %
%     for sti = 1:length(sts)
%         win = (sts(sti)-presamps):(sts(sti)+postsamps+1);
%         
%         % interpolation approach
%         eco(win(presamps:(ct-1))) = interp1([presamps-1 ct], eco(win([presamps-1 ct])), presamps:(ct-1));
%     end
    
    data(:,i) = eco;
end

%%
dataEpoched = squeeze(getEpochSignal(data,sts-presamps,sts+postsamps+1));
t = ((1:size(dataEpoched,1))*1e3/fs_data);



% look at mena

dataEpochedMean = squeeze(mean(dataEpoched,3));

ECoGData = permute(dataEpoched,[1 3 2]);


ECoGDataAverage = squeeze(mean(ECoGData,2));

Z_ConstantsLarryDavidStephen


save(fullfile(META_DIR, [sid '_3x3_StimulationAndCCEPs.mat']), 't','ECoGData','ECoGDataAverage','-v7.3');




