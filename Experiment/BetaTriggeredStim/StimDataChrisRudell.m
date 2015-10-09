%% this is a data file to grab the stim data and current data from the stimulator electrode from a subject for chris ruddell
% right now, for ecb43e
%%
Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%%

sid = input('Subject ID?','s');

switch sid
    case '9ab7ab'
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\9ab7ab\data\d7\9ab7ab_BetaTriggeredStim');
        tank.selectBlock('BetaPhase-3');
        
    case '702d24'
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\702d24\data\d7\702d24_BetaStim');
        tank.selectBlock('BetaPhase-4');
        
    case 'ecb43e'
        tank = TTank;
        tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\ecb43e\data\d7\BetaStim');
        tank.selectBlock('BetaPhase-3');
        
end


% get stim voltage, realized stim voltage from stimulator
[stim,info] = tank.readWaveEvent('SMon', 4);

stimVoltage = stim;

stimVoltageSamplingFrequency = info.SamplingRateHz;

stimCurrent = tank.readWaveEvent('Para',7');

stimCurrentSamplingFrequency = round(stimVoltageSamplingFrequency/(length(stimVoltage)/length(stimCurrent)));


%% save the file
save(fullfile(META_DIR, [sid '_StimulationInformation.mat']), 'stimVoltage','stimVoltageSamplingFrequency','stimCurrent','stimCurrentSamplingFrequency');