%%%% OPTIONS

delayEpochBy = 0; % Samples to shift the epoch by to account for reaction time
dataDir = myGetenv('subject_dir');
% dataDir = 'd:\research\subjects\';

% fprintf('Segmentation based on epoch.  Epochs elayed by %i samples\n\n', delayEpochBy);


%% Determine experimental parameters - is it nouns?  what is the rest code?
% isNouns = input('is this Noun/Verbs (aggregate all stimuluscodes?) - y/[n]:','s');
% 
% if strcmpi(isNouns,'y')
%     isNouns = 'y';
%     restCode = 0;
% else
%     isNouns = 'n';
%     restCode = input('rest StimulusCode (usually zero, unless finger flex [use 1]) - ');
% end
isNouns = 'y';

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
%     bciFile = [file.name(1:find(file.name=='_',1,'last')-1) '.dat'];
%     [sig states parms] = load_bcidat(bciFile);
    load(file.name);
    montageFile = strrep(file.name, '.mat', '_montage.mat');
    states.StimulusCode = stimulusCode;
    params.SamplingRate = fs;
    sig = signals;
    
%     sig = resample(sig,6,10);
%     montageFile = [file.name(1:find(bciFile=='.',1,'last')-1) '_montage.mat'];
else
    [sig states parms] = load_bcidat(file.name);
    montageFile = [file.name(1:find(file.name=='.',1,'last')-1) '_montage.mat'];
end
try
    load(montageFile);
    if isfield(Montage, 'BadChannels') == false
        Montage.BadChannels = [];
    end
    
catch
    error('Couldn''t load montage.  Make sure you have run ScreenBadChannels.');
end
for field = fields(states)';
    states.(field{:}) = single(states.(field{:}));
end

numchans = sum(Montage.Montage);
sig = sig(:,1:numchans);

% states.StimulusCode = double(states.TargetCode) .* double(states.Feedback);
% params.Stimuli = {'up', 'down'};

% states.StimulusCode = respCode;
% 
% for c = 1:length(respCode);
%     if(respCode(c)==1)
%         states.StimulusCode(c-600:c+600) = 1;
%     end
% end

% flds = fieldnames(parms);
% for i=flds';
%     try
%         tempField = parms.(i{1});
%     %         fprintf('%s ',tempField.Type);
%         switch tempField.Type
%             case 'string'
%                 eval(sprintf('params.%s = tempField.Value;',i{1}));
%             case 'matrix'
%                 eval(sprintf('params.%s = tempField.Value;',i{1}));
%             otherwise
%                 numVal = double(tempField.NumericValue);
%                 eval(sprintf('params.%s = numVal;',i{1}));
%         end
%     catch
%         bad = cell2mat(i);
%         fprintf('  ignoring params.%s, not numerical\n', bad);
%     end
% end

%%%%% Clean signal 
fprintf('Cleaning signal\n');
sig = double(sig);

sig = NotchFilter(sig, [60 120], params.SamplingRate);
if mod(params.SamplingRate,1000) == 0
    fprintf('Neuroscan detected\n');
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
else
    fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
    
    sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, sig);
    
end

%%%%% Band pass for chi range and get power
fprintf('Band passing\n');
% bpSig = BandPassFilter(sig, [75 200], params.SamplingRate);
% bpSig = BandPassFilter(sig, [75 200], params.SamplingRate, 2);
bpSig = BandPassFilter(sig, [75 200], params.SamplingRate, 2);
sigAmp = abs(hilbert(bpSig));
sigPower = sigAmp.^2;
lSigPower = log(sigPower);
slSigPower = GaussianSmooth(lSigPower, 120);

[av, win, tav, twin] = triggeredAverage(diff(double(states.StimulusCode)), .5, 1, lSigPower, params.SamplingRate, params.SamplingRate*2);

%%
for c = 1:size(win,2)
    figure;
    t = (-fs):(fs*2);
    plot(t,av(:,c));
    title(num2str(c));
%     title(trodeNameFromMontage(c, Montage));
end

return;
