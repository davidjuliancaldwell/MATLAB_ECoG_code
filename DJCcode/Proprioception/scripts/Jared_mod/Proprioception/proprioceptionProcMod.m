%%Sript for data epochs in 4087bd, proprioception testing
%JDO 8/2013 adapted from QuickScreen_StimulusPresentation by JDW
% modified significantly 12/2013 to move many lines of code out of
% functions.

%modified by DJC 7/2014, Subjects - f1ee00, a9952e, d5cd55

clear all;

%% Load file and associated montage
% Open up the relevant signal files, with the associated montage. In this
% step we also locate the directory tree for all cortical plots etc to be
% used later in the script.
pr.subjid = []; % initializing data structure pr
pr.filename = [];
[pr.filepath, pr.subjid, pr.filename] = fileHandling; % collect appropriate information necessary to run
[sig, sta, par, Montage] = loadMontage (pr.filepath); % load data and montage (if exists) in to memory
pro.subjid = pr.subjid; % initializing data structure pro
pro.filename = pr.filename;

%% Initial pre-processing of the signal with HG and Beta power extraction
% Do basic common average re-referencing notch filtering, then extract the
% high-gamma and beta power in each frequency bin.  This is essentially
% pre-processing for use in further steps.
% [fs, sig, logHGPower, logBetaPower, numChans] = preProc (sig, par, Montage);

pro.sig = carr (par, sig, Montage); % common average re-referencing
clear sig;

% notch filter to eliminate line noise
pr.harmonics = [120 180]; % user defined
pr.fs = par.SamplingRate.NumericValue;
pr.filtOrder = 4; % user defined
fprintf('notch filtering\n');
pro.sig = notch(pro.sig, pr.harmonics, pr.fs, pr.filtOrder);

% extract HG and Beta power bands
pr.hgRange = [70 200]; % user defined HG range
pr.betaRange = [12 18]; % user defined beta rainge
fprintf('extracting HG power\n');
pro.logHGPower = log(hilbAmp(pro.sig, pr.hgRange, pr.fs).^2); % HG power- hilbAmp is custom
fprintf('extracting Beta power\n');
pro.logBetaPower = log(hilbAmp(pro.sig, pr.betaRange, pr.fs).^2); % beta power

%% Subject and file specific identification of test segments
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

% plotting the overall joint states
%figure;
%plot (jointState(:,1), jointState(:,2), 'k');

%% identify the cyberglove responses- taken from extractCyberGloveResponses
% In this step we identify the start of each finger movement determined by
% the rate of change of the glove state variable at the thumb joint. Then,
% we convert each finger movement into an "epoch" of finger movement using
% hard-coded time block
%D_extractCyberGloveResponses;
%D_1_plotGloveWithEpoch;
pro.responseCode = extractCyberGloveResponses(sta, pr);

%% breaking up jointState into discrete components based on experiment
% design. In this section, we break up the overall joint state array into
% states based on the action performed during that block, as identified by
% the subject-specific states. 
pro.jointStateRest = pro.jointState(pr.stateRestStart:pr.stateRestEnd, :);
pro.jointStateRestHold = pro.jointState(pr.stateRestHoldStart:pr.stateRestHoldEnd, :);
pro.jointStateTest = pro.jointState(pr.stateTestStart:pr.stateTestEnd, :);
pro.jointStateSelf = pro.jointState(pr.stateSelfStart:pr.stateSelfEnd, :);

%% plotting the overall joint states
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

%% Rest vs Rest Hold (while finger is held).
fprintf ('processing Rest vs Rest Hold states for %s \n', pr.filename)
fprintf ('Rest Hold is active state \n')

% sigRvRH nomenclature: signal for Rest vs Rest Hold
RvRH.sigRest = pro.sig (pr.stateRestStart:pr.stateRestEnd, :);
RvRH.sigHold = pro.sig (pr.stateRestHoldStart:pr.stateRestHoldEnd, :); % breaking all channels of sig into components of interest
RvRH.stateRest = zeros (pr.stateRestEnd- pr.stateRestStart, 1); %code for replacing responseCode with responseCodeRvRH comprised of zeros for rest period and ones for period of interest
RvRH.stateRest = nanify(RvRH.stateRest, pr.nanifykeep, pr.nanifyFullPeriod); %1200 for 4087bd. This code is creating NaN state for breaking data into rest epochs
RvRH.stateHold = ones (pr.stateRestHoldEnd-pr.stateRestHoldStart, 1);
RvRH.stateHold = nanify(RvRH.stateHold, pr.nanifykeep, pr.nanifyFullPeriod); %1200 for 4087bd

%from here down, the broken-up sig and response codes are put back together
%for statisical analysis...kludgy. 
RvRH.jointState = [pro.jointStateRest; pro.jointStateRestHold];% joining joint states of interest
RvRH.sig = [RvRH.sigRest;RvRH.sigHold]; % joining sig of interest
RvRH.responseCode = [RvRH.stateRest;RvRH.stateHold]; % joining response codes of interest
RvRH.responseCode (length (RvRH.responseCode)) = 0; %ending the data set with a rest code
RvRH.responseCode (1) = 0; %starting data set with rest code
RvRH.logHGPower = [(pro.logHGPower(pr.stateRestStart:pr.stateRestEnd, :));...
    (pro.logHGPower(pr.stateRestHoldStart:pr.stateRestHoldEnd,:))]; % breaking logHGPower into components of interest
RvRH.logBetaPower = [(pro.logBetaPower(pr.stateRestStart:pr.stateRestEnd, :));...
    (pro.logBetaPower(pr.stateRestHoldStart:pr.stateRestHoldEnd, :))];

%% rest vs hold with statistcal analysis
[RvRH.restHGs, RvRH.restBetas, RvRH.activityHGs, RvRH.activityBetas, RvRH.windows, RvRH.ts, RvRH.restLength, ~] = ...
    powerDeltaCalcProprioception ...
    (RvRH.responseCode, pr.restCode, pr.numChans, RvRH.logHGPower, RvRH.logBetaPower, pr.activities, RvRH.sig, pr.fs);
[RvRH.HGSigs, RvRH.BetaSigs, RvRH.HGRSAs, RvRH.BetaRSAs, RvRH.HGSigsp, RvRH.BetaSigsp, RvRH.HGCi1, RvRH.HGCi2, RvRH.BetaCi1, RvRH.BetaCi2, RvRH.HGStats, RvRH.BetaStats] = ...
    epochStats (RvRH.activityHGs, RvRH.activityBetas, RvRH.restHGs, RvRH.restBetas, pr.activities, pr.numChans);

% %% plots rest vs hold
% 
legendEntries = linePlots (pr.numChans, RvRH.HGRSAs, RvRH.HGSigs, pr.aggregate, RvRH.BetaRSAs, RvRH.BetaSigs, pr.activities, pr.filename, par, RvRH.HGSigsp, RvRH.BetaSigsp); %line plots of channels...no cortical surfaces needed
% corticalPlots (Montage, pr.aggregate, pr.subjid, RvRH.HGRSAs, RvRH.BetaRSAs, pr.hemisphere, pr.activities, legendEntries, pr.filename); % do the cortical plots

% %% TFA rest vs hold
%  tfa(RvRH.HGSigs, RvRH.BetaSigs, RvRH.windows, RvRH.ts, Montage, pr.aggregate, pr.activities, pr.fs, RvRH.restLength); % do time frequency plots 

dummy=NaN(64); %Why use this? DJC 7/2014, changed dummy to RvRH.HGRSA
corticalPlots (Montage, pr.aggregate, pr.subjid, RvRH.HGRSAs, RvRH.BetaRSAs, pr.hemisphere, pr.activities, legendEntries, pr.filename); % do the cortical plots

    
%% Rest holding finger vs passive movement of joint

fprintf ('processing Rest Hold vs Test states for %s \n', pr.filename)
fprintf ('Test is active state \n')

RHvT.sig = [(pro.sig (pr.stateRestHoldStart:pr.stateRestHoldEnd, :)); (pro.sig (pr.stateTestStart:pr.stateTestEnd, :))];
RHvT.jointState = [pro.jointStateRestHold; pro.jointStateTest];
temp = double(pro.responseCode (pr.stateRestHoldStart:pr.stateRestHoldEnd));
temp = nanify(temp, pr.nanifykeep, pr.nanifyFullPeriod); %1200 for 4087bd
tempStateTest = double(pro.responseCode(pr.stateTestStart:pr.stateTestEnd));
tempStateTest(tempStateTest==0) = NaN;
RHvT.responseCode = [(temp);(tempStateTest)];
%clear ('temp', 'tempStateTest')
clear 'temp'

% figure
% plot (responseCodeRHvT)
% ylim ([-2 2])
%responseCodeRHvT = [(responseCode (stateRestHoldStart:stateRestHoldEnd));(responseCode (stateTestStart:stateTestEnd))];
%temp1 = zeros (stateRestHoldEnd-stateRestHoldStart, 1);
%temp2 = ones (stateTestEnd-stateTestStart, 1);
%responseCodeRHvT = [temp1;temp2];
%responseCodeRHvT (length (responseCodeRHvT)) = 0; %ending the data set with a rest code
%responseCodeRHvT (1) = 0; %starting data set with rest code

RHvT.logHGPower = [(pro.logHGPower(pr.stateRestHoldStart:pr.stateRestHoldEnd, :));(pro.logHGPower(pr.stateTestStart:pr.stateTestEnd,:))];
RHvT.logBetaPower = [(pro.logBetaPower(pr.stateRestHoldStart:pr.stateRestHoldEnd, :));(pro.logBetaPower(pr.stateTestStart:pr.stateTestEnd, :))];

%% rest hold vs test with statistcal analysis
[RHvT.restHGs, RHvT.restBetas, RHvT.activityHGs, RHvT.activityBetas, RHvT.windows, RHvT.ts, RHvT.restLength, ~] = ...
    powerDeltaCalcProprioception ...
    (RHvT.responseCode, pr.restCode, pr.numChans, RHvT.logHGPower, RHvT.logBetaPower, pr.activities, RHvT.sig, pr.fs);
[RHvT.HGSigs, RHvT.BetaSigs, RHvT.HGRSAs, RHvT.BetaRSAs, RHvT.HGSigsp, RHvT.BetaSigsp, RHvT.HGCi1, RHvT.HGCi2, RHvT.BetaCi1, RHvT.BetaCi2, RHvT.HGStats, RHvT.BetaStats] = ...
    epochStats (RHvT.activityHGs, RHvT.activityBetas, RHvT.restHGs, RHvT.restBetas, pr.activities, pr.numChans);

%% plots rest hold vs test

legendEntries = linePlots (pr.numChans, RHvT.HGRSAs, RHvT.HGSigs, pr.aggregate, RHvT.BetaRSAs, RHvT.BetaSigs, pr.activities, pr.filename, par, RHvT.HGSigsp, RHvT.BetaSigsp); %line plots of channels...no cortical surfaces needed
corticalPlots (Montage, pr.aggregate, pr.subjid, RHvT.HGRSAs, RHvT.BetaRSAs, pr.hemisphere, pr.activities, legendEntries, pr.filename); % do the cortical plots

%% TFA rest hold vs test - %modified by DJC 7/2014 - do this for ONE channel right now (Select electrode)
[RHvT.t, RHvT.fw, RHvT.normC] = tfa(RHvT.HGSigs, RHvT.BetaSigs, RHvT.windows, RHvT.ts, Montage, pr.aggregate, pr.activities, pr.fs, RHvT.restLength); % do time frequency plots 

%% 7/2014 - Modified by DJC - Quantification of beta desynchronization and gamma onset 

% make 3D matrix, 1st dimension normC, 2nd fw, 3rd t 
RHvT.waveletmatrix = RHvT.normC;
RHvT.waveletmatrix(:,:,2) = repmat(RHvT.fw',1,size(RHvT.normC,2));
RHvT.waveletmatrix(:,:,3) = repmat(RHvT.t,size(RHvT.normC,1),1);

%below finds the LINEAR index on the first "plane" of data, which is the
%2d matrix of normC. Find requires that all of its conditions have the same
%size that is being searched, and it returns the index which matches the
%conditions on each plane. So the given linear condition matches the 1st,
%2nd, 3rd "level" of the multidimensional array. If they are different
%sizes this would not work. 

RHvT.betadesync = find((RHvT.waveletmatrix(:,:,1)<-5) & (12 < RHvT.waveletmatrix(:,:,2)) & (RHvT.waveletmatrix(:,:,2)< 18) ...
    & (-0.2 < RHvT.waveletmatrix(:,:,3)) & (RHvT.waveletmatrix(:,:,3) < 0.2), 1); % find first occurence of given threshold

RHvT.gammaonset = find(RHvT.waveletmatrix(:,:,1)>5 & (70 < RHvT.waveletmatrix(:,:,2)) & (RHvT.waveletmatrix(:,:,2) < 200) ...
    & (-0.2 < RHvT.waveletmatrix(:,:,3)) & (RHvT.waveletmatrix(:,:,3) < 0.2), 1); % find first occurence of given threshold

%compute the size of the normC, or wavelet coefficients, so that by using
%ind2sub the linear index can be converted into x,y coordinates which can
%be used to extract the times of the beta desync and gamma onset. 
RHvT.sizetfa = [size(RHvT.normC,1),size(RHvT.normC,2)];
[RHvT.betax, RHvT.betay] = ind2sub(RHvT.sizetfa,RHvT.betadesync);
[RHvT.gammax, RHvT.gammay] = ind2sub(RHvT.sizetfa,RHvT.gammaonset);

%compute the time difference between gamma onset and beta desync
RHvT.timediff = RHvT.waveletmatrix(RHvT.gammax,RHvT.gammay,3)-RHvT.waveletmatrix(RHvT.betax,RHvT.betay,3);

% plot
figure
image = imagesc(RHvT.t,RHvT.fw,RHvT.normC);
axis xy;
colorbar
set_colormap_threshold(gcf, [-2 2], [-10 10], [1 1 1]); 
hold on
%draw vertical lines at the onset of gamma, desync of beta 
vline(RHvT.waveletmatrix(RHvT.betax, RHvT.betay,3),'r','beta')
vline(RHvT.waveletmatrix(RHvT.gammax, RHvT.gammay,3),'b','gamma')
%% Testing Subject at rest vs self paced movement

fprintf ('processing Rest vs Self Paced Movement for %s \n', pr.filename)
fprintf ('Self Paced is active state \n')

RvS.sig = [(pro.sig (pr.stateRestStart:pr.stateRestEnd, :)); (pro.sig (pr.stateSelfStart:pr.stateSelfEnd, :))];
RvS.jointState = [pro.jointStateRest; pro.jointStateSelf];

temp = double(pro.responseCode (pr.stateRestStart:pr.stateRestEnd));
temp = nanify(temp, pr.nanifykeep, pr.nanifyFullPeriod); %1200 for 4087bd
tempStateSelf = double(pro.responseCode(pr.stateSelfStart:pr.stateSelfEnd));
tempStateSelf(tempStateSelf==0) = NaN;
RvS.responseCode = [(temp);(tempStateSelf)];
%clear ('temp', 'tempStateSelf')
%responseCodeRvS = [(responseCode (stateRestStart:stateRestEnd));(responseCode (stateSelfStart:stateSelfEnd))];

RvS.logHGPower = [(pro.logHGPower(pr.stateRestStart:pr.stateRestEnd, :));(pro.logHGPower(pr.stateSelfStart:pr.stateSelfEnd,:))];
RvS.logBetaPower = [(pro.logBetaPower(pr.stateRestStart:pr.stateRestEnd, :));(pro.logBetaPower(pr.stateSelfStart:pr.stateSelfEnd, :))];

%% rest vs self with statistcal analysis
[RvS.restHGs, RvS.restBetas, RvS.activityHGs, RvS.activityBetas, RvS.windows, RvS.ts, RvS.restLength, ~] = ...
    powerDeltaCalcProprioception ...
    (RvS.responseCode, pr.restCode, pr.numChans, RvS.logHGPower, RvS.logBetaPower, pr.activities, RvS.sig, pr.fs);
[RvS.HGSigs, RvS.BetaSigs, RvS.HGRSAs, RvS.BetaRSAs, RvS.HGSigsp, RvS.BetaSigsp, RvS.HGCi1, RvS.HGCi2, RvS.BetaCi1, RvS.BetaCi2, RvS.HGStats, RvS.BetaStats] = ...
    epochStats (RvS.activityHGs, RvS.activityBetas, RvS.restHGs, RvS.restBetas, pr.activities, pr.numChans);

%% plots rest vs self 

legendEntries = linePlots (pr.numChans, RvS.HGRSAs, RvS.HGSigs, pr.aggregate, RvS.BetaRSAs, RvS.BetaSigs, pr.activities, pr.filename, par, RvS.HGSigsp, RvS.BetaSigsp); %line plots of channels...no cortical surfaces needed
corticalPlots (Montage, pr.aggregate, pr.subjid, RvS.HGRSAs, RvS.BetaRSAs, pr.hemisphere, pr.activities, legendEntries, pr.filename); % do the cortical plots

%% TFA rest vs self - modified by DJC 7/2014
[RvS.t, RvS.fw,RvS.normC] = tfa(RvS.HGSigs, RvS.BetaSigs, RvS.windows, RvS.ts, Montage, pr.aggregate, pr.activities, pr.fs, RvS.restLength); % do time frequency plots 


% %% Testing Subject at Test vs self paced movement
% 
% fprintf ('processing Test vs Self Paced Movement for %s \n', pr.filename)
% fprintf ('Self Paced is active state \n')
% 
% TvS.sig = [(pro.sig (pr.stateTestStart:pr.stateTestEnd, :)); (pro.sig (pr.stateSelfStart:pr.stateSelfEnd, :))];
% TvS.jointState = [pro.jointStateTest; pro.jointStateSelf];
% tempStateTest (tempStateTest == 1) = 0;
% TvS.responseCode = [(tempStateTest);(tempStateSelf)];
% 
% TvS.logHGPower = [(pro.logHGPower(pr.stateTestStart:pr.stateTestEnd, :));(pro.logHGPower(pr.stateSelfStart:pr.stateSelfEnd,:))];
% TvS.logBetaPower = [(pro.logBetaPower(pr.stateTestStart:pr.stateTestEnd, :));(pro.logBetaPower(pr.stateSelfStart:pr.stateSelfEnd, :))];
% 
% %% test vs self with statistcal analysis
% [TvS.restHGs, TvS.restBetas, TvS.activityHGs, TvS.activityBetas, TvS.windows, TvS.ts, TvS.restLength, ~] = ...
%     powerDeltaCalcProprioception ...
%     (TvS.responseCode, pr.restCode, pr.numChans, TvS.logHGPower, TvS.logBetaPower, pr.activities, TvS.sig, pr.fs);
% [TvS.HGSigs, TvS.BetaSigs, TvS.HGRSAs, TvS.BetaRSAs, TvS.HGSigsp, TvS.BetaSigsp, TvS.HGCi1, TvS.HGCi2, TvS.BetaCi1, TvS.BetaCi2, TvS.HGStats, TvS.BetaStats] = ...
%     epochStats (TvS.activityHGs, TvS.activityBetas, TvS.restHGs, TvS.restBetas, pr.activities, pr.numChans);
% 
% %% plots tes vs self 
% 
% legendEntries = linePlots (pr.numChans, TvS.HGRSAs, TvS.HGSigs, pr.aggregate, TvS.BetaRSAs, TvS.BetaSigs, pr.activities, pr.filename, par, TvS.HGSigsp, TvS.BetaSigsp); %line plots of channels...no cortical surfaces needed
% corticalPlots (Montage, pr.aggregate, pr.subjid, TvS.HGRSAs, TvS.BetaRSAs, pr.hemisphere, pr.activities, legendEntries, pr.filename); % do the cortical plots
% 
% %% TFA test vs self 
% tfa(TvS.HGSigs, TvS.BetaSigs, TvS.windows, TvS.ts, Montage, pr.aggregate, pr.activities, pr.fs, TvS.restLength); % do time frequency plots 

%% 7/2014 - Modified by DJC - Quantification of beta desynchronization and gamma onset 

% make 3D matrix, 1st dimension normC, 2nd fw, 3rd t 
RvS.waveletmatrix = RvS.normC;
RvS.waveletmatrix(:,:,2) = repmat(RvS.fw',1,size(RvS.normC,2));
RvS.waveletmatrix(:,:,3) = repmat(RvS.t,size(RvS.normC,1),1);

%below finds the LINEAR index on the first "plane" of data, which is the
%2d matrix of normC. Find requires that all of its conditions have the same
%size that is being searched, and it returns the index which matches the
%conditions on each plane. So the given linear condition matches the 1st,
%2nd, 3rd "level" of the multidimensional array. If they are different
%sizes this would not work. 

RvS.betadesync = find((RvS.waveletmatrix(:,:,1)<-4) & (12 < RvS.waveletmatrix(:,:,2)) & (RvS.waveletmatrix(:,:,2)< 18) ...
    & (-0.2 < RvS.waveletmatrix(:,:,3)) & (RvS.waveletmatrix(:,:,3) < 0.2), 1); % find first occurence of given threshold

RvS.gammaonset = find(RvS.waveletmatrix(:,:,1)>4 & (70 < RvS.waveletmatrix(:,:,2)) & (RvS.waveletmatrix(:,:,2) < 200) ...
    & (-0.2 < RvS.waveletmatrix(:,:,3)) & (RvS.waveletmatrix(:,:,3) < 0.2), 1); % find first occurence of given threshold

%compute the size of the normC, or wavelet coefficients, so that by using
%ind2sub the linear index can be converted into x,y coordinates which can
%be used to extract the times of the beta desync and gamma onset. 
RvS.sizetfa = [size(RvS.normC,1),size(RvS.normC,2)];
[RvS.betax, RvS.betay] = ind2sub(RvS.sizetfa,RvS.betadesync);
[RvS.gammax, RvS.gammay] = ind2sub(RvS.sizetfa,RvS.gammaonset);

%compute the time difference between gamma onset and beta desync
RvS.timediff = RvS.waveletmatrix(RvS.gammax,RvS.gammay,3)-RvS.waveletmatrix(RvS.betax,RvS.betay,3);

% plot
figure
image = imagesc(RvS.t,RvS.fw,RvS.normC);
axis xy;
colorbar
set_colormap_threshold(gcf, [-2 2], [-10 10], [1 1 1]); 
hold on
%draw vertical lines at the onset of gamma, desync of beta 
vline(RvS.waveletmatrix(RvS.betax, RvS.betay,3),'r','beta')
vline(RvS.waveletmatrix(RvS.gammax, RvS.gammay,3),'b','gamma')

