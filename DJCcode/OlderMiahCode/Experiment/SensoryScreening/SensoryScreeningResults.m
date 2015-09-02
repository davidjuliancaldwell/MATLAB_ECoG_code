%%
% datapath = 'D:\Data\Patients\ebffea\d3\ebffea_finger_tip_test001\ebffea_finger_tip_testS001R02.dat';
% [sig, sta, par] = load_bcidat(datapath);

%%
%%%% OPTIONS

delayEpochBy = 0; % Samples to shift the epoch by to account for reaction time
dataDir = 'D:\data\patients\';

fprintf('Segmentation based on epoch.  Epochs elayed by %i samples\n\n', delayEpochBy);


%% Determine experimental parameters - what type of analysis is it?
screenType = input('is this _f_ingertips or _t_hreshold - [f]/t:','s');

restCode = 0;

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

slashies = strfind(PathName,'\');
subjID = PathName(slashies(3)+1:slashies(4)-1);
fprintf('subject id is %s\n', subjID);

%%%%% load the file
fprintf('Loading file\n');
file.name = [PathName FileNames];

if strcmp(file.name(end-2:end),'mat') == 1
    %Assume we're trying to load the clinical data
    bciFile = [file.name(1:find(file.name=='_',1,'last')-1) '.dat'];
    [sig states parms] = load_bcidat(bciFile);
    sig = double(sig);
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
switch screenType
    case 'f'
        finger1 = [1 5 6 7 11 12 14];
        finger2 = [2 5 8 9 11 13 14];
        finger3 = [3 6 8 10 11 12 13 14];
        finger4 = [4 7 9 10 12 13 14];
        
        % TODO compile stim codes
        targetCodes = sort(unique(states.StimulusCode));
        numTargetCodes = length(targetCodes);

        rsaVals = zeros(size(sigPower,2),length(nonzeros(targetCodes)));

        rsaIndex = 1;
        for targetCode = nonzeros(targetCodes)'


            actPeriods = sumPower(epochs(:,4)==targetCode,:);
            restPeriods = sumPower(epochs(:,4)==restCode,:);

            % note, this RSA calc should probably be its own function
            numerator = ((mean(actPeriods,1)-mean(restPeriods,1)).^3);
            dena = abs(mean(actPeriods,1)-mean(restPeriods,1));
            denb = var([actPeriods;restPeriods],1);
            num2 = (size(actPeriods,1)*size(restPeriods,1));
            den2 = size([actPeriods;restPeriods],1);

            rsaVals(:,rsaIndex)=numerator./(dena.*denb).*num2./den2.^2;
            rsaIndex = rsaIndex + 1;
        end
    case 't'
        % Do RSA for all activations vs rest

        rsaVals = zeros(size(sigPower,2),1);
        
        actPeriods = sumPower(epochs(:,4)~=restCode,:);
        restPeriods = sumPower(epochs(:,4)==restCode,:);

        % note, this RSA calc should probably be its own function
        numerator = ((mean(actPeriods,1)-mean(restPeriods,1)).^3);
        dena = abs(mean(actPeriods,1)-mean(restPeriods,1));
        denb = var([actPeriods;restPeriods],1);
        num2 = (size(actPeriods,1)*size(restPeriods,1));
        den2 = size([actPeriods;restPeriods],1);

        rsaVals(:,1)=numerator./(dena.*denb).*num2./den2.^2;        
end


% Get rid of bad channels
rsaVals(Montage.BadChannels,:) = 0;
%%
%%%%% Display the results individually
fprintf('Plotting RSA values\n');
switch screenType
    case 'f'
        %%%%% Plot each individual code
        for targetCode = nonzeros(targetCodes)'

            stimuli = params.Stimuli{1,targetCode};

            figure;

            plot(rsaVals(:,targetCode));
            title(sprintf('Target code %2i', targetCode));
            legend(sprintf('%2i',targetCode));
            set(gca,'xlim',[1 size(rsaVals,1)]);
        end
        
        %%%%% Overlay all
%         stimuli = params.Stimuli(1,nonzeros(targetCodes));

        figure;

        plot(rsaVals);
        title(sprintf('All activity'));
        legend(num2str(targetCodes));
        set(gca,'xlim',[1 size(rsaVals,1)]);
    case 't'
        figure;

        plot(rsaVals(:,end));
        title(sprintf('Activity vs Rest condition (TargetCode == %i)', restCode));
        legend(sprintf('Activity'));
        axis tight;
end

%%
%%%%% Cortical plots
% fprintf('ABORTING CORTICAL PLOTS - Delete this line to generate them \n'); return;
fprintf('Generating cortical plots\n');
try
    load(['H:\Data\' subjID '\surf\' subjID '_cortex.mat']);
catch
    error(sprintf('Can''t find patient cortical surface!  Make sure it''s in the %PATIENTDIR%/surf directory, named [pid]_cortex.mat\n'));
end

switch screenType
    case 'f'
        for targetCode = nonzeros(targetCodes)'

            stimuli = params.Stimuli{1,targetCode};

            figure;

%             temp1 = doSwitch(Montage.MontageTrodes);
%             
%             fprintf('note, this script is currently configured to transpose the grid data along the axis from elec 1 to elec 64\n');
            
          ctmr_gauss_plot(cortex,Montage.MontageTrodes,rsaVals(:,targetCode),'l')
%             ctmr_gauss_plot(cortex,temp1,rsaVals(:,targetCode),'l')
            
            title(sprintf('%s - Target code %2i', stimuli, targetCode));
        end
    case 't'
        figure;

%         ctmr_gauss_plot(cortex,temp1,rsaVals,'l')
                  ctmr_gauss_plot(cortex,Montage.MontageTrodes,rsaVals,'r')
        title(sprintf('Activity'));
end