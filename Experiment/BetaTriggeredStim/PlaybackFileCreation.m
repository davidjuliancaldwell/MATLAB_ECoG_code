%% 11-18-2015 - This is a file to create the text file for playback of stimulation
% This file builds a stimulation table in a .txt file, one value per row,
% in one column, from the previously recorded

Z_Constants;
addpath ./scripts/ %DJC edit 7/17/2015

%% Open up the data tank, have to point to the correct place

sid = input('what is the subject id?','s');

tank = TTank;


% tank.openTank('D:\Subjects\ecb43e\data\d7\BetaStim');
% tank.selectBlock('BetaPhase-3');

tank.openTank('D:\Subjects\702d24\data\d7\702d24_BetaStim');
tank.selectBlock('BetaPhase-4');

tic;
[smon, info] = tank.readWaveEvent('SMon', 2);
smon = smon';
toc;

stims = find(smon(1,:)==1); % identify samples when smon = 1 (stimulation command sent)


%% make vector of points where stims == 0

pts = stims;

%% write these times to file

filename = sprintf('%s_PlayBackStimulus.txt',sid);
fileID = fopen(filename,'w');
fprintf(fileID,'%d\r\n',pts);
fclose(fileID);

