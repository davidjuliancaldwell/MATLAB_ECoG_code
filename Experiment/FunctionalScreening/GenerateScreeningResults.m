%%%% OPTIONS

delayEpochBy = 300; % Samples to shift the epoch by to account for reaction time
dataDir = myGetenv('subject_dir');
% dataDir = 'd:\research\subjects\';

fprintf('Segmentation based on epoch.  Epochs elayed by %i samples\n\n', delayEpochBy);


%% Determine experimental parameters - is it nouns?  what is the rest code?
isNouns = input('is this Noun/Verbs (aggregate all stimuluscodes?) - y/[n]:','s');

if strcmpi(isNouns,'y')
    isNouns = 'y';
    restCode = 0;
else
    isNouns = 'n';
    restCode = input('rest StimulusCode (usually zero, unless finger flex [use 1]) - ');
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

% slashcount = length(strfind(dataDir, '\'));
% slashies = strfind(PathName,'\');
% subjID = PathName(slashies(slashcount)+1:slashies(slashcount+1)-1);

subjID = extractSubjid(PathName);
fprintf('script is guessing that subj_id = %s\n', subjID);


%%%%% load the file
fprintf('Loading file\n');
file.name = [PathName FileNames];

if strcmp(file.name(end-2:end),'mat') == 1
    %Assume we're trying to load the clinical data
    bciFile = [file.name(1:find(file.name=='_',1,'last')-1) '.dat'];
    [~, ~, parms] = load_bcidat(bciFile);
    load(file.name);
    sig = signals;
%     sig = resample(double(sig),6,10);
%     montageFile = [file.name(1:find(bciFile=='.',1,'last')-1) '_montage.mat'];
    montageFile = strrep(file.name, '.mat', '_montage.mat');
    states.StimulusCode = stimulusCode;
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

% numchans = sum(Montage.Montage);
% sig = sig(:,1:numchans);
% 
% parms.SamplingRate.NumericValue = fs;
% Montage.BadChannels = [];

% states.StimulusCode = double(states.TargetCode) .* double(states.Feedback);
% params.Stimuli = {'up', 'down'};

% states.StimulusCode = respCode;
% 
% for c = 1:length(respCode);
%     if(respCode(c)==1)
%         states.StimulusCode(c-600:c+600) = 1;
%     end
% end

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

    elcount = max(cumsum(Montage.Montage));
    gmontage = repmat(16, [1 floor(elcount/16)]);
    if (mod(elcount, 16) ~= 0)
        gmontage = [gmontage mod(elcount, 16)];
    end
    
    sig = ReferenceCAR(gmontage, Montage.BadChannels, sig);
    
end

%%%%% Band pass for chi range and get power
fprintf('Band passing\n');
% bpSig = BandPassFilter(sig, [75 200], params.SamplingRate);
% bpSig = BandPassFilter(sig, [75 200], params.SamplingRate, 2);
bpSig = BandPassFilter(sig, [75 200], params.SamplingRate, 2);
sigAmp = abs(hilbert(bpSig));
sigPower = sigAmp.^2;

%%%%% Set up epochs 
fprintf('Setting up epochs\n');
epochs = ones(length(find(diff(states.StimulusCode)~= 0)),1);
epochs(:,1) = cumsum(epochs(:,1));
newEpochAt = find(diff(states.StimulusCode) ~= 0);
epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.StimulusCode)]];
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
switch isNouns
    case 'n'
        targetCodes = sort(unique(states.StimulusCode));
        numTargetCodes = length(targetCodes);

        rsaVals = zeros(size(sigPower,2),length(nonzeros(targetCodes)));
        rsaSigs = zeros(size(sigPower,2),length(nonzeros(targetCodes)));
        
        rsaIndex = 1;
        for targetCode = nonzeros(targetCodes)'


            actPeriods = sumPower(epochs(:,4)==targetCode,:);
            restPeriods = sumPower(epochs(:,4)==restCode,:);
            
            if (size(actPeriods,1) > 0 && size(restPeriods,1) > 0)
                [rsaVals(:,rsaIndex), rsaSigs(:,rsaIndex)] = signedSquaredXCorrValue(actPeriods,restPeriods,1);

%                 for c = 1:size(actPeriods,2)
%                     rsaSigs(c,rsaIndex) = ranksum(actPeriods(:,c), restPeriods(:,c));
%                 end            
            else
                rsaVals(:,rsaIndex) = 0;
                rsaSigs(:,rsaIndex) = 0;
            end
            
            rsaIndex = rsaIndex + 1;
        end
    case 'y'
        % Do RSA for all activations vs rest

        rsaVals = zeros(size(sigPower,2),1);
        rsaSigs = zeros(size(sigPower,2),1);
        
        actPeriods = sumPower(epochs(:,4)~=restCode,:);
        restPeriods = sumPower(epochs(:,4)==restCode,:);

        [rsaVals(:), rsaSigs(:)] = signedSquaredXCorrValue(actPeriods, restPeriods, 1);
        
%         for c = 1:size(actPeriods,2)
%             rsaSigs(c) = ranksum(actPeriods(:,c), restPeriods(:,c));
%         end                    
end


% Get rid of bad channels
rsaVals(Montage.BadChannels,:) = 0;
rsaSigs(Montage.BadChannels,:) = 0;

%%
%%%%% Display the results individually
fprintf('Plotting RSA values\n');

switch isNouns
    case 'n'
        %%%%% Plot each individual code
        for targetCode = nonzeros(targetCodes)'

            if (size(params.Stimuli, 2) >= targetCode)
                stimuli = params.Stimuli{1,targetCode};

                figure;

                plot(rsaVals(:,targetCode));
                hold on;
                sigs = rsaSigs(:,targetCode);
                
                plot(find(sigs == 1), rsaVals(sigs == 1, targetCode), '*');

                title(sprintf('%s - Target code %2i', stimuli, targetCode));
                legend(sprintf('%s',stimuli));
                set(gca,'xlim',[1 size(rsaVals,1)]);
            end
        end
        
        %%%%% Overlay all
        idxs = intersect(nonzeros(targetCodes), 1:size(params.Stimuli,2));
%         stimuli = params.Stimuli(1,nonzeros(targetCodes));
        stimuli = params.Stimuli(1,idxs);

        figure;

        plot(rsaVals);
        
        title(sprintf('All activity'));
        legend(stimuli);
        set(gca,'xlim',[1 size(rsaVals,1)]);
    case 'y'
        figure;

        plot(rsaVals(:,end));
        hold on;
        sigs = rsaSigs;
        plot(find(sigs == 1), rsaVals(sigs == 1), '*');        
            
        title(sprintf('All conditions vs Rest condition (TargetCode == %i)', restCode));
        legend(sprintf('All conditions'));
        axis tight;
end

%%
%%%%% Cortical plots
% fprintf('ABORTING CORTICAL PLOTS - Delete this line to generate them \n'); return;
fprintf('Generating cortical plots\n');

% Get rid of bad channels
rsaVals(Montage.BadChannels,:) = NaN;
rsaSigs(Montage.BadChannels,:) = NaN;

% try
%     load([dataDir '\' subjID '\surf\' subjID '_cortex_
%     load([dataDir '\' subjID '\surf\' subjID '_cortex.mat']);
% catch
%     error(sprintf('Can''t find patient cortical surface!  Make sure it''s in the %PATIENTDIR%/surf directory, named [pid]_cortex.mat\n'));
% end

screenedRsaVals = rsaVals;
% screenedRsaVals(rsaSigs == 0) = NaN; % need mult comps? bonf corr?

labels = zeros(size(sig,2),1);

for c = 1:size(sig,2)
    temp = trodeNameFromMontage(c, Montage);
    
    labels(c) = str2double(temp(strfind(temp,'(')+1:strfind(temp,')')-1));
end

switch isNouns
    case 'n'
        for targetCode = nonzeros(targetCodes)'

            if (size(params.Stimuli, 2) >= targetCode) && targetCode ~= restCode
                stimuli = params.Stimuli{1,targetCode};

                figure;

                lims = abs(max(screenedRsaVals(:,targetCode)));
                lims = [-lims lims];
                PlotDotsDirect(subjID, Montage.MontageTrodes, screenedRsaVals(:,targetCode), 'r', lims, 20, 'recon_colormap');
                load('recon_colormap');
                colormap(cm);
                colorbar;
    %             ctmr_dot_plot(cortex, Montage.MontageTrodes, screenedRsaVals(:,targetCode), 'r', [-1 1], 20);
    %             ctmr_dot_plot(cortex, Montage.MontageTrodes, rsaVals(:,targetCode), 'r', [-1 1], 20);
    %             ctmr_gauss_plot(cortex,Montage.MontageTrodes,rsaVals(:,targetCode),'r')
                title(strrep(sprintf('%s - Target code %2i', stimuli, targetCode), '_', '\_'));
            end
        end
    case 'y'
        figure;
        lims = abs(max(screenedRsaVals));
        lims = [-lims lims];

        PlotDotsDirect(subjID, Montage.MontageTrodes, screenedRsaVals, 'r', lims, 20, 'recon_colormap', labels);
%         load('recon_colormap');
        load('recon_colormap');
        colormap(cm);
        colorbar;
%         ctmr_dot_plot(cortex, Montage.MontageTrodes, screenedRsaVals, 'l', [-1 1], 20);
%         ctmr_gauss_plot(cortex,Montage.MontageTrodes,rsaVals,'r')
        title(sprintf('All conditions vs Rest condition (TargetCode == %i)', restCode));
end