file = 'C:\Research\Data\Patients\cde503\d6\cde503_introspection001\cde503_introspectionS001R01.dat';

[sig states parms] = load_bcidat(file);
sig(1:10450,:) = [];
photoCode = double(sig(:,17));

montageFile = [file(1:find(file=='.',1,'last')-1) '_montage.mat'];

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

sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);

%%%%% Band pass for chi range and get power
fprintf('Band passing\n');
bpSig = BandPassFilter(sig, [75 200], params.SamplingRate);
sigAmp = abs(hilbert(bpSig));
lSigAmp = log(sigAmp);
sigPower = sigAmp.^2;

gridChans = [1:16 18:33 35:50];
stripChans = [52:67];

flashAt = (find(photoCode>0));

flashAt([45 46 47]) = []; % get rid of epoch that only registered 3 flashes
epochs = vec2mat(flashAt, 4);
epochs(1:end-1,5) = epochs(2:end,1)-1;
% flashLabel = zeros(size(flashAt,1));

idx = 0;
periodLabel = 0;
for i=1:length(flashAt)-1
    idx = idx + 1;
    
    periodLabel = mod(periodLabel,4);
    flashLabel(idx) = periodLabel;
    val = flashAt(i+1)-flashAt(i);
    fprintf('Flash %3i - %f ',idx,val ); 

    if(periodLabel == 0)
        fprintf(' TRIAL START ');
    end
    
    fprintf(' =%i= ', flashLabel(idx));
    
    if(val < 1200*(1.05) && val > 1200*(0.95))
        fprintf ('-READY or PLUS');
    end
    
    fprintf('\n');
    periodLabel = periodLabel + 1;
end


epochs(:,6) = [2000 3000 4000 6000 4000 3000 6000 2000 6000 2000 4000 6000 2000 3000 4000 3000 6000 4000 2000 4000 6000 3000 2000 2000 6000 4000 3000 4000 2000 3000 6000 2000 3000 4000 6000 4000 6000 2000 3000 3000 2000 4000 6000 2000 3000 6000 4000];

epochs(end,:) = []; % get rid of the overhanging one

meanPower = zeros(46,64,4);

epochIdx = 1;
for epoch = epochs'
    recChanIdx = 1;
    for chan = [gridChans stripChans]
        meanPower(epochIdx,recChanIdx,1) = mean(lSigAmp(epoch(1):epoch(2),chan));
        meanPower(epochIdx,recChanIdx,2) = mean(lSigAmp(epoch(2):epoch(3),chan));
        meanPower(epochIdx,recChanIdx,3) = mean(lSigAmp(epoch(3):epoch(4),chan));
        meanPower(epochIdx,recChanIdx,4) = mean(lSigAmp(epoch(4):epoch(5),chan));
        recChanIdx = recChanIdx + 1;
    end
    epochIdx = epochIdx + 1;
end
%%
colors = 'krgb';
figure
for recChan =1:64
    subplot(8,8,recChan);
    for period =1:4 
        plot((period-1)*46 + [1:46],exp(meanPower(:,recChan,period)),[colors(period) '.']);
        hold on;
    end
end
DensePlot(8,8);

%%

comps = [2 1; 3 1; 4 1; 3 2; 4 2; 4 3];

rsaVals = zeros(64,6);
rsaIndex = 1;
for comp = comps'
    
    actPeriods = meanPower(:,:,comp(1));
    restPeriods = meanPower(:,:,comp(2));

    % note, this RSA calc should probably be its own function
    numerator = ((mean(actPeriods,1)-mean(restPeriods,1)).^3);
    dena = abs(mean(actPeriods,1)-mean(restPeriods,1));
    denb = var([actPeriods;restPeriods],1);
    num2 = (size(actPeriods,1)*size(restPeriods,1));
    den2 = size([actPeriods;restPeriods],1);

    rsaVals(:,rsaIndex)=numerator./(dena.*denb).*num2./den2.^2;
    rsaIndex = rsaIndex + 1;
end

%%
for i=1:6
    figure;
    condition = i;
    weights = rsaVals(:,condition);
    weights = [weights(1:16);0;weights(17:32);0;weights(33:48);0;weights(49:64);0];
    ctmr_gauss_plot(cortex,Montage.MontageTrodes,weights,'r', [-1 1]); 
    switch (condition)
        case 1
            title('Ready vs ITI');
        case 2
            title('Cross vs ITI');
        case 3
            title('Intro vs ITI');
        case 4
            title('Cross vs Ready');
        case 5
            title('Intro vs Ready');
        case 6
            title('Intro vs Cross');
    end
    view(-10,0);
    light('position',[-2 0 0]);
end