%% File to load in and plot stimulation parameters for Broca's data 
% written by David Caldwell

% load in MATLAB file (have file in current working directory

load('0b5a2eBrocas_StimulationInformation.mat')

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
title('Stimulation Voltage of all 4 channels')
ylabel('Voltage (V)')
xlabel('time (ms)')

% plot each channel of the stimulation channels separately 
figure
subplot(2,2,1)
plot(tV,stimVoltage(:,1))

title('Stimulation Voltage for each channel separately')
ylabel('Voltage (V)')
xlabel('time (ms)')


subplot(2,2,2)
plot(tV,stimVoltage(:,2))

subplot(2,2,3)
plot(tV,stimVoltage(:,3))

subplot(2,2,4)
plot(tV,stimVoltage(:,4))
