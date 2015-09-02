%% this is a basic screening script for data collected using the
%% StimulusPresentation BCI2000 Application module.
%
% Changelog:
%  23AUG2012 - JDW - Originally Written
%
% processing steps are as follows:
%  (1) collect appropriate information necessary to run
%        filename, analysis type
%  (2) load data and montage (if exists) in to memory
%  (3) identify response epochs
%        based on glove motion
%        audio responses
%        based on stimulus codes
%  (4) preprocess data
%        re-reference
%        filter
%        extract band powers
%  (5) determine mean powers during rest and activity epochs
%  (6) perform epoch-based statistical analyses
%  (7) generate plots
%  (8) select significant electrodes and generate T/F plots

% TODO account for bad channels
warning('this script still doesn''t acount for bad channels');
warning('this script cannot handle glove or audio locking');

%% collect appropriate information necessary to run
% filename to process
filepath = promptForBCI2000Recording;
subjid = extractSubjid(filepath);

aggregate = input('aggregate all stimuluscodes (e.g. speech tasks) - y/[n]: ','s');

if strcmpi(aggregate,'y')
    aggregate = true;
else
    aggregate = false;
end

restCode = input('rest StimulusCode (usually zero, unless finger twister): ');

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


%% identify response epochs
% response epochs are not guaranteed to be the same length

identifier = input('how are epochs identified (1) cyber glove, (2) audio responses, [3] stimulus code: ');

if (aggregate == true)
    % in this case we're re-coding the stimulus code to be zero during rest
    % and 1 at all other times
    stimCode = zeros(size(sta.StimulusCode));
    stimCode(double(sta.StimulusCode) ~= restCode) = 1;
    
    rest = 0;
    activities = 1;
else
    % in this case we're maintaining a list of all activity stimulus codes
    % and the rest stimulus code
    
    % for example, in finger twister, rest will still be a stimulus code of
    % 1, and activity will be all remaining stimulus codes (this will
    % unfortunately include stimcode = 0.
    stimCode = double(sta.StimulusCode);
    rest = restCode;
    activities = unique(stimCode);
    activities(activities == rest) = [];
end

switch (identifier)
    case 1
        error('cyber glove not implemented');
        responseCode = extractCyberGloveResponses(sta, stimCode, rest);
    case 2
        error('audio not implemented, get code from kurt...');
        responseCode = extractAudioResponses(sta, stimCode, rest);
    case 3
        responseDelay = input('how many milliseconds is the average response delay: ');
        responseDelayInSamples = round(responseDelay/1000*par.SamplingRate.NumericValue);
        responseCode = zeros(size(stimCode));
        responseCode((1+responseDelayInSamples):end) = stimCode(1:(end-responseDelayInSamples));
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


%% determine mean powers during rest and activity epochs

fprintf('performing analyses\n');
[restStarts, restStops] = getEpochs(responseCode, rest, false);

restHGs = zeros(length(restStarts), numChans);
restBetas = zeros(length(restStarts), numChans);

for n = 1:length(restStarts)
    restHGs(n, :) = mean(logHGPower(restStarts(n):restStops(n), :), 1);
    restBetas(n, :) = mean(logBetaPower(restStarts(n):restStops(n), :), 1);
end

actHGs = cell(length(activities), 1);
actBetas = cell(length(activities), 1);

windows = cell(length(activities), 1);
ts = cell(length(activities), 1);

for activityIdx = 1:length(activities)
    activity = activities(activityIdx);
    
    [activityStarts, activityStops] = getEpochs(responseCode, activity, false);
    
    activityLength = round(mean(activityStops-activityStarts));
    restLength = round(mean(restStops-restStarts));
    isValidWindow = ((activityStarts - restLength) > 0) & ((activityStarts + activityLength) <= size(sig,1));
    
    activityHGs{activityIdx} = zeros(length(activityStarts), numChans);
    activityBetas{activityIdx} = zeros(length(activityStarts), numChans);
    windows{activityIdx} = zeros(restLength+activityLength, numChans, sum(isValidWindow));

    ts{activityIdx} = (-restLength:(activityLength-1)) / fs;
    
    for n = 1:length(activityStarts)
        activityHGs{activityIdx}(n, :) = mean(logHGPower(activityStarts(n):activityStops(n), :), 1);
        activityBetas{activityIdx}(n, :) = mean(logBetaPower(activityStarts(n):activityStops(n), :), 1);
        
        if (isValidWindow(n))
            windows{activityIdx}(:, :, n) = sig((activityStarts(n)-restLength):(activityStarts(n)+activityLength-1), :);
        end
    end
end

%% perform epoch-based statistical analyses

ptarg = 0.05 / numChans;

HGSigs = zeros(length(activities), numChans);% == 1; % force boolean type
HGRSAs = zeros(length(activities), numChans);

BetaSigs = zeros(length(activities), numChans);% == 1; % force boolean type
BetaRSAs = zeros(length(activities), numChans);

for activityIdx = 1:length(activities)
    tempHGs = activityHGs{activityIdx};
    tempBetas = activityBetas{activityIdx};
        
    HGSigs(activityIdx,:) = ttest2(restHGs, tempHGs, ptarg, 'r', 'unequal', 1);
    BetaSigs(activityIdx,:) = ttest2(restBetas, tempBetas, ptarg, 'r', 'unequal', 1);
    
    HGRSAs(activityIdx,:) = signedSquaredXCorrValue(tempHGs, restHGs, 1);
    BetaRSAs(activityIdx,:) = signedSquaredXCorrValue(tempBetas, restBetas, 1);
end

if (sum(sum(isnan(HGSigs))) || sum(sum(isnan(BetaSigs))))
    warning('forcing NaNs to zero');
    HGSigs (isnan(HGSigs)) = 0;
    BetaSigs (isnan(BetaSigs)) = 0;
end

HGSigs = HGSigs == 1; % make boolean
BetaSigs = BetaSigs == 1; % make boolean

%% do plots

% first make a combined line plots for all rsas
colors = 'rgbcmyk';
chans = 1:numChans;

if (aggregate == true)
    
    %HG figure
    figure
    plot(chans, HGRSAs);
    hold on;
    plot(chans(HGSigs), HGRSAs(HGSigs), '*');
    
    xlabel('channel number');
    ylabel('R^2');
    title('Aggregated HG Response');
    legend('aggregate activity');

    % Beta
    figure;
    plot(chans, BetaRSAs);
    hold on;
    plot(chans(BetaSigs), BetaRSAs(BetaSigs), '*');
    
    xlabel('channel number');
    ylabel('R^2');
    title('Aggregated Beta Response');
    legend('aggregate activity');

else
    legendEntries = {};
    
    % HG figure
    figure;
    for activityIdx = 1:length(activities)
        h(activityIdx) = plot(chans, HGRSAs(activityIdx,:), colors(activityIdx));
        hold on;
        plot(chans(HGSigs(activityIdx,:)), HGRSAs(activityIdx, HGSigs(activityIdx,:)), [colors(activityIdx) '*']);

        
        activity = activities(activityIdx);
        if (activity == 0)
            legendEntries{end+1} = 'null';
        else
            legendEntries{end+1} = par.Stimuli.Value{1, activity};
        end
    end    
    xlabel('channel number');
    ylabel('R^2');
    title('HG Response');    
    legend(h, legendEntries);
    
    % Beta figure
    clear h;
    
    figure;
    for activityIdx = 1:length(activities)
        h(activityIdx) = plot(chans, BetaRSAs(activityIdx,:), colors(activityIdx));
        hold on;
        plot(chans(BetaSigs(activityIdx,:)), BetaRSAs(activityIdx, BetaSigs(activityIdx,:)), [colors(activityIdx) '*']);
        
        activity = activities(activityIdx);
    end        
    xlabel('channel number');
    ylabel('R^2');
    title('Beta Response');    
    legend(h, legendEntries);
end

% do the cortical plots
if (isfield(Montage, 'Default') == false || Montage.Default == false) % actually have a montage, do the cortical plots
    if (aggregate == true)
        figure;
        PlotDots(subjid, Montage.MontageTokenized, HGRSAs(1, :), 'both', [-1 1], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        title('HG Response to aggregated stimuli');
        colorbar;

        figure;
        PlotDots(subjid, Montage.MontageTokenized, BetaRSAs(1, :), 'both', [-1 1], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        title('Beta Response to aggregated stimuli');
        colorbar;
    else    
        for activityIdx = 1:length(activities)
            figure;
            PlotDots(subjid, Montage.MontageTokenized, HGRSAs(activityIdx, :), 'both', [-1 1], 20, 'recon_colormap');
            load('recon_colormap');
            colormap(cm);
            title(sprintf(' HG Response %s', legendEntries{activityIdx}));
            colorbar;

            figure;
            PlotDots(subjid, Montage.MontageTokenized, BetaRSAs(activityIdx, :), 'both', [-1 1], 20, 'recon_colormap');
            load('recon_colormap');
            colormap(cm);
            title(sprintf(' Beta Response %s', legendEntries{activityIdx}));
            colorbar;
        end 
    end
end


%% do time frequency plots for all electrodes that have significant
%% interactions

doTFA = input('do time frequency analyses [y]/n: ', 's');
if (strcmpi(doTFA, 'n'))
    return; % early return
end
 
trodeList = input ('list the electrodes to be analyzed in matlab vector format.  Leave blank if you want to analyze electrodes with significant RSA values: ', 's');
% find electrodes of interest
if (isempty(trodeList) == false)
    eval(sprintf('interesting = %s', trodeList));
else
    interesting = find(sum(HGSigs,1) > 0 | sum(BetaSigs,1) > 0);
end

fw = [1:3:200];

% we're making a plot for each electrode for each activity
% and grouping the plots by activity (all electrodes in a figure)
for activityIdx = 1:length(activities)
    figure;
    wins = windows{activityIdx}(:,interesting,:);
    t = ts{activityIdx};
    
    obsCount = size(wins, 1);
    dim = ceil(sqrt(length(interesting)));

    if (obsCount > 0) % means there's one or more observation of this activity
        for chanIdx = 1:length(interesting)
            subplot(dim,dim,chanIdx);
            
            [C, ~, ~, ~] = time_frequency_wavelet(squeeze(wins(:,chanIdx,:)), fw, fs, 1, 1, 'CPUtest');
            normC=normalize_plv(C',C(t>min(t)+0.2*restLength/fs & t<-0.2*restLength/fs,:)');
            
            

            imagesc(t,fw,normC);
            axis xy;
            set_colormap_threshold(gcf, [-1 1], [-7 7], [1 1 1]);        
            title(trodeNameFromMontage(interesting(chanIdx),Montage)); 
        end
    end
    maximize;
    if (aggregate)
        mtit('aggregate', 'xoff', 0, 'yoff', 0.05);
    else
        mtit(legendEntries{activityIdx}, 'xoff', 0, 'yoff', 0.05);
    end
end
    





