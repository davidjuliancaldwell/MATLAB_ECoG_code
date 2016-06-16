%% script to plot peak timing
close all;clearvars;clc
load('latenciesPeaksData_6_15_2016.mat')

%% big ol gplotmatrix
figure
gplotmatrix(bigMatrix,[],ccepSID',[],[],[],'on','stairs',bigMatrix_categories);


%% individual plots
figure;
gscatter(betaDist_total,mag_total_ave,ccepSID')
xlabel('distance from beta recording electrode')
ylabel('magnitude of peak')

figure;
gscatter(betaDist_total,latency_total_ave,ccepSID')
xlabel('distance from beta recording electrode')
ylabel('latency of peak')

figure;
gscatter(betaDist_total,z_total_ave,ccepSID')
xlabel('distance from beta recording electrode')
ylabel('z-scored')

figure;
gscatter(latency_total_ave,mag_total_ave,ccepSID')
xlabel('latency of peak')
ylabel('magnitude of peak')

