%% 7/2014 script to further analyze DMN data. Take a closer look at 3f5a8c
% adapted from QuickScreen_StimulusPresentation 

%% load in patient data

[sig_3f5a8c_d6_r02, sta_3f5a8c_d6_r02, par_3f5a8c_d6_r02] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R02.dat');
[sig_3f5a8c_d6_r03, sta_3f5a8c_d6_r03, par_3f5a8c_d6_r03] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R03.dat');
[sig_3f5a8c_d6_r04, sta_3f5a8c_d6_r04, par_3f5a8c_d6_r04] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d6\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R04.dat');
[sig_3f5a8c_d7_r04, sta_3f5a8c_d7_r04, par_3f5a8c_d7_r04] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R04.dat');
[sig_3f5a8c_d7_r05, sta_3f5a8c_d7_r05, par_3f5a8c_d7_r05] = load_bcidat('C:\Users\David\Desktop\Research\Rao Lab\MATLAB\Subjects\3f5a8c\data\d7\3f5a8c_ud_dmn001\3f5a8c_ud_dmnS001R05.dat');

num_runs = input('How many different trials?');

patient_3f5a8c = [sta_3f5a8c_d6_r02 sta_3f5a8c_d6_r03 sta_3f5a8c_d6_r04 sta_3f5a8c_d7_r04 sta_3f5a8c_d7_r05]';
patient_3f5a8c_feedback = {patient_3f5a8c(1).Feedback; patient_3f5a8c(2).Feedback; patient_3f5a8c(3).Feedback; patient_3f5a8c(4).Feedback; patient_3f5a8c(5).Feedback};
patient_3f5a8c_target = {patient_3f5a8c(1).TargetCode; patient_3f5a8c(2).TargetCode; patient_3f5a8c(3).TargetCode; patient_3f5a8c(4).TargetCode; patient_3f5a8c(5).TargetCode};
patient_3f5a8c_result = {patient_3f5a8c(1).ResultCode; patient_3f5a8c(2).ResultCode; patient_3f5a8c(3).ResultCode; patient_3f5a8c(4).ResultCode; patient_3f5a8c(5).ResultCode};

% convert all of the data to type double for analysis 
patient_3f5a8c_feedback = cellfun(@double, patient_3f5a8c_feedback, 'UniformOutput', false);
patient_3f5a8c_target = cellfun(@double, patient_3f5a8c_target, 'UniformOutput', false);
patient_3f5a8c_result = cellfun(@double, patient_3f5a8c_result, 'UniformOutput', false);

% compute indices of transitions for all data, keep it in cells 
x1 = cellfun(@diff, patient_3f5a8c_feedback, 'UniformOutput', false);
ind1 = cellfun(@(x) find(x<0),x1, 'UniformOutput', false);
y1 = cellfun(@(x) size(x), ind1, 'UniformOutput', false);
num_trials_complete1 = cellfun(@(x)x(1), y1); %extract from the array, not the cell!!!


%% collect appropriate information necessary to run
% filename to process
filepath = promptForBCI2000Recording;
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

% edited 9/3/2014 for abstract drawing, change samples to time(seconds),
% change titles, axes, etc 

figure;
prettyline(prettySigInterest, sta.TargetCode(targetStart),[0 0 .5; .5 0 0; .3 .3 1; 1 .3 .3])
h = get(gca,'xtick');
set(gca,'xticklabel',h/1200)
vline(1200); % draw lines dividing prettyLine into sections of interest 
vline(3600);
vline((3600+3600));
title('Representative HG powers across BCI trials for up and down targets')
xlabel('Time (seconds)')
ylabel('Log HG power')
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
prettyline(prettySigInterestSuccess,resultInterest,[0 0 .5; .5 0 0; .3 .3 1; 1 .3 .3])
vline(1200); % draw lines dividing prettyLine into sections of interest 
vline(3600);
vline(3600+3520);
title('Successful Trials - Gaussian Smoothed')
xlabel('Samples')
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

%ptarg = 0.05/numChans; % bonferroni correction? 
ptarg = 0.05; % testing one hypothesis at controlling electrode, start w/no correction 

[hDown,pDown,ciDown,statsDown] = ttest2(restHGmeansDown',activityHGmeansDown',ptarg,'r','unequal',1);
[hUp,pUp,ciUp,statsUp] = ttest2(restHGmeansUp', activityHGmeansUp', ptarg, 'r', 'unequal',1);
[hRest,pRest,ciRest,statsRest] = ttest2(restHGmeansUp',restHGmeansDown',ptarg,'r','unequal',1);

pDown
pUp
pRest

meanActUp = mean(activityHGmeansUp)
meanActDown = mean(activityHGmeansDown)
meanRestUp = mean(restHGmeansUp)
meanRestDown = mean(restHGmeansDown)

