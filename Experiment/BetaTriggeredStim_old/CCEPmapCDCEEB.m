%% this is a script to create a CCEP map for subject cdceeb - DJC - 8/21/2015
% run this in betariggered stim folder with access to z_constants and
% ./scripts/

%% Constants
Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%% import data

tank = TTank;
tank.openTank('C:\Users\David\Desktop\Research\RaoLab\MATLAB\Subjects\cdceeb\EvokedPotentialscdceeb');
tank.selectBlock('EP-4');

tic;
[smon, info] = tank.readWaveEvent('SMon', 2);
smon = smon';

fs = info.SamplingRateHz;

stim = tank.readWaveEvent('SMon', 4)';
toc;

% Wave-1 looks like the beta signal (SHIT!), should have been the
% decision variable

% Wave-2 is the mode
% Wave-3 is the mode time/counter
% Wave-4 looks like the stim command
tic;
mode = tank.readWaveEvent('Wave', 2)';
ttype = tank.readWaveEvent('Wave', 1)';

beta = tank.readWaveEvent('Blck', 1)';
%     [beta, ~] = tdt_loadStream(tp, block, 'Blck', 1);
raw = tank.readWaveEvent('Blck', 2)';
%     [raw, ~] = tdt_loadStream(tp, block, 'Blck', 2);
toc;
