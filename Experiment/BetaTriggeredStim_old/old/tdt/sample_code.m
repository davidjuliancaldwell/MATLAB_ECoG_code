function sampFreq = ecogTDTData2Matlab(rawDataPath,blockName,chans2Convert,dataTag,outputPath,outputPrefix)
% sampFreq = ecogTDTData2Matlab(rawDataPath,blockName,chans2Convert,dataTag,outputPath,outputPrefix) Covert a set of channels recorded with a TDT sytem to matlab 
%
% PURPOSE: Transform raw TDT data to matlab files
% Each channel is written into a separate mat-file
% Precision is single. 
%
% INPUT:
% rawDataPath: Where the raw data live 
% e.g. D:\Data\Ecog\bp21FingerMov090127\GP21_B12
% blockName: The data block of interest e.g. GP21_B12. Typically
% this is the last part of the pathname and is included in 
% the name of the raw files. An error is thron and the
% availabe blocks are listed if the requested block does 
% not exist in the tank.
% chans2Convert: A list of channel to convert.
% 1:64 will convert the first 64 channels. Currently ther
% is no checking if the channels exist. You will just
% find very small files.
% dataTag: A case sensitive four letter tag defining what we read 
% Most likely 'ECOG' or 'Wave' if you want to convert ecog
% channels.
% Most likely 'ANIN' if you want to convert analogue
% channels.
% Check 'ecogTDTGetDataTags()' if you are not sure
% outputPath: The path where the exported dat are written.
% Typically the same as rawDataPath
% outputPrefix: The prefix for the output files. Helps to discrimintae
% the contents.
% For ECoG use 'gdat_'
% For analogue channels use 'analog_'
% 
% OUTPUT: The data are written to mat-files. The file contains
% data: A vector containing the time series
% params: A structure holding descriptive information
% tagName: The tag name of the channel
% chanNum: The number of the current channel
% sampFreq: The sampling frequency
% nChannels: The total number of channels with
% that tag
% sampFreq: The sampling frequency used to collect the data
%
% REQUIREMENTS: This function requires Microsoft Windows, the 
% TDT drivers, and OpenDeveloper (the latter requires openEx)
% installed
% Get the software from www.tdt.com. OpenEX and OpenDeveloper 
% are password protected. 
%
% EXAMPLE:
% ecogTDTData2Matlab('D:\Data\Berkeley\Ecog\bp22090323\resultsFile\GP22_B28','GP22_B28',1:80,'HECG','D:\Data\Berkeley\Ecog\bp22090323\resultsFile\GP22_B28','gdat_')
% reads 80 channels of ECoG-data from tag 'HECG' and writes each of them to
% a file starting with name 'gdat_[1:80]'. Returns the sampling frequency
% Use 

% 090130 got the original code from LS
% 090130 JR included comments, OS-check, try catch, removed repeated calls and modified path handling 
% 090324 JR rewritten to read only data associated with one tag
% tag is passed as an argument
% fileprefix is passed as an argument
% channels are passed as an argument
% 090324 JR The time series is now named 'data' and a params structure is
% written together with the timeseries.
% 090321 JR Tank name is now found in the directory. No more assumptions
% about specific prefixes are made
% If a block name is not available, all available names are listed before throwing an error 
% 090812 JR Use dataTag as outputprefix if non was passed instead of chrashing 

switch computer
    case 'PCWIN'
    case 'PCWIN64'
    otherwise
        error('Requires Microsoft Windows. Uses ActiveX controls.')
end 

TT = actxcontrol('TTank.X');
e=invoke(TT,'ConnectServer','Local','Me');
if (e==0)
    error('Cannot connect to server');
end

try
pause(1)
%e=invoke(TT,'OpenTank',[rawDataPath '\Ecog2_' blockName],'R');%PLACE PATH OF TANK TO COLLECT DATA FROM
% % the sumption here is that there is only one tank in a directory and
    % that the extension is tev
    tmp=ls('*.tev');
    [p,tankName,e]=fileparts(tmp);
 e=invoke(TT,'OpenTank',[rawDataPath filesep tankName],'R');%PLACE PATH OF TANK TO COLLECT DATA FROM
 if (e==0)
    %error(['Cannot open data tank: ' rawDataPath '\Ecog2_' blockName]);
    error(['Cannot open data tank: ' rawDataPath filesep blockName ' No *.tev file there']);
end
pause(1)
e=invoke(TT,'SelectBlock',blockName);%PLACE NAME OF BLOCK
if e==0
    display('Available block names are:')
    count=1;
    while (~isempty(TT.QueryBlockName(count)))
        display(TT.QueryBlockName(count));
        count=count+1;
    end
    error(['Cannot find block name: ' blockName]);
end
totaltime = floor(invoke(TT,'CurBlockStopTime')- invoke(TT,'CurBlockStartTime'));%Gets total tank duration.
display(['Found ' num2str(totaltime) ' second of data']);

%oldPath=pwd;
%cd(outputPath);

params.tagName=dataTag;
TT.GetCodeSpecs(TT.StringToEvCode(dataTag));
sampFreq=TT.EvSampFreq(1);
params.sampFreq=sampFreq;
params.nChannels=length(chans2Convert);

for k=1:length(chans2Convert)
    params.chanNum=chans2Convert(k);
    e=invoke (TT,'SetGlobals', ['Options = ALL; WavesMemLimit = 134217728;Channel=' num2str(chans2Convert(k)) '; T1=0; T2=' num2str(totaltime)]);
    data=invoke(TT, 'ReadWavesV', dataTag)';%read data
    if ~isempty(data)
        if ~exist('outputPrefix','var') || isempty(outputPrefix)
            outputPrefix=params.tagName;
        end
    disp(['saving ' outputPrefix num2str(chans2Convert(k)) ' of ' num2str(chans2Convert(end))]);
    %eval([outputPrefix num2str(chans2Convert(k)) ' = data;']);
    %eval(['save ' outputPrefix num2str(chans2Convert(k)) ' ' outputPrefix num2str(chans2Convert(k)) 'params;']);
    save([rawDataPath filesep outputPrefix num2str(chans2Convert(k))],'data','params');
    else
        disp(['No data found for channeL: ' num2str(chans2Convert(k)) '. Skipping!']); 
    end
end

%clear gdat*
if 0
% anin channels
for ch = nchans_anin
    e=invoke (TT,'SetGlobals', ['Options = ALL; WavesMemLimit = 134217728; Channel=' num2str(ch) '; T1=0; T2=' num2str(totaltime)]);
    gdat=invoke(TT, 'ReadWavesV', 'ANIN')';%grabs the file
    disp(['saving analog ' num2str(ch) ' of ' num2str(nchans_anin(end))]);
    eval(['analog_' num2str(ch) ' = gdat;']);
    eval(['save analog_' num2str(ch) ' analog_' num2str(ch) ';']);
end
end

invoke(TT,'CloseTank')%closes the server.
% got to where we started 
%cd(oldPath)

catch %Make sure the server is closed if anything chrashes
    invoke(TT,'CloseTank')%closes the server.
    display(lasterr) %Tell the user the problem
% cd(oldPath)
end 