%% DJC - 5/20/2016 - Resting State Analysis script for TDT stuff


close all;clear all;clc

Z_Constants;
SUB_DIR = fullfile(myGetenv('subject_dir'));
OUTPUT_DIR = fullfile(myGetenv('OUTPUT_DIR'));

subjid = input('What is the subject ID?  \n','s');

load(fullfile(OUTPUT_DIR,'TDTtoMATfiles','78283a_RestingState','RestingState-2.mat'))

%% load in data 

fs = Wave.info.SamplingRateHz;
ECoGData = Wave.data;


figure(1)
for i = 1:64
    subplot(8,8,i);
    plot(ECoGData(:,i));
end
figure(2)
for i = 65:128
    subplot(8,8,i-64);
    plot(ECoGData(:,i));
end

%% fake montage for plotting 

% make fake montage


%there appears to be no montage for this subject currently
Montage.Montage = 64;
Montage.MontageTokenized = {'Grid(1:64)'};
Montage.MontageString = Montage.MontageTokenized{:};
Montage.MontageTrodes = zeros(64, 3);
Montage.BadChannels = [];
Montage.Default = true;

% get electrode locations
locs = trodeLocsFromMontage(sid, Montage, false);