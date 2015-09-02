%%%% OPTIONS

delayEpochBy = 1200; % Samples to shift the epoch by to account for reaction time
dataDir = myGetenv('subject_dir');
% dataDir = 'd:\research\subjects\';

fprintf('Segmentation based on epoch.  Epochs elayed by %i samples\n\n', delayEpochBy);


restCodes = input('rest StimulusCodes:','s');
restCodes = str2mat(restCodes);

actCodes = input('DMN StimulusCodes:','s');
actCodes = str2mat(actCodes);
%% Determine experimental parameters - is it nouns?  what is the rest code?
hemi = input('Hemisphere [r/l]:','s');

if strcmpi(hemi,'l')
    hemi = 'lh';
else
    hemi = 'rh';
end

%%%%% Select which file we want to load for analysis
curPath = pwd;
try
    cd(dataDir);
    [FileNames,PathName,FilterIndex] = uigetfile('*.dat;*.mat','MultiSelect', 'off');
catch
    cd(curPath);
    return;
end
cd(curPath);

slashcount = length(strfind(dataDir, '\'));
slashies = strfind(PathName,'\');
subjID = PathName(slashies(slashcount)+1:slashies(slashcount+1)-1);

fprintf('script is guessing that subj_id = %s\n', subjID);


%%%%% load the file
fprintf('Loading file\n');
file.name = [PathName FileNames];

if strcmp(file.name(end-2:end),'mat') == 1
    %Assume we're trying to load the clinical data
    bciFile = [file.name(1:find(file.name=='_',1,'last')-1) '.dat'];
    [sig states parms] = load_bcidat(bciFile);
    load(file.name);
    sig = resample(sig,6,10);
    montageFile = [file.name(1:find(bciFile=='.',1,'last')-1) '_montage.mat'];
else
    [sig states parms] = load_bcidat(file.name);
    montageFile = [file.name(1:find(file.name=='.',1,'last')-1) '_montage.mat'];
end
try
    load(montageFile);
catch
    error('Couldn''t load montage.  Make sure you have run ScreenBadChannels.');
end
for field = fields(states)';
    states.(field{:}) = single(states.(field{:}));
end
flds = fieldnames(parms);
for i=flds';
    try
        tempField = parms.(i{1});
    %         fprintf('%s ',tempField.Type);
        switch tempField.Type
            case 'string'
                eval(sprintf('params.%s = tempField.Value;',i{1}));
            case 'matrix'
                eval(sprintf('params.%s = tempField.Value;',i{1}));
            otherwise
                numVal = double(tempField.NumericValue);
                eval(sprintf('params.%s = numVal;',i{1}));
        end
    catch
        bad = cell2mat(i);
        fprintf('  ignoring params.%s, not numerical\n', bad);
    end
end

%%%%% Clean signal 
fprintf('Cleaning signal\n');
sig = double(sig);

sig = NotchFilter(sig, [60 120], params.SamplingRate);
if mod(params.SamplingRate,1000) == 0
    fprintf('Neuroscan detected\n');
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
else
    fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
    sig = ReferenceCAR([16 16 16 16], Montage.BadChannels, sig);
end

%%%%% Band pass for chi range and get power
fprintf('Band passing\n');
bpSig = BandPassFilter(sig, [75 200], params.SamplingRate);
sigAmp = abs(hilbert(bpSig));
sigPower = sigAmp.^2;

%%%%% Set up epochs 
fprintf('Setting up epochs\n');
epochs = ones(length(find(diff(states.StimulusCode)~= 0)),1);
epochs(:,1) = cumsum(epochs(:,1));
newEpochAt = find(diff(states.StimulusCode) ~= 0);
epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];
epochs(:,4) = states.StimulusCode(epochs(:,3));

% Note: now epochs(1) = epoch number, epoch(2):epoch(3) is the epoch
% duration, and epoch(4) = StimulusCode

%%
%%%%% Get sum power for each epoch
fprintf('Summing power over epochs\n');
sumPower = zeros(size(epochs,1), size(sig,2));
for epoch = epochs'
    % select epoch range and apply delay if needed
    range = epoch(2):epoch(3);
    range = range + delayEpochBy;
    
    % avoid any clipping at the end imposed by the delay
    range = range(range < size(sig,1)); 
    % Note: should use mean.  Can use sum, but only if epochs have same
    % lengths (most of the time they do)
%     sumPower(epoch(1),:) = sum(sigPower(range,:));
    sumPower(epoch(1),:) = mean(sigPower(range,:));
end

%%%%% Calculate signed R2 for sum powers
fprintf('Calculate RSA\n');

rsaVals = zeros(size(sigPower,2),1);
rsaSigs = zeros(size(sigPower,2),1);

actPeriods = [];
for actCode = actCodes
    actPeriods = vertcat(actPeriods, sumPower(epochs(:,4)==str2double(actCode),:));
end

restPeriods = [];
for restCode = restCodes
    restPeriods = vertcat(restPeriods, sumPower(epochs(:,4)==str2double(restCode),:));
end

rsaVals(:) = signedSquaredXCorrValue(actPeriods,restPeriods,1);




% Get rid of bad channels
rsaVals(Montage.BadChannels,:) = 0;

figure;
plot(rsaVals);
%%
%%%%% Cortical plots
% fprintf('ABORTING CORTICAL PLOTS - Delete this line to generate them \n'); return;
fprintf('Generating cortical plots\n');
try
    load([dataDir '\' subjID '\surf\' subjID '_cortex_' hemi '_hires.mat']);
catch
    error(sprintf('Can''t find patient cortical surface!  Make sure it''s in the %%PATIENTDIR%%/surf directory, named [pid]_cortex.mat\n'));
end

screenedRsaVals = rsaVals;
ctmr_dot_plot(cortex, Montage.MontageTrodes, rsaVals, 'r', [-1 1], 20);