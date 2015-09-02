%%%% OPTIONS

delayEpochBy = 0; % Samples to shift the epoch by to account for reaction time
dataDir = [myGetenv('subject_dir') '\'];


fileName = [dataDir genPID('deca10') '\d3\38e116_sensorystim_L001\38e116_sensorystim_LS001R01.dat'];

%% Determine experimental parameters - is it nouns?  what is the rest code?

slashies = strfind(fileName,'\');
subjID = fileName(slashies(4)+1:slashies(5)-1);


%%%%% load the file
fprintf('Loading file\n');


[sig states parms] = load_bcidat(fileName);
montageFile = [fileName(1:find(fileName=='.',1,'last')-1) '_montage.mat'];

try
    load(montageFile);
catch
    error('Couldn''t load montage.  Make sure you have run ScreenBadChannels.');
end

% cleaning states/params
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
clear parms

%%%%% Clean signal 
fprintf('Cleaning signal\n');
sig = double(sig);

sig = NotchFilter(sig, [60 120 180], params.SamplingRate);
if mod(params.SamplingRate,1000) == 0
    fprintf('Neuroscan detected\n');
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
else
    fprintf('Guger detected! Re-referencing each amplifier bank together...\n'); 
    sig = ReferenceCAR([16 16 16 16], Montage.BadChannels, sig);
end

% %%%%% Band pass for chi range and get power
fprintf('Band passing\n');
bpSig = BandPassFilter(sig, [75 150], params.SamplingRate);
sigAmp = abs(hilbert(bpSig));
sigPower = sigAmp.^2;
smoothLogPower = GaussianSmooth(log(sigPower),500);
zScoreSmoothLogPower = (smoothLogPower - repmat(mean(smoothLogPower(1:3600,:),1),size(smoothLogPower,1),1)) ./ repmat(std(smoothLogPower(1:3600,:),1),size(smoothLogPower,1),1);
zSmoothAmp = exp(zScoreSmoothLogPower);
% smoothSigAmp = GaussianSmooth(sigPower,500);
% zSmoothAmp = (smoothSigAmp - repmat(mean(smoothSigAmp(1:3600,:),1),size(smoothSigAmp,1),1)) ./ repmat(std(smoothSigAmp(1:3600,:),1),size(smoothSigAmp,1),1);


%%%%% Set up epochs 
fprintf('Setting up epochs\n');
epochs = ones(length(find(diff(states.StimulusCode)~= 0)),1);
epochs(:,1) = cumsum(epochs(:,1));
newEpochAt = find(diff(states.StimulusCode) ~= 0);
epochs(:,2:3) = [newEpochAt+1 [newEpochAt(2:end);length(states.Running)]];
epochs(:,4) = states.StimulusCode(epochs(:,3));

% Note: now epochs(1) = epoch number, epoch(2):epoch(3) is the epoch
% duration, and epoch(4) = StimulusCode

% Get rid of last two epochs, they looked bad
epochs(end-1:end,:) = [];

%%
%%%% Get sum power for each epoch

fprintf('Summing power over epochs\n');

epochPowers = zeros(unique(epochs(:,3)-epochs(:,2))+1+600,size(sig,2),size(epochs,1));

for epoch = epochs'
    % select epoch range and apply delay if needed
    range = epoch(2):epoch(3)+600;
    range = range + delayEpochBy;
    

    epochPowers(:,:,epoch(1)) = zSmoothAmp(range,:);
end

meanEP = zeros(size(epochPowers,1),size(epochPowers,2),6);

for i=1:6
    meanEP(:,:,i) = mean(epochPowers(:,:,epochs(:,4)==i),3);
end

% colors = {
%     [.8 .8 .8],[0 0 0];
%     [1 .6 .6],[1 0 0];
%     [.6 1 .6],[0 1 0];
%     [.6 .6 1],[0 0 1];
%     [1 .6 1], [1 0 1];
%     [1 1 .6], [1 1 0];
%     [.6 1 1], [0 1 1];
%     [.6 .8 1], [0 0.5 1];
%     [.6 1 .8], [0 1 0.5];
%     [1 .8 .6], [1 0.5 0];
%     [1 .6 .8], [1 0 0.5];
%     };

colors = {
    [.8 .8 .8],[1 .6 0];
    [1 .6 .6],[0 0 1];
    [.6 1 .6],[0 1 0];
    [.6 .6 1],[1 1 0];
    [1 .6 1], [0 1 1];
    [1 1 .6], [1 0 1];
    [], [1 0 0];
%     [], [1 .5 0];
%     [], [.5 1 0];
%     [], [.5 0 1];
%     [], [0 1 .5];
[],[0 0 0];
[],[0 0 0];
[],[0 0 0];
[],[0 0 0];
    };

for i=2:6  
    subplot(8,8,i);
    hold on;
%     for i=1:5
%         plot(squeeze(epochPowers(:,chan,epochs(:,4)==i)),'color',colors{i,1});
%     end
    idx = 1;
    for chan=[17 18 25 27 34 41 36 47 22 28 51]
              
        plot(meanEP(:,chan,i),'color',colors{idx,2},'linewidth',2);
        idx = idx + 1;
    end
    axis tight;
    set(gca,'ylim',[-2 80]);
end

DensePlot(3,2);

%% figure

interestingChannels = [17,18,25,26,27,28,33,34,41,42,43];

for stimCode = 2:6;
    subplot(5,1,stimCode-1);
    hold on;
    idx = 1;
    imagesc(meanEP(:,interestingChannels,stimCode)');
%     for ic = interestingChannels
%         plot(meanEP(:,ic,stimCode),'color',colors{idx,1});
%         idx = idx + 1;
%     end
    axis tight;
%     set(gca,'ylim',[-2 10]);
    set(gca,'ytick', [1:11]); 
    set(gca,'yticklabel',['17';'18';'25';'26';'27';'28';'33';'34';'41';'42';'43']);
end
% legend('17','18','25','26','27','28','33','34','41','42','43');

% DensePlot(5,1);

%%

f = 1;
for epoch=[epochs(epochs(:,4)==2,:)]'
    subplot(5,2,f);
%     figure
    
    epoch(1);
    
    idx = 1;
    for chan=[17 18 25 27 34 41]
        hold on;
        plot(epochPowers(:,chan,epoch(1)),'color',colors{idx,2});
        idx = idx + 1;
    end
    axis tight;
    set(gca,'ylim',[-2 100]);
    f = f + 1;
end
DensePlot(5,2);

%%



for i=2:6; 
    subplot(3,2,i); 
    imagesc(meanEP(:,:,i)'); 
    set(gca,'clim',[0 80]); 
end;