function [data, fs] = tdt_loadStream(tankpath, block, event, chans)
% function stream = tdt_loadStream(tankpath, block, event, chans)
%   loads one or more channels of continuous data from a TDT block
%
%   ARGUMENTS
%   tankpath (string) is the absolute path to the data tank
%   block    (string) is the name of the block to draw data from
%   event    (string) is the name of the event in the data tank
%   chans    (double []) is a list of the channels from the event for which
%              you want to extract data from the tank.  if empty or
%              nonexistent, this function will return all channels.
%
%   RETURNS
%   data  (double [NxT]) where N is the number of channels and T is the
%              number of samples.
%   fs    (double) sampling rate of recorded data
%
%   EXAMPLE USAGE
%     tp = 'd:\research\subjects\d5cd55\data\d8\d5cd55_BetaTriggeredStim';
%     block = 'Block-49';
%     event = 'TDAT';
%     chans = [];
%
%     result = tdt_loadStream(tp, block, event, chans);
   
    ttx = actxcontrol('TTank.X');
    pause(.2);
    
    ttx.ConnectServer('Local','Me');
    pause(.2);
    
    res = ttx.OpenTank(tankpath,'R');
    pause(.2);
    
    if (res == 0)
        ttx.ReleaseServer;
        error('unable to open tank');
    end
    
    res = ttx.SelectBlock(block);
    pause(.2);
    
    if (res == 0)
        ttx.CloseTank;
        ttx.ReleaseServer;
        error('unable to locate block');
    end
    
    % check to make sure the event exists
    notes = parseTDTNotes(ttx.CurBlockNotes);
    
    evIdx = -1;
    for c = 1:length(notes)
        if (strcmp(notes(c).name, event))
            evIdx = c;
        end
    end
    
    if (evIdx <= 0)
        ttx.CloseTank;
        ttx.ReleaseServer;        
        error('requested event does not exist.');
    end
    
    % and that the channels requested exist
    if (~exist('chans', 'var') || isempty(chans))
        chans = 1:notes(evIdx).nchans;
    end
        
    if (max(chans) > notes(evIdx).nchans)
        ttx.CloseTank;
        ttx.ReleaseServer;        
        error('Too many channels requested from event.');
    end        
    
    % collect one channel worth of the data to init our array
    ttx.SetGlobalV('WavesMemLimit', 1024^3);    
    ttx.SetGlobals(sprintf('Channel=%d', chans(1)));
    temp = ttx.ReadWavesV(event);

    data = zeros(length(chans), length(temp));
    data(1,:) = temp;
    clear temp;
    
    for idx = 2:length(chans)
        ttx.SetGlobals(sprintf('Channel=%d', chans(idx)));
        data(idx, :) = ttx.ReadWavesV(event);
    end
        
    fs = notes(evIdx).fs;
    
    ttx.CloseTank;
    ttx.ReleaseServer;    
end
