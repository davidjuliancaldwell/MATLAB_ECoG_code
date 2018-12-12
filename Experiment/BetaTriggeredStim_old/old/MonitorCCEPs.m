%% this script is used in conjunction with the TDT CCEP Mapping circuit and program to monitor CCEPs in real time.

%% what tank are we going to be collecting data from?
% tankpath = ['C:\TDT\OpenEx\MyProjects\' experiment '\DataTanks\' subjid '_' experiment '\'];
TANKPATH = 'D:\research\code\output\BetaTriggeredStim\data';
NCHANS = 64;    

ttx = actxcontrol('TTank.X');
ttx.ConnectServer('Local','Me');
ttx.OpenTank(TANKPATH,'R');
hotblock = ttx.GetHotBlock;

if (isempty(hotblock))
    error('no block is currently being recorded');
end

ttx.SelectBlock(hotblock);

while (true)
    % check for new events
    nrecs = ttx.ReadEventsV(1, 'EVNT', 0, 0, curtime);
    
    if (nrecs >= 1)
        % get event data
        curtime = ttx.ParseEvInfoV(0, 1, 6);
        curtime = curtime + 0.010; % add ten msec
        
        stimcurrent = ttx.ParseEvInfoV(0, 1, 7); % not sure if this will work
        
        % if the stimulus current has changed, clear the figure
        if (stimcurrent ~= prevstimcurrent)
            % do reset
            fprintf('should reset here');
        end
    
        % get the waveform data
        newWaves = ttx.ParseEvV(0, 1);
        
        % draw the new waveform, update the mean
        fprintf('do draw here');
    else
        pause(.5);
    end
end

ttx.CloseTank;
ttx.ReleaseServer;
    
