%% 7/29/2014 - DJC - function to run on EACH DMN file, call from script.

function [activityHGmeansUp,activityHGmeansDown,restHGmeansUp, restHGmeansDown] = dmnProcess(filepath)

%% collect appropriate information necessary to run
% filename to process
subjid = extractSubjid(filepath);

%% load data and montage (if exists) in to memory
[~, ~, ext] = fileparts(filepath);

if (strcmp(ext, '.dat'))
    [sig, sta, par] = load_bcidat(filepath);
else
    load(filepath);
end

montageFilepath = strrep(filepath, '.dat', '_montage.mat');

if (exist(montageFilepath, 'file'))
    load(montageFilepath);
else
    % default Montage
    Montage.Montage = size(sig,2);
    Montage.MontageTokenized = {sprintf('Channel(1:%d)', size(sig,2))};
    Montage.MontageString = Montage.MontageTokenized{:};
    Montage.MontageTrodes = zeros(size(sig,2), 3);
    Montage.BadChannels = [];
    Montage.Default = true;
end


%% preprocess data
numChans = max(cumsum(Montage.Montage));
fs = par.SamplingRate.NumericValue;
sig = double(sig(:,1:numChans));

% common average re-reference.  Make sure to split up the gugers by
% amplifier bank using the function GugerizeMontage
if (mod(fs, 1200) == 0)
    sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, sig);
else
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
end

% notch filter to eliminate line noise
fprintf('notch filtering\n');
sig = notch(sig, [120 180], fs, 4);

% extract HG and Beta power bands
fprintf('extracting HG power\n');
logHGPower = log(hilbAmp(sig, [70 200], fs).^2);
fprintf('extracting Beta power\n');
logBetaPower = log(hilbAmp(sig, [12 18], fs).^2);

%% plotting prettyline for the approx 7 seconds across ALL samples

feedbackDiff = diff(double(sta.Feedback));
feedbackEnd = find(feedbackDiff < 0);

feedbackStart = find(feedbackDiff > 0);
prettyStart = feedbackStart - 3*fs;
prettyEnd = feedbackEnd+fs; %duration of feedback is not quite 3

%smooth signal first 7/28/2014, isntead of logHGpower
smoothedLogHGpower = GaussianSmooth(logHGPower,500);

prettySig = getEpochSignal(smoothedLogHGpower, prettyStart, prettyEnd);

prettySigInterest = prettySig(:,9,:);
prettySigInterest = squeeze(permute(prettySigInterest,[1 3 2]));

targetDiff = diff(double(sta.TargetCode));

targetStart = find(targetDiff > 0)+1;

% plot with time vector 10-13-2015
time = (prettyEnd-prettyStart);
time = time(1);

t = [1:1:time]./fs;

figure;
%adjusted to plot with time, rather than samples 
prettyline(t,prettySigInterest, sta.TargetCode(targetStart),[0 0 .5; .5 0 0; .3 .3 1; 1 .3 .3])
vline(1200/fs); % draw lines dividing prettyLine into sections of interest 
vline(3600/fs);
vline((3600+3520)/fs);
title('All Trials - Gaussian Smoothed')
xlabel('Time (seconds)')
ylabel('log HG Power')
legend('Up targets','Down targets')
% 
% figure;
% pretty_sig_interest_gaussian = GaussianSmooth(pretty_sig_interest,500);
% prettyline(pretty_sig_interest_gaussian, sta.TargetCode(target_start),[0 0 .5; .5 0 0; .3 .3 1; 1 .3 .3])
% vline(1200); % draw lines dividing prettyLine into sections of interest 
% vline(3600);
% vline(3600+3520);

%% plotting pretty line for only successful trials 

targets = sta.TargetCode(feedbackEnd);
results = sta.ResultCode(feedbackEnd+1);

prettyStartSuccess = feedbackStart(targets == results) - 3*fs;
prettyEndSuccess = prettyStartSuccess + 3520 + 4*fs;

