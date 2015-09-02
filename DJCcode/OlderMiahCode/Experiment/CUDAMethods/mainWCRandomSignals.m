sampleLength = 100000;
fs = 1000;

numRandIncreases = 40;
scaleFactor = 1.1;

randomHeights = 1;

%for uniform height
gaussianWidth = fs / 10;

source = SimulateBroadband(sampleLength,1000,[75 200],15,1,2,0);
dest = SimulateBroadband(sampleLength,1000,[75 200],15,1,2,0);

rawSignalFigure = figure;
plot(source); hold on; plot(dest,'r');
title('Simulated raw source and destination channels');
legend('Source','Destination');
xlabel('Sample');
ylabel('Signal (Simulated Voltage)');

psdFigure = figure;
psdOut = pwelch(source,1000,250,fs,fs);
hold on;
plot(log(psdOut));
psdOut = pwelch(dest,1000,250,fs,fs);
plot(log(psdOut),'r');
xlabel('Frequency');
ylabel('Log Power');
title('Power spectral density plots for source and destination channels');

% return;

%Add random gaussian increases to source
sampleToAddRandIncreases = round([rand(numRandIncreases,1)* sampleLength])';

for i = sampleToAddRandIncreases
%     convWindow = gausswin(gaussianWidth)+1 + 0.5*rand(1,1);
    convWindow = gausswin(gaussianWidth)+1 + scaleFactor;
    
    centeredWindow = [i-ceil(gaussianWidth/2):i+floor(gaussianWidth/2)-1];
    
    convWindow(centeredWindow < 1) = [];
    convWindow(centeredWindow > sampleLength) = [];
    centeredWindow(centeredWindow < 1) = [];
    centeredWindow(centeredWindow > sampleLength) = [];
    
    source(centeredWindow) = source(centeredWindow) .* convWindow';
end

%Add random gaussian increases to dest
sampleToAddRandIncreases = round([rand(numRandIncreases,1)* sampleLength])';

for i = sampleToAddRandIncreases
%     convWindow = gausswin(gaussianWidth)+1 + 0.5*rand(1,1);
    convWindow = gausswin(gaussianWidth)+1 + scaleFactor;
    
    centeredWindow = [i-ceil(gaussianWidth/2):i+floor(gaussianWidth/2)-1];
    
    convWindow(centeredWindow < 1) = [];
    convWindow(centeredWindow > sampleLength) = [];
    centeredWindow(centeredWindow < 1) = [];
    centeredWindow(centeredWindow > sampleLength) = [];
    
    dest(centeredWindow) = dest(centeredWindow) .* convWindow';
end

source = abs(hilbert(source));
dest = abs(hilbert(dest));

covFig = figure;
plot([-500:500],xcov(source, dest,500)); hold on;

f = gausswc(single(source)', single(dest)',300, 300,single(gausswin(300)));
%%
figure;
imagesc(f)
pause( 0.25); 
set(gca,'ytick',[1 101 201 301 401 501 601]);
pause( 0.25); 
set(gca,'yticklabel',[300 200 100 0 -100 -200 300]);
ylabel('Delay (delta)');
xlabel('Time');

%%

acUn = figure;
periodBefore = fs;
periodAfter = fs;

averageCov = zeros(periodBefore + periodAfter, 300*2+1)';



numValidEpochs = 0;
for sc = sampleToAddRandIncreases
    try
        averageCov = averageCov + f(:,sc-periodBefore:sc+periodAfter-1);
        numValidEpochs = numValidEpochs + 1;
    catch
%         fprintf('ERR\n');
    end
end

averageCov = averageCov ./ numValidEpochs;

imagesc(averageCov);
pause( 0.25); set(gca,'ytick',[1 101 201 301 401 501 601]);pause( 0.25); 
set(gca,'yticklabel',[300 200 100 0 -100 -200 300]);
ylabel('Delay (delta)');
xlabel('Time');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this time add some time-lagged correlated signals
timeLag = 50;

% source = SimulateBroadband(sampleLength,1000,[70 200],3,1,2,0);
% dest = SimulateBroadband(sampleLength,1000,[70 200],3,1,2,0);

%Add random gaussian increases to source
sampleToAddRandIncreases = round([rand(numRandIncreases,1)* sampleLength])';

for i = sampleToAddRandIncreases
%     convWindow = gausswin(gaussianWidth)+1 + 0.5*rand(1,1);
    convWindow = gausswin(gaussianWidth)+1 + scaleFactor;
    
    centeredWindow = [i-ceil(gaussianWidth/2):i+floor(gaussianWidth/2)-1];
    
    convWindow(centeredWindow < 1) = [];
    convWindow(centeredWindow > sampleLength) = [];
    centeredWindow(centeredWindow < 1) = [];
    centeredWindow(centeredWindow > sampleLength) = [];
    
    source(centeredWindow) = source(centeredWindow) .* convWindow';
    
    %%
%     convWindow = gausswin(gaussianWidth)+1 + 0.5*rand(1,1);
    convWindow = gausswin(gaussianWidth)+1 + scaleFactor;
    centeredWindow = [i-ceil(gaussianWidth/2):i+floor(gaussianWidth/2)-1]+timeLag;
    
    convWindow(centeredWindow < 1) = [];
    convWindow(centeredWindow > sampleLength) = [];
    centeredWindow(centeredWindow < 1) = [];
    centeredWindow(centeredWindow > sampleLength) = [];
    
    dest(centeredWindow) = dest(centeredWindow) .* convWindow';
end

source = abs(hilbert(source));
dest = abs(hilbert(dest));
% f = CudaMex_v2(single(source)', single(dest)',300, 300);
f = gausswc(single(source)', single(dest)',300, 300,single(gausswin(300)));

%%
figure;
imagesc(f)
hold on;
for i = sampleToAddRandIncreases
    plot([i i], [1 601],'k');
end
pause( 0.25); set(gca,'ytick',[1 101 201 301 401 501 601]);pause( 0.25); 
set(gca,'yticklabel',[300 200 100 0 -100 -200 300]);
ylabel('Delay (delta)');
xlabel('Time');
%%
figure;
periodBefore = fs;
periodAfter = fs;

averageCov = zeros(periodBefore + periodAfter, 300*2+1)';



numValidEpochs = 0;
for sc = sampleToAddRandIncreases
    try
        averageCov = averageCov + f(:,sc-periodBefore:sc+periodAfter-1);
        numValidEpochs = numValidEpochs + 1;
    catch
%         fprintf('ERR\n');
    end
end

averageCov = averageCov ./ numValidEpochs;

imagesc(averageCov);
clims = get(gca,'clim');
pause( 0.25); set(gca,'ytick',[1 101 201 301 401 501 601]);pause( 0.25); 
set(gca,'yticklabel',[300 200 100 0 -100 -200 300]);
ylabel('Delay (delta)');
xlabel('Time');

figure(acUn);
set(gca,'clim',clims);

% figure(covFig);
% plot([-500:500],xcov(source, dest,500),'r'); hold on;