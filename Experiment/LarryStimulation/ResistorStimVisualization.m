%% Script to analyze the stim data we recorded 
% Drag the file in that we want to load to the workspace

recordData = Wave.data;
stimData = Stim.data; 

%% for the one channel output case 
% note the weird transients at beginning and end sometimes as system is
% armed, disarmed, recording is turned on and off. 

figure
subplot(2,1,1)
plot(recordData(:,1))
title('Recorded at headbox')

subplot(2,1,2)
plot(stimData(:,1))
title('Recorded at stimulator')

%% for the three channel output case

figure
plot(recordData(:,1))
title('Recorded at headbox')

figure
subplot(2,2,1)
plot(stimData(:,1))
title('Stim Channel 1') 

subplot(2,2,2)
plot(stimData(:,2))
title('Stim Channel 2') 

subplot(2,2,3)
plot(stimData(:,3))
title('Stim Channel 3') 

subplot(2,2,4)
plot(stimData(:,4))
title('Stim Channel 4') 






