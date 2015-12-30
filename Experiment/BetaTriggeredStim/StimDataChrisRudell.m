%% this is a data file to grab the stim data and current data from the stimulator electrode from a subject for chris ruddell
% right now, for ecb43e
%%
Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%%

sid = input('Subject ID?  ','s');

switch sid
    case '9ab7ab'
        sid = '9ab7ab';
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
        tank.selectBlock('BetaPhase-3');
        
    case '702d24'
        sid = '702d24';
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\702d24\data\d7\702d24_BetaStim');
        tank.selectBlock('BetaPhase-4');
        
    case 'ecb43e'
        sid = 'ecb43e';
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim');
        tank.selectBlock('BetaPhase-3');
    case 'ecb43e-EP'
        sid = 'ecb43e';
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim');
        tank.selectBlock('EP-1')
    case '0b5a2e'
        sid = '0b5a2e';
        tank = TTank;
        tank.openTank('D:\Subjects\0b5a2e\data\d8\0b5a2e_BetaStim\0b5a2e_BetaStim');
        tank.selectBlock('BetaPhase-2');
end


% get stim voltage, realized stim voltage from stimulator
[stim,info] = tank.readWaveEvent('SMon', 4);

stimVoltage = stim;

stimVoltageSamplingFrequency = info.SamplingRateHz;

stimCurrent = tank.readWaveEvent('Para',7');

stimCurrentSamplingFrequency = round(stimVoltageSamplingFrequency/(length(stimVoltage)/length(stimCurrent)));

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
%% save the file
save(fullfile(META_DIR, [sid '_StimulationInformation.mat']), 'stimVoltage','stimVoltageSamplingFrequency','stimCurrent','stimCurrentSamplingFrequency');