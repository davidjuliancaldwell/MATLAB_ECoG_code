%%%% OPTIONS



% fileName = 'C:\Research\Data\Patients\38e116\d1\38e116_6targ001\38e116_6targS001R03.dat';
fileName = 'C:\Research\Data\Patients\38e116\d2\38e116_6targ_im001\38e116_6targ_imS001R02.dat';
[sig states parms] = load_bcidat(fileName);
montageFile = [fileName(1:find(fileName=='.',1,'last')-1) '_montage.mat'];

load(montageFile);

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
logSigAmp = log(sigAmp);
zScored = (logSigAmp - repmat(mean(logSigAmp),size(logSigAmp,1),1)) ./ repmat(std(logSigAmp),size(logSigAmp,1),1);

controlChannel = params.TransmitChList(str2double(params.Classifier{1,1}));

%%%%% Set up epochs 
fprintf('Setting up epochs\n');
epochs = ones(length(find(diff(states.TargetCode)~= 0)),1);
epochs(:,1) = cumsum(epochs(:,1));
newEpochAt = find(diff(states.TargetCode) ~= 0);
epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];

activeRunAt = vec2mat(find(diff(states.Feedback) ~= 0),2);
araIdx = 1;
for i=1:2:length(epochs)

    
    epochs(i,4) = activeRunAt(araIdx,1);
    epochs(i,5) = activeRunAt(araIdx,2);
    araIdx = araIdx + 1;
end
epochs(:,6) = states.TargetCode(epochs(:,3));
epochs(:,7) = states.ResultCode(epochs(:,3));


% Note: now epochs(1) = epoch number, epoch(2):epoch(3) is the epoch
% duration, and epoch(4) = StimulusCode

%%
%%%%% Get sum power for each epoch
fprintf('Summing power over epochs\n');
sumPower = zeros(size(epochs,1), size(sig,2));
for epoch = epochs'
    % select epoch range and apply delay if needed
    switch epoch(6)
        case 0
            range = epoch(2):epoch(3);
        otherwise
            range = epoch(4):epoch(5);
    end
    
    % avoid any clipping at the end imposed by the delay
    range = range(range < size(sig,1)); 
    % Note: should use mean.  Can use sum, but only if epochs have same
    % lengths (most of the time they do)
%     sumPower(epoch(1),:) = sum(sigPower(range,:));
    sumEpoch(epoch(1),:) = mean(zScored(range,:));
end

%%%%% Calculate signed R2 for sum powers
fprintf('Calculate RSA\n');

targetCodes = sort(unique(states.TargetCode));
numTargetCodes = length(targetCodes);

rsaVals = zeros(size(logSigAmp,2),length(nonzeros(targetCodes)));

rsaIndex = 1;
for targetCode = nonzeros(targetCodes)'
    actPeriods = sumEpoch(epochs(:,6)==targetCode,:);
    restPeriods = sumEpoch(epochs(:,6)==0,:);

    % note, this RSA calc should probably be its own function
    numerator = ((mean(actPeriods,1)-mean(restPeriods,1)).^3);
    dena = abs(mean(actPeriods,1)-mean(restPeriods,1));
    denb = var([actPeriods;restPeriods],1);
    num2 = (size(actPeriods,1)*size(restPeriods,1));
    den2 = size([actPeriods;restPeriods],1);

    rsaVals(:,rsaIndex)=numerator./(dena.*denb).*num2./den2.^2;
    rsaIndex = rsaIndex + 1;
end

% Get rid of bad channels
rsaVals(Montage.BadChannels,:) = 0;
%%
f = figure;
plot(rsaVals);

f = figure;
hold on;
% colors = ['krgbcmy'];

colors = [...
    [0 0 0];...
    [1 0 0];...
    [0 1 0];...
    [0 0 1];...
    [1 0 .5];...
    [.3 .8 1];...
    [1 .5 0]];
numPlotted = 0;
for targetCode = unique(epochs(:,6))'
    tcSumEpoch = exp(sumEpoch(epochs(:,6)==targetCode, controlChannel));
    plot(numPlotted + [1:size(tcSumEpoch,1)], tcSumEpoch,'color',colors(targetCode+1,:),'marker','.','linestyle','none');
    numPlotted = numPlotted + size(tcSumEpoch,1);
end
