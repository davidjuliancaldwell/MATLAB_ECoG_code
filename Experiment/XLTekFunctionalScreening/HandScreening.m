clear variables;
subject = 'wn';
movementFirst = 0;
fractionAlong = 0.5;


eval(sprintf('load d:\\Research\\Data\\Carter\\%s\\%s_mat.mat', subject, subject));
setupEnvironment

%% Load the data
signal = double(EEG.data)';
signal(:,1) = [];
signal = signal(:,1:64);

% clean the ending zero'd values from the end of the file. It's a byproduct
% of the EDF files
 for i=length(signal):-1:1; 
     if length(unique(signal(i,:))) > 1; 
         signal(i+1:end,:) = [];
         break; 
     end; 
 end;
samplingRate = double(EEG.srate);

signal = NotchFilter(signal, [60 120 180], samplingRate);
if movementFirst == 1
    actPeriod = 1:floor(size(signal,1)*fractionAlong);
    restPeriod = floor(size(signal,1)*fractionAlong)+1:size(signal,1);
else
    restPeriod = 1:floor(size(signal,1)*fractionAlong);
    actPeriod = floor(size(signal,1)*fractionAlong)+1:size(signal,1);
end

%%
spectra = zeros(1001,64);

tic
for chan=1:64
    spectra(:,chan) = log(pwelch(signal(:,chan),2000,500, 2000, samplingRate, 'onesided'));
end

toc

figure; 
plot(spectra);

%% Remove DC offsets, then re-reference

signal = BandPassFilter(signal,[0.1 (samplingRate/2-1)], samplingRate,4);
signal = ReferenceCAR(64,8,signal);

bp = BandPassFilter(signal, [75 150], samplingRate, 4);
bp = abs(hilbert(bp));
bp = log(bp);
%%
windowLength = .5; % in seconds
windowOverlap = 0.2; % in seconds

windowLength = floor(windowLength * samplingRate);
windowSkip = windowLength - floor(windowOverlap * samplingRate);
numWindows = length(1:windowSkip:size(bp,1)-windowLength);

% Z-score log amplitude

zScore = (bp - repmat(mean(bp(restPeriod,:),1),size(bp,1),1)) ./ repmat(std(bp(restPeriod,:),1),size(bp,1),1);



% actWindows = 1:floor(numWindows/2);
% restWindows = ceil(numWindows/2):numWindows;

actWindows = 1:floor(numWindows * fractionAlong);
restWindows = ceil(numWindows * fractionAlong):numWindows;

if movementFirst == 0
    temp = actWindows;
    actWindows = restWindows;
    restWindows = temp;
end



%% 
figure;
meanAmp = zeros(numWindows,64);

for chan=1:64
    subplot(8,8,chan);

    

    idx = 1;
    for sampleIdx =1:windowSkip:size(bp,1)-windowLength
        meanAmp(idx,chan) = exp(mean(zScore(sampleIdx:(sampleIdx+windowLength-1),chan)));
        idx = idx + 1;
    end

    plot(actWindows,meanAmp(actWindows,chan),'r.');
    hold on;
    plot(restWindows,meanAmp(restWindows,chan),'b.');
    axis tight;
    set(gca,'ylim',[0 3]);
end
DensePlot(8,8);

%%
actPeriods = meanAmp(actWindows,:);
restPeriods = meanAmp(restWindows,:);

% note, this RSA calc should probably be its own function
numerator = ((mean(actPeriods,1)-mean(restPeriods,1)).^3);
dena = abs(mean(actPeriods,1)-mean(restPeriods,1));
denb = var([actPeriods;restPeriods],1);
num2 = (size(actPeriods,1)*size(restPeriods,1));
den2 = size([actPeriods;restPeriods],1);

rsaVals=numerator./(dena.*denb).*num2./den2.^2;

%% 
f = figure;

% [h p] = ttest2(meanAmp(actWindows,:),meanAmp(restWindows,:));
plot(rsaVals); axis tight;
ylabel('significance');
xlabel('channel');
title(sprintf('%s significance',subject));

saveFigure(f,sprintf('d:\\research\\output\\carter\\%s_significance.jpg', subject), 1);
close(f);
%%
f = figure;
imagesc(vec2mat(rsaVals,8,8));
set(gca,'clim',[-max(abs(rsaVals)) max(abs(rsaVals))]);
load loc_colormap
colormap(cm);
colorbar
title(sprintf('%s significance',subject));
set(gca,'xticklabel',{'57','58','59','60','61','62','63','64'})
set(gca,'yticklabel',{'1','9','17','25','33','41','49','57'})
xlabel('channel');
ylabel('channel');
saveFigure(f,sprintf('d:\\research\\output\\carter\\%s_grid.jpg', subject), 1);
close(f);

%%
% eval(sprintf('load C:\\Research\\Data\\Carter\\%s\\surf\\%s_cortex.mat', subject, subject));
% eval(sprintf('load C:\\Research\\Data\\Carter\\%s\\trodes.mat', subject));
% figure;
% ctmr_gauss_plot(cortex,SupPostGrid,rsaVals,'r');