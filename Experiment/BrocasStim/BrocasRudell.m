%% this is a data file to grab the stim data and current data from brocas
% Written by David Caldwell, 1/5/2016
%

%% initialize output and meta dir
Z_ConstantsBrocas;
addpath ./Experiment/BetaTriggeredStim/scripts

%% load in subject

sid = SIDS{1};

if (strcmp(sid, '0b5a2e'))
    tank = TTank;
    tank.openTank('D:\Subjects\0b5a2e\data\d8\0b5a2e_otherStim\0b5a2e_otherStim');
    tank.selectBlock('brocas-1');
    stims = [28 36];
    badChans = [20 24 28]; % unplugged channels
    
    tic;
    [data, data_info] = tank.readWaveEvent('Wave');
    [stim, stim_info] = tank.readWaveEvent('Stim');
    toc;
    
    
    fs_data = data_info.SamplingRateHz;
    fs_stim = stim_info.SamplingRateHz;
    
    [Stm0, Stm0_info] = tank.readWaveEvent('Stm0');
    [Sing, Sing_info] = tank.readWaveEvent('Sing');
    
    stimVoltage = stim;
    
    stimVoltageSamplingFrequency = stim_info.SamplingRateHz;
    
    stimCurrent = Sing;
    
    stimCurrentSamplingFrequency = Sing_info.SamplingRateHz;
    
    
end

% plot 
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


%% save the file
save(fullfile(META_DIR, [sid 'Brocas_StimulationInformation.mat']), 'stimVoltage','stimVoltageSamplingFrequency','stimCurrent','stimCurrentSamplingFrequency');