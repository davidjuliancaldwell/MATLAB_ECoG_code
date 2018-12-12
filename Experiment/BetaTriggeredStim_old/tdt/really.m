%% OPEN
% open the data tank control
TT = actxcontrol('TTank.X');

%% connect to it
e=invoke(TT,'ConnectServer','Local','Me');
if (e==0)
    error('Cannot connect to server');
end

%% get a path to the data tank of interest
rawDataPath = 'C:\TDT\OpenEx\Tanks';


%% list the tanks in this folder, and have the user select one
tmp = ls(fullfile(rawDataPath, '*.*'));

files = dir(rawDataPath);
keepers = false(size(files));

for fileIdx = 1:length(files)
    if (strfind(files(fileIdx).name, '.tev'))
        keepers(fileIdx) = 1;
    end
end

files = files(keepers);
        
% currently hardcoded
idx = 1;

tankPath = fullfile(rawDataPath, files(idx).name);

%% open the tank
e=invoke(TT,'OpenTank',tankPath,'R');%PLACE PATH OF TANK TO COLLECT DATA FROM

if (e==0)
    error(['Cannot open data tank: ' tankPath]);
end

%% list the blocks in this tank, and have the user select one
display('Available block names are:')
count=1;
blockNames = {};
while (~isempty(TT.QueryBlockName(count)))
    blockNames{count} = TT.QueryBlockName(count);    
    count=count+1;
end
display(blockNames);

blocknum = 1;

%% select the block
e=invoke(TT,'SelectBlock',blockNames{blocknum});%PLACE NAME OF BLOCK

if (e==0)
    error('Cannot select block');
end

totaltime = floor(invoke(TT,'CurBlockStopTime')- invoke(TT,'CurBlockStartTime'));%Gets total tank duration.
display(['Found ' num2str(totaltime) ' seconds of data']);

%% 
dataTag = 'ECOG';
chans2Convert = 1:4;

params.tagName=dataTag;
TT.GetCodeSpecs(TT.StringToEvCode(dataTag));
sampFreq=TT.EvSampFreq(1);
params.sampFreq=sampFreq;
params.nChannels=length(chans2Convert);

