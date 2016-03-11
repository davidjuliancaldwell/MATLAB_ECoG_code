%% for subject 9ab7ab
% (Below is from Jenny in email to Utah)

% ECoG data was recorded for 10ms before the trigger (stimulation) and 30 ms afterwards
% Most of the files use the following naming system:
% SMon.data(:,4) is the stim data that was used
% SMon.data(:,2) is the trigger that goes high whenever stim pulse occurs and triggers a 40ms recording block of the ECoG signal
% Blck.data are the ECoG channels
% I believe that only the grid (64 ch) was recorded for each experiment
% Some of the files don’t have SMon, and instead of Blck use AvEP for the ECoG channels
% You can access the sampling rate of the data by <name>.info.SamplingRateHz, e.g. SMon.info.SamplingRateHz
% Note that in most cases the stim sampling rate and ECoG sampling rate are different
%

% convert stim sample rates, ECoG sampling rates to milliseconds to be
% consistent

% load in data

sid = input('What was the subject ID? 0b5a2e?','s');

switch sid
    case '9ab7ab'
        load 'D:/Subjects/9ab7ab/data/EP-1.mat'
    case '0b5a2e'
        load 'D:\Subjects\0b5a2e\data\d8\0b5a2e_EP'
end

%%
% stim is stim data, smon is trigger that goes high whenever stim pulse
% occurs and triggers 40 ms recording block

stim = SMon.data(:,4)';
fs_stim = SMon.info.SamplingRateHz;
smon = SMon.data(:,2)';

fs_sig = Blck.info.SamplingRateHz;
sig = Blck.data';


%
% figure
% subplot(2,1,1)
% plot([1:1:length(smon)],smon)
% title('Smon')
% subplot(2,1,2)
% plot([1:1:length(stim)],stim)
% title('Stim')

%% stim table
% 1 - stim ID
% 2 - stimulation start
% 3 - stimulation stop
% 4 - trigger time
stimtab = [];

% index of stimulation trigger
smonind = find(smon>0);
stimtab(1,:) = [1:1:length(smonind)];
stimtab(4,:) = smonind;
stimtab(2,:) = smonind;
stimtab(3,:) = smonind+100;

start_ind = stimtab(2,:);
end_ind = stimtab(3,:);
smon_epoch = squeeze(getEpochSignal(smon',start_ind-10,end_ind))';
stim_epoch = squeeze(getEpochSignal(stim',start_ind-10,end_ind))';

figure
subplot(2,1,1)
plot([-9:1:length(smon_epoch)-10],smon_epoch)
title('Smon')
subplot(2,1,2)
plot([-9:1:length(stim_epoch)-10],stim_epoch)
title('Stim')

% want to make sure stim was delivered everytime that trigger occured
%%

