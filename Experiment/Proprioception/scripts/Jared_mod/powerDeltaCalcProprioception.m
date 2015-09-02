%%function to calculate power during rest and during activity
 
% inputs:
% responseCode
% rest
% numChans
% logHGPower
% logBetaPower
% activities
% 
% outputs: 
% restHGs
% restBetas
% activityHGs
% activityBetas
% windows
% ts

function  [restHGs, restBetas, activityHGs, activityBetas, windows, ts, restLength, activityLength]...
    = powerDeltaCalcProprioception (responseCode, rest, numChans, logHGPower, logBetaPower, activities, sig, fs)

[restStarts, restStops] = getEpochs(responseCode, rest, false);  %calls getEpochs for REST periods

restHGs = zeros(length(restStarts), numChans);
restBetas = zeros(length(restStarts), numChans);

%determining the resting HG and Beta by taking the mean of the logHGPower
%and logBetaPower during rest intervals only
for n = 1:length(restStarts)
    restHGs(n, :) = mean(logHGPower(restStarts(n):restStops(n), :), 1);
    restBetas(n, :) = mean(logBetaPower(restStarts(n):restStops(n), :), 1);
end

%determining the HG and beta during each activity period (general case for
%multiple activity periods). Net effect is that the calculations in this
%section are based on the actual activity starts and stops as determined by
%getEpochs, but then for the windowing, AVERAGES of the rest and active
%periods are used instead.

%creating cell arrays for each activityIdx
actHGs = cell(length(activities), 1);
actBetas = cell(length(activities), 1);

windows = cell(length(activities), 1);
ts = cell(length(activities), 1);

for activityIdx = 1:length(activities) %activityIdx is the counter for all possible activity states. 
    activity = activities(activityIdx);
    
    [activityStarts, activityStops] = getEpochs(responseCode, activity, false); %calls getEpochs for ACTIVITY periods
    
    activityLength = round(mean(activityStops-activityStarts)); %IMPORTANT: appears to take MEAN activity length, not actual lengths
    restLength = round(mean(restStops-restStarts)); %IMPORTANT: appears to take MEAN rest length, not actual
    isValidWindow = ((activityStarts - restLength) > 0) & ((activityStarts + activityLength) <= size(sig,1)); %checking that lengths are valid
    
    activityHGs{activityIdx} = zeros(length(activityStarts), numChans); %initializing storage variables
    activityBetas{activityIdx} = zeros(length(activityStarts), numChans);
    windows{activityIdx} = zeros(restLength+activityLength, numChans, sum(isValidWindow)); %creating window length based on rest and activity lengths for each activityIdx. JDO- create option for user-determined window length?
% windows is a cell with a container for each activity state, samples x
% channels x activity repitition count
    ts{activityIdx} = (-restLength:(activityLength-1)) / fs; %creating the time index from the sample index (ts means time stamp)
    
    for n = 1:length(activityStarts)
        activityHGs{activityIdx}(n, :) = mean(logHGPower(activityStarts(n):activityStops(n), :), 1); % taking mean logHGPower of all active times, the last ", 1)" does not seem to be necessary...
        activityBetas{activityIdx}(n, :) = mean(logBetaPower(activityStarts(n):activityStops(n), :), 1);% same as above for beta
        
        if (isValidWindow(n))
            windows{activityIdx}(:, :, n) = sig((activityStarts(n)-restLength):(activityStarts(n)+activityLength-1), :); % storing sig data in the window variable based on the activity start minus rest length, to activity length minus 1. JDO- in conjunction with creation of the window, consider a user-determined window length option?
        end
    end
end