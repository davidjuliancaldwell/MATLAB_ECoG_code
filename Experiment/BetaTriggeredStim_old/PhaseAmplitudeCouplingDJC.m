%%load in data - post stim 

load ../../../Subjects/ecb43e_PAC_poststim.mat % 5his is set to be run from experiment/betatriggered stim folder

%% Plot images of interest
% data matrix is frequency, 1st column (fwa) is phase frequencies, 2nd
% (fwb) is amplitude frequencies, next two columns are channels 

figure
cLims = [0 25e-3];

subplot(4,3,1)
imagesc([0 30],[70 130],squeeze(map(:,:,56,47)'))
title('Channel 56 frequency mapped to Channel 47 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
hold on

subplot(4,3,2)
imagesc([0 30], [70 130],squeeze(map(:,:,56,55)'))
title('Channel 56 frequency mapped to Channel 55 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,3)
imagesc([0 30],[70 130],squeeze(map(:,:,56,64)'))
title('Channel 56 frequency mapped to Channel 64 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,4)
imagesc([0 30],[70 130],squeeze(map(:,:,64,47)'))
title('Channel 64 frequency mapped to Channel 47 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,5)
imagesc([0 30],[70 130],squeeze(map(:,:,64,55)'))
title('Channel 64 frequency mapped to Channel 55 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,6)
imagesc([0 30],[70 130],squeeze(map(:,:,64,56)'))
title('Channel 64 frequency mapped to Channel 56 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,7)
imagesc([0 30],[70 130],squeeze(map(:,:,47,55)'))
title('Channel 47 frequency mapped to Channel 55 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
hold on

subplot(4,3,8)
imagesc([0 30], [70 130],squeeze(map(:,:,47,56)'))
title('Channel 47 frequency mapped to Channel 56 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,9)
imagesc([0 30],[70 130],squeeze(map(:,:,47,64)'))
title('Channel 47 frequency mapped to Channel 64 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,10)
imagesc([0 30],[70 130],squeeze(map(:,:,55,47)'))
title('Channel 55 frequency mapped to Channel 47 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,11)
imagesc([0 30],[70 130],squeeze(map(:,:,55,56)'))
title('Channel 55 frequency mapped to Channel 56 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,12)
imagesc([0 30],[70 130],squeeze(map(:,:,55,64)'))
title('Channel 55 frequency mapped to Channel 64 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
xlabel('Hz')
ylabel('Hz')

subtitle('Phase Amplitude Coupling post stimulation')


%% load in data - pre stim 

load ../../../Subjects/ecb43e_PAC_prestim.mat

%% Plot images of interest
% data matrix is frequency, 1st column (fwa) is phase frequencies, 2nd
% (fwb) is amplitude frequencies, next two columns are channels 

figure


subplot(4,3,1)
imagesc([0 30],[70 130],squeeze(map(:,:,56,47)'))
title('Channel 56 frequency mapped to Channel 47 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
hold on

subplot(4,3,2)
imagesc([0 30], [70 130],squeeze(map(:,:,56,55)'))
title('Channel 56 frequency mapped to Channel 55 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,3)
imagesc([0 30],[70 130],squeeze(map(:,:,56,64)'))
title('Channel 56 frequency mapped to Channel 64 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,4)
imagesc([0 30],[70 130],squeeze(map(:,:,64,47)'))
title('Channel 64 frequency mapped to Channel 47 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,5)
imagesc([0 30],[70 130],squeeze(map(:,:,64,55)'))
title('Channel 64 frequency mapped to Channel 55 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,6)
imagesc([0 30],[70 130],squeeze(map(:,:,64,56)'))
title('Channel 64 frequency mapped to Channel 56 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,7)
imagesc([0 30],[70 130],squeeze(map(:,:,47,55)'))
title('Channel 47 frequency mapped to Channel 55 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
hold on

subplot(4,3,8)
imagesc([0 30], [70 130],squeeze(map(:,:,47,56)'))
title('Channel 47 frequency mapped to Channel 56 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,9)
imagesc([0 30],[70 130],squeeze(map(:,:,47,64)'))
title('Channel 47 frequency mapped to Channel 64 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,10)
imagesc([0 30],[70 130],squeeze(map(:,:,55,47)'))
title('Channel 55 frequency mapped to Channel 47 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,11)
imagesc([0 30],[70 130],squeeze(map(:,:,55,56)'))
title('Channel 55 frequency mapped to Channel 56 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)

subplot(4,3,12)
imagesc([0 30],[70 130],squeeze(map(:,:,55,64)'))
title('Channel 55 frequency mapped to Channel 64 amplitude')
set(gca,'Ydir','normal')
colorbar
caxis(cLims)
xlabel('Hz')
ylabel('Hz')

subtitle('Phase Amplitude Coupling pre stimulation')