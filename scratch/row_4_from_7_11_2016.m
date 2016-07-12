% compute the means
% load('/Users/imac2/Desktop/spatially separated stim data/stim_4_60.mat')
% for j=1:64;d460(:,j)=mean(dataEpochedHigh(:,j,:),3);end;
% 
% load('/Users/imac2/Desktop/spatially separated stim data/stim_12_52.mat')
% for j=1:64;d1252(:,j)=mean(dataEpochedHigh(:,j,:),3);end;
% 
% load('/Users/imac2/Desktop/spatially separated stim data/stim_20_44.mat')
% for j=1:64;d2044(:,j)=mean(dataEpochedHigh(:,j,:),3);end;
% 
% load('/Users/imac2/Desktop/spatially separated stim data/stim_28_36.mat')
% for j=1:64;d2836(:,j)=mean(dataEpochedHigh(:,j,:),3);end;

% extract peak positive voltages
for j=1:64;p2836(j)=d2836(628,j);end
for j=1:64;p1252(j)=d1252(628,j);end
for j=1:64;p2044(j)=d2044(628,j);end
for j=1:64;p460(j)=d460(628,j);end

% extract peak pnegative voltages
for j=1:64;nn2836(j)=d2836(630,j);end
for j=1:64;nn1252(j)=d1252(630,j);end
for j=1:64;nn2044(j)=d2044(630,j);end
for j=1:64;nn460(j)=d460(630,j);end

% plot the means
figure;for j=1:64;subplot(8,8,j);plot(d460(:,j));axis([620, 640, -.03, .03]);hold on;end
figure;for j=1:64;subplot(8,8,j);plot(d1252(:,j));axis([620, 640, -.03, .03]);hold on;end
figure;for j=1:64;subplot(8,8,j);plot(d2044(:,j));axis([620, 640, -.03, .03]);hold on;end
figure;for j=1:64;subplot(8,8,j);plot(d2836(:,j));axis([620, 640, -.03, .03]);hold on;end

% plot the peak voltages
figure;plot(nn460);hold on;plot(-2*p460,'r')
figure;plot(nn1252);hold on;plot(-2*p1252,'r')
figure;plot(nn2044);hold on;plot(-2*p2044,'r')
figure;plot(nn2836);hold on;plot(-2*p2836,'r')