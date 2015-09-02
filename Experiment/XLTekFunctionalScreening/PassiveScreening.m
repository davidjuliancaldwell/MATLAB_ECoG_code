load('C:\Research\Data\Patients\80a4e3\file1.mat');offset = 32000; secondsPerStim = 4; % for file1
% load('C:\Research\Data\Patients\80a4e3\file2.mat');offset = 8800; secondsPerStim = 5; % for file2
load('C:\Research\Data\Patients\80a4e3\labels.mat');

load('C:\Research\Data\Patients\80a4e3\trodes.mat');
trodePositions = [[0 0 0]; Grid(17:64,:); LTGr; SFG; FIH([1:7 9:14 16],:); AST([1 2 4 5],:); ITO([1 2 3 4 5 6 7 8 9 10 11 12],:); [0 0 0; 0 0 0]];




signal = double(signal);

samplingRate = 500;

% clean the ending zero'd values from the end of the file. It's a byproduct
% of the EDF files
 for i=length(signal):-1:1; 
     if length(unique(signal(i,:))) > 1; 
         signal(i+1:end,:) = [];
         break; 
     end; 
 end;
 
 signal = NotchFilter(signal, [60 120 180], samplingRate);
spectra = zeros(samplingRate/2+1,size(signal,2));

tic
for chan=1:size(signal,2)
    spectra(:,chan) = log(pwelch(signal(:,chan),samplingRate*2,samplingRate/2, samplingRate, samplingRate, 'onesided'));
    fprintf('%i ',chan);
end
toc
fprintf('\n',chan);

% figure; 
% imagesc(spectra')


signal = BandPassFilter(signal,[0.1 (samplingRate/2-1)], samplingRate,4);

bp = BandPassFilter(signal, [75 150], samplingRate, 4);
bp = abs(hilbert(bp)).^2;
bp = log(bp);

windowSize = 100;
numPoints = floor(size(signal,1)/windowSize);


meanPoints = zeros(numPoints,size(signal,2));


for idx=1:numPoints
    sample = 1 + (idx-1) * windowSize;
    meanPoints(idx,:) = mean(bp(sample:sample+windowSize-1,:),1);
end

rsaVals = [];

% for offset=windowSize:windowSize:40000

    
    movementWindows = secondsPerStim / (windowSize/samplingRate);

    movementStarts = offset/windowSize:movementWindows*2:numPoints-movementWindows;
    restStarts = offset/windowSize+movementWindows:movementWindows*2:numPoints-movementWindows;

    allMovements = repmat(1:movementWindows,length(movementStarts),1) + repmat(movementStarts,movementWindows,1)';
    allMovements = allMovements(:);
    allRests = repmat(1:movementWindows,length(restStarts),1) + repmat(restStarts,movementWindows,1)';
    allRests = allRests(:);

% chan = 110;
% 
% figure; 
% hold on;
% for startAt = movementStarts
%     window = startAt+[1:movementWindows];
%     plot(window, meanPoints(window,chan),'r.');
% end
% 
% for startAt = restStarts
%     window = startAt+[1:movementWindows];
%     plot(window, meanPoints(window,chan),'b.');
% end
% title(labels(chan))


% figure; 
% hold on;
% plot(meanPoints(allMovements,chan),'r.');
% plot(length(allMovements) + [1:length(allRests)],meanPoints(allRests(:),chan),'b.');
% title(labels(chan))
% 


    numerator = ((mean(meanPoints(allMovements,:),1)-mean(meanPoints(allRests,:),1)).^3);
    dena = abs(mean(meanPoints(allMovements,:),1)-mean(meanPoints(allRests,:),1));
    denb = var([meanPoints(allMovements,:);meanPoints(allRests,:)],1);
    num2 = (size(meanPoints(allMovements,:),1)*size(meanPoints(allRests,:),1));
    den2 = size([meanPoints(allMovements,:);meanPoints(allRests,:)],1);

    newRsa = numerator./(dena.*denb).*num2./den2.^2;
    
    rsaVals=[rsaVals; newRsa];
% end

