%% File to load in and plot stimulation parameters
% written by David Caldwell

% load in MATLAB file (have file in current working directory

load('0b5a2e_StimulationInformation.mat')

% plot variables of interest

figure
subplot(2,1,1)
tC = 1e3*(0:length(stimCurrent)-1)/stimCurrentSamplingFrequency;
plot(tC,stimCurrent)
title('Stimulation Current')
ylabel('Current (\muA)')
xlabel('time (ms)')

subplot(2,1,2)
tV = 1e3*(0:length(stimVoltage)-1)/stimVoltageSamplingFrequency;
plot(tV,stimVoltage)
title('Stimulation Voltage')
ylabel('Voltage (V)')
xlabel('times (ms)')