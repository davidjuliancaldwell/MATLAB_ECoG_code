%% 7/2014 - DJC -  Trying to do analysis with wavelets first, epochs second
% basic idea
%
% import Data 
% preprocess data (common average rereference, etc)
% separate data into sections of interest (rest, rest hold, etc)
% perform wavelet analysis across these data regions
% normalize across the whole range to account for low frequency bias (1/f
% power of the brain, etc) 
% break up matrix coefficients into epochs based off of glove data
% visualize coefficents based off of epochs 

%%
clear all;

%% Load file and associated montage - FROM JARED
% Open up the relevant signal files, with the associated montage. In this
% step we also locate the directory tree for all cortical plots etc to be
% used later in the script.
pr.subjid = []; % initializing data structure pr
pr.filename = [];
[pr.filepath, pr.subjid, pr.filename] = fileHandling; % collect appropriate information necessary to run
[sig, sta, par, Montage] = loadMontage (pr.filepath); % load data and montage (if exists) in to memory
pro.subjid = pr.subjid; % initializing data structure pro
pro.filename = pr.filename;

%% Initial pre-processing of the signal with HG and Beta power extraction - FROM JARED
% Do basic common average re-referencing notch filtering, that's it, until after TFA  

pro.sig = carr (par, sig, Montage); % common average re-referencing
clear sig;

% notch filter to eliminate line noise
pr.harmonics = [120 180]; % user defined
pr.fs = par.SamplingRate.NumericValue;
pr.filtOrder = 4; % user defined
fprintf('notch filtering\n');
pro.sig = notch(pro.sig, pr.harmonics, pr.fs, pr.filtOrder);

%% Subject and file specific identification of test segments - FROM JARED
% goal in this step is to set up the specific variable values for use in
% the later scripts. This may be best implemented in a different way, such
% as by using object oriented programming, but for now it essentially
% populates a list of variables in memory for use later.  May be best to
% introduce these in a JIT fashion just before they are used in the
% following scripts. Not sure...

if isequal(pr.subjid, '4087bd') %4087bd_proprioceptionS001R02
        pr.hemisphere = 'l'; % hemisphere to visualize ('l', 'r', 'both')
        pr.identifier = 3; % how the epochs are idenfified (1) cyber glove, (2) audio responses, [3] stimulus code
        pr.aggregate = 'n'; % option to aggregate all stimulus codes together ('n' or'y')
        pr.restCode = 0; % usually zero, unless finger twister
        pr.responseDelay = 0; % number of miliseconds to delay processing to account for subject response time    
        pr.numChans = max(cumsum(Montage.Montage));
    %hard coded start and stop values for segments
        pr.stateRestStart = 1e4;
        pr.stateRestEnd = 7.2e4;
        pr.stateRestHoldStart = 1.3e5;
        pr.stateRestHoldEnd = 1.7e5;
        pr.stateTestStart = 2e5;
        pr.stateTestEnd = 2.761e5; %excluding last epoch start of this set
        pr.stateSelfStart = 2.8e5;
        pr.stateSelfEnd = 3.84e5;
        
                % data processing and presentation options
        % Note: this could be entered via object/ class to improve data handling
        pr.gloveData = sta.rCyber3;
        pr.fixedEpochDuration= 800; %(fixed epoch in samples) hardcoded for now...originally 1200 for 4087bd, then 800 for abstract, originally 600 for 828260
        pr.blackout = int64(2500); % hard coded period of time between starts of glove epochs. for 38e116_fingerflex_LS001R02 it was 5000. 4087bd was initialy 2000, best at 2500. 828260 was 1200
        pr.ampcutoff = 2; % derivative amplitude cutoff for selecting epoch start. Hardcoded for now. Varies between right and left cybergloves? for 38e116_fingerflex_LS001R02 it was 10.
        pr.nanifykeep = 1200; %orig 1200
        pr.nanifyFullPeriod = 2400; %orig 2400 (2 sec)
        pr.activities = 1;

end

if isequal (pr.subjid, '828260')% 828260_proprioceptionS001R03
        pr.hemisphere = 'l'; % hemisphere to visualize ('l', 'r', 'both')
        pr.identifier = 3; % how the epochs are idenfified (1) cyber glove, (2) audio responses, [3] stimulus code
        pr.aggregate = 'n'; % option to aggregate all stimulus codes together ('n' or'y')
        pr.restCode = 0; % usually zero, unless finger twister
        pr.responseDelay = 0; % number of miliseconds to delay processing to account for subject response time    
        pr.numChans = max(cumsum(Montage.Montage));
        %hard coded start and stop values for segments
        pr.stateRestStart = 5500;
        pr.stateRestEnd = 3.9e4;
        pr.stateRestHoldStart = 5.4e4;
        pr.stateRestHoldEnd = 7.95e4;
        pr.stateTestStart = 8.28e4;
        pr.stateTestEnd = 1.84e5; 
        pr.stateSelfStart = 1.94e5;
        pr.stateSelfEnd = 2.6e5;   
        
                % data processing and presentation options
        % Note: this could be entered via object/ class to improve data handling
        pr.gloveData = sta.rCyber3;
        pr.fixedEpochDuration= 800; %(fixed epoch in samples) originally 600 for 828260
        pr.blackout = int64(1200); % hard coded period of time between starts of epochs. for 38e116_fingerflex_LS001R02 it was 5000. 4087bd was initialy 2000, best at 2500. 828260 was 1200
        pr.ampcutoff = 2; % derivative amplitude cutoff for selecting epoch start. Hardcoded for now. Varies between right and left cybergloves? for 38e116_fingerflex_LS001R02 it was 10.
        pr.nanifykeep = 800; % orig 800
        pr.nanifyFullPeriod = 2400; %orig 2400 (2sec)
        pr.activities = 1;
        
end

if isequal(pr.subjid, 'f1ee00') %f1ee00_proprioceptionS001R04 - look at rCyber3
        pr.hemisphere = 'l'; % hemisphere to visualize ('l', 'r', 'both')
        pr.identifier = 3; % how the epochs are idenfified (1) cyber glove, (2) audio responses, [3] stimulus code
        pr.aggregate = 'n'; % option to aggregate all stimulus codes together ('n' or'y')
        pr.restCode = 0; % usually zero, unless finger twister
        pr.responseDelay = 0; % number of miliseconds to delay processing to account for subject response time    
        pr.numChans = max(cumsum(Montage.Montage));
    %hard coded start and stop values for segments
        pr.stateRestStart = 1.143e4;
        pr.stateRestEnd = 4.126e4;
        pr.stateRestHoldStart = 6.223e4;
        pr.stateRestHoldEnd = 1.007e5;
        pr.stateTestStart = 1.03e5;
        pr.stateTestEnd = 2.35e5; %excluding last epoch start of this set?
        pr.stateSelfStart = 2.436e5;
        pr.stateSelfEnd = 3.611e5;
        
                % data processing and presentation options
        % Note: this could be entered via object/ class to improve data handling
        pr.gloveData = sta.rCyber3;
        pr.fixedEpochDuration= 800; %(fixed epoch in samples) hardcoded for now...originally 1200 for 4087bd, then 800 for abstract, originally 600 for 828260
        pr.blackout = int64(1200); % hard coded period of time between starts of glove epochs. for 38e116_fingerflex_LS001R02 it was 5000. 4087bd was initialy 2000, best at 2500. 828260 was 1200
        pr.ampcutoff = 2; % derivative amplitude cutoff for selecting epoch start. Hardcoded for now. Varies between right and left cybergloves? for 38e116_fingerflex_LS001R02 it was 10.
        pr.nanifykeep = 800; %orig 1200 for first f1ee00 try 
        pr.nanifyFullPeriod = 2400; %orig 2400 (2 sec)
        pr.activities = 1;

end

if isequal(pr.subjid, 'a9952e') %a9952e_proprioceptionS001R04\1 - look at rCyber3
        pr.hemisphere = 'l'; % hemisphere to visualize ('l', 'r', 'both')
        pr.identifier = 3; % how the epochs are idenfified (1) cyber glove, (2) audio responses, [3] stimulus code
        pr.aggregate = 'n'; % option to aggregate all stimulus codes together ('n' or'y')
        pr.restCode = 0; % usually zero, unless finger twister
        pr.responseDelay = 0; % number of miliseconds to delay processing to account for subject response time    
        pr.numChans = max(cumsum(Montage.Montage));
    %hard coded start and stop values for segments
        pr.stateRestStart = 1e4;
        pr.stateRestEnd = 6.374e4;
        pr.stateRestHoldStart = 7.505e4;
        pr.stateRestHoldEnd = 1.418e5;
        pr.stateTestStart = 1.455e5;
        pr.stateTestEnd = 3.982e5; %excluding last epoch start of this set?
        pr.stateSelfStart = 4.686e5; %to ignore noise at the beginning of the task
        pr.stateSelfEnd = 6.291e5;
        
                % data processing and presentation options
        % Note: this could be entered via object/ class to improve data handling
        pr.gloveData = sta.rCyber3;
        pr.fixedEpochDuration= 800; %(fixed epoch in samples) hardcoded for now...originally 1200 for 4087bd, then 800 for abstract, originally 600 for 828260
        pr.blackout = int64(1200); % hard coded period of time between starts of glove epochs. for 38e116_fingerflex_LS001R02 it was 5000. 4087bd was initialy 2000, best at 2500. 828260 was 1200
        pr.ampcutoff = 2; % derivative amplitude cutoff for selecting epoch start. Hardcoded for now. Varies between right and left cybergloves? for 38e116_fingerflex_LS001R02 it was 10.
        pr.nanifykeep = 800; % DJC 7/2014, try 800? 
        pr.nanifyFullPeriod = 2400; %orig 2400 (2 sec)
        pr.activities = 1;

end

if isequal(pr.subjid, 'd5cd55') %d5cd55_proprioceptionS001R02 - look at rCyber3
        pr.hemisphere = 'l'; % hemisphere to visualize ('l', 'r', 'both')
        pr.identifier = 3; % how the epochs are idenfified (1) cyber glove, (2) audio responses, [3] stimulus code
        pr.aggregate = 'n'; % option to aggregate all stimulus codes together ('n' or'y')
        pr.restCode = 0; % usually zero, unless finger twister
        pr.responseDelay = 0; % number of miliseconds to delay processing to account for subject response time    
        pr.numChans = max(cumsum(Montage.Montage));
    %hard coded start and stop values for segments
        pr.stateRestStart = 1.104e4;
        pr.stateRestEnd = 7.364e4;
        pr.stateRestHoldStart = 8.453e4;
        pr.stateRestHoldEnd = 1.538e5;
        pr.stateTestStart = 1.635e5;
        pr.stateTestEnd = 3.105e5; %excluding last epoch start of this set?
        pr.stateSelfStart = 3.165e5;
        pr.stateSelfEnd = 4.364e5;
        
                % data processing and presentation options
        % Note: this could be entered via object/ class to improve data handling
        pr.gloveData = sta.rCyber3;
        pr.fixedEpochDuration= 800; %(fixed epoch in samples) hardcoded for now...originally 1200 for 4087bd, then 800 for abstract, originally 600 for 828260
        pr.blackout = int64(1500); % hard coded period of time between starts of glove epochs. for 38e116_fingerflex_LS001R02 it was 5000. 4087bd was initialy 2000, best at 2500. 828260 was 1200
        pr.ampcutoff = 2; % derivative amplitude cutoff for selecting epoch start. Hardcoded for now. Varies between right and left cybergloves? for 38e116_fingerflex_LS001R02 it was 10.
        pr.nanifykeep = 800; %orig 1200
        pr.nanifyFullPeriod = 2400; %orig 2400 (2 sec)
        pr.activities = 1;

end

%this code turns sta.rCyber3 into an array with a sample counter
pro.jointState(:,2) = pr.gloveData;
pro.jointState = double (pro.jointState);
pro.jointState(:,1) = 1:length(pro.jointState);

%% identify the cyberglove responses- taken from extractCyberGloveResponses - FROM JARED 
% In this step we identify the start of each finger movement determined by
% the rate of change of the glove state variable at the thumb joint. Then,
% we convert each finger movement into an "epoch" of finger movement using
% hard-coded time block

pro.responseCode = extractCyberGloveResponses(sta, pr);

%% breaking up jointState into discrete components based on experiment - FROM JARED
% design. In this section, we break up the overall joint state array into
% states based on the action performed during that block, as identified by
% the subject-specific states. 

pro.jointStateRest = pro.jointState(pr.stateRestStart:pr.stateRestEnd, :);
pro.jointStateRestHold = pro.jointState(pr.stateRestHoldStart:pr.stateRestHoldEnd, :);
pro.jointStateTest = pro.jointState(pr.stateTestStart:pr.stateTestEnd, :);
pro.jointStateSelf = pro.jointState(pr.stateSelfStart:pr.stateSelfEnd, :);


%% plotting the overall joint states - FROM JARED 
figure;
plot (pro.jointState(:,1), pro.jointState(:,2), 'k');

% plotting each of the components on the original joint state plot
hold on;
plot (pro.jointStateRest(:,1), pro.jointStateRest(:,2), 'b');
plot (pro.jointStateRestHold(:,1), pro.jointStateRestHold(:,2), 'b');
plot (pro.jointStateTest(:,1), pro.jointStateTest(:,2), 'g');
plot (pro.jointStateSelf(:,1), pro.jointStateSelf(:,2), 'b');
xlabel('sample count')
ylabel('cyberglove state')
title('Glove States Segmented')
hold off;

%% obtain signals for each part of the experiment in blocks - from jared 
Rsig = pro.sig(pr.stateRestStart:pr.stateRestEnd, :);
RHsig = pro.sig(pr.stateRestHoldStart:pr.stateRestHoldEnd, :);
Tsig = pro.sig(pr.stateTestStart:pr.stateTestEnd, :);
Ssig = pro.sig(pr.stateSelfStart:pr.stateSelfEnd, :);

%% TFA - partly from miah, jared
fw = [1:3:200];
fs = 1200; 

% make matrix of normalized wavelet coefficients 

RsigWavelet = zeros(size(Rsig,1),size(fw,2),size(Rsig,2)); %initialized matrix of samples x frequencies x channels 

for iChan = 1:size(Rsig,2)
    
    [~, ~, temp] = time_frequency_wavelet(Rsig(:,iChan),fw,fs,1,0,'CPUtest'); % calculate wavelet coefficients for each channel across rest time signal
    tempAbs = abs(temp); % discard phase information of wavelet for plotting 
    tempz = zscore(tempAbs); % z-score wavelet across whole time period
    RsigWavelet(:,:,iChan) = tempz; % build up 3D matrix where each plane is a channel 

end

[restStarts, restStops] = getEpochs(responseCode, rest, false);
[activityStarts, activityStops] = getEpochs(responseCode, activity, false);

foo = getEpochSignal(temp, 1:1000:10000, 51:1000:10051);



% C.R = time_frequency_wavelet(Rsig(1:1200, 1),fw,fs,1,0,'CPUtest');

imagesc(1:

%% break 