%using pre-smoothed signal, 7/28/2014 
prettySigSuccess = getEpochSignal(smoothedLogHGpower, prettyStartSuccess,prettyEndSuccess);
prettySigInterestSuccess = prettySigSuccess(:,9,:);
prettySigInterestSuccess = squeeze(permute(prettySigInterestSuccess,[1 3 2]));

resultInterest = results(results==targets);

%pretty_sig_interest_success_gaussian = GaussianSmooth(pretty_sig_interest_success,200);
figure;
prettyline(t,prettySigInterestSuccess,resultInterest,[0 0 .5; .5 0 0; .3 .3 1; 1 .3 .3])
vline(1200/fs); % draw lines dividing prettyLine into sections of interest 
vline(3600/fs);
vline((3600+3520)/fs);
title('Successful Trials - Gaussian Smoothed')
xlabel('Time (seconds)')
ylabel('logHGPower')
legend('Up targets','Down targets')

%% epoch Stats, compare mean HG during activity to during rest for uptargets and down targets  

restStart = prettyStart;
restStop = prettyStart + 1200;

%feedback start has already been initialized 
%feedback_start = feedback_start;
feedbackEnd = feedbackStart + 3520;

activityHGmeans = getEpochMeans(logHGPower(:,9),feedbackStart,feedbackEnd);
restHGmeans = getEpochMeans(logHGPower(:,9),restStart,restStop);

%break up into up and down targets 
class = sta.TargetCode(targetStart);
activityHGmeansUp = activityHGmeans(:,class==1);
activityHGmeansDown = activityHGmeans(:,class==2);
restHGmeansUp = restHGmeans(:,class==1);
restHGmeansDown = restHGmeans(:,class==2);


%% DJC 10-14-2015
% plot cursor trajectory
cursorX = getEpochSignal(sta.CursorPosX, prettyStart,prettyEnd);
cursorY = getEpochSignal(sta.CursorPosY, prettyStart,prettyEnd);

cursorX = squeeze(cursorX);
cursorY = squeeze(cursorY);

cursorXUp = cursorX(:,class==1);
cursorYUp = cursorY(:,class==1);
cursorXDown = cursorX(:,class==2);
cursorYDown = cursorY(:,class==2);

figure
hold on
for i = 1:size(cursorYUp,2)
    plot(t,cursorYUp(:,i),'color','b','linewidth',4)
end

for i = 1:size(cursorYDown,2)
    plot(t,cursorYDown(:,i),'color','r','linewidth',4)
end

set(gca,'Ydir','reverse')
ylim([0 1024])
vline(1200/fs); % draw lines dividing prettyLine into sections of interest 
vline(3600/fs);
vline((3600+3520)/fs);
hline((1024/2));

%% DJC 10-14-2015
% plot cursor trajectory success
cursorX = getEpochSignal(sta.CursorPosX, prettyStartSuccess,prettyEndSuccess);
cursorY = getEpochSignal(sta.CursorPosY, prettyStartSuccess,prettyEndSuccess);

cursorX = squeeze(cursorX);
cursorY = squeeze(cursorY);

cursorXUp = cursorX(:,resultInterest==1);
cursorYUp = cursorY(:,resultInterest==1);
cursorXDown = cursorX(:,resultInterest==2);
cursorYDown = cursorY(:,resultInterest==2);

figure
hold on
for i = 1:size(cursorYUp,2)
    plot(t,cursorYUp(:,i),'color','r')
end

for i = 1:size(cursorYDown,2)
    plot(t,cursorYDown(:,i),'color','b')
end

vline(1200/fs); % draw lines dividing prettyLine into sections of interest 
vline(3600/fs);
vline((3600+3520)/fs);


%% feedback 10-14-2015
feedback = getEpochSignal(sta.Feedback, prettyStart,prettyEnd);
feedback = squeeze(feedback);


end
