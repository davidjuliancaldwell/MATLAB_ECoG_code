%%load in data - post stim 

 load('ecb43e_PAC_postsimulbci1.mat') % 5his is set to be run from experiment/betatriggered stim folder

%% Plot images of interest
% data matrix is frequency, 1st column (fwa) is phase frequencies, 2nd
% (fwb) is amplitude frequencies, next two columns are channels 

figure
cLims = [0 31e-3];

subplot(4,3,1)
imagesc([0 30],[70 40],squeeze(map(:,:,4,21)'))
title('Channel 4 phase -> Channel 21 amplitude ')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)
hold on

subplot(4,3,2)
imagesc([0 30], [70 40],squeeze(map(:,:,4,54)'))
title('Channel 4 phase -> Channel 54 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,3)
imagesc([0 30],[70 40],squeeze(map(:,:,4,62)'))
title('Channel 4 phase -> Channel 62 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,4)
imagesc([0 30],[70 40],squeeze(map(:,:,62,21)'))
title('Channel 62 phase -> Channel 21 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,5)
imagesc([0 30],[70 40],squeeze(map(:,:,62,54)'))
title('Channel 62 phase -> Channel 54 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,6)
imagesc([0 30],[70 40],squeeze(map(:,:,62,4)'))
title('Channel 62 phase -> Channel 4 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,7)
imagesc([0 30],[70 40],squeeze(map(:,:,21,54)'))
title('Channel 21 phase -> Channel 54 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)
hold on

subplot(4,3,8)
imagesc([0 30], [70 40],squeeze(map(:,:,21,4)'))
title('Channel 21 phase -> Channel 4 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,9)
imagesc([0 30],[70 40],squeeze(map(:,:,21,62)'))
title('Channel 21 phase -> Channel 62 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,10)
imagesc([0 30],[70 40],squeeze(map(:,:,54,21)'))
title('Channel 54 phase -> Channel 21 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,11)
imagesc([0 30],[70 40],squeeze(map(:,:,54,4)'))
title('Channel 54 phase -> Channel 4 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
text('FontSize', 20)

subplot(4,3,12)
imagesc([0 30],[70 40],squeeze(map(:,:,54,62)'))
title('Channel 54 phase -> Channel 62 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
xlabel('Hz')
ylabel('Hz')
text('FontSize', 20)

subtitle('Post task')
text('FontSize', 20)


%% load in data - pre stim 

load('ecb43e_PAC_baseline')

%% Plot images of interest
% data matrix is frequency, 1st column (fwa) is phase frequencies, 2nd
% (fwb) is amplitude frequencies, next two columns are channels 

figure


subplot(4,3,1)
imagesc([0 30],[70 40],squeeze(map(:,:,4,21)'))
title('Channel 4 phase -> Channel 21 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
hold on

subplot(4,3,2)
imagesc([0 30], [70 40],squeeze(map(:,:,4,54)'))
title('Channel 4 phase -> Channel 54 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,3)
imagesc([0 30],[70 40],squeeze(map(:,:,4,62)'))
title('Channel 4 phase -> Channel 62 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,4)
imagesc([0 30],[70 40],squeeze(map(:,:,62,21)'))
title('Channel 62 phase -> Channel 21 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,5)
imagesc([0 30],[70 40],squeeze(map(:,:,62,54)'))
title('Channel 62 phase -> Channel 54 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,6)
imagesc([0 30],[70 40],squeeze(map(:,:,62,4)'))
title('Channel 62 phase -> Channel 4 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,7)
imagesc([0 30],[70 40],squeeze(map(:,:,21,54)'))
title('Channel 21 phase -> Channel 54 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
hold on

subplot(4,3,8)
imagesc([0 30], [70 40],squeeze(map(:,:,21,4)'))
title('Channel 21 phase -> Channel 4 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,9)
imagesc([0 30],[70 40],squeeze(map(:,:,21,62)'))
title('Channel 21 phase -> Channel 62 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,10)
imagesc([0 30],[70 40],squeeze(map(:,:,54,21)'))
title('Channel 54 phase -> Channel 21 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,11)
imagesc([0 30],[70 40],squeeze(map(:,:,54,4)'))
title('Channel 54 phase -> Channel 4 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,12)
imagesc([0 30],[70 40],squeeze(map(:,:,54,62)'))
title('Channel 54 phase -> Channel 62 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
xlabel('Hz')
ylabel('Hz')

subtitle('Baseline session A')