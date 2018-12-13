%% this script is used in conjunction with the TDT CCEP Mapping circuit and program to monitor CCEPs in real time.

%% what tank are we going to be collecting data from?
TANKPATH = 'C:\TDT\OpenEx\MyProjects\EvokedPotentials\DataTanks\Test_EvokedPotentials';

% TANKPATH = 'D:\research\code\output\BetaTriggeredStim\data';
NCHANS = 64;    

try 
    ttx = actxcontrol('TTank.X');
    res = ttx.ConnectServer('Local','Me');
    if (res == 0) 
        error ('failed connecting');
    end

    res = ttx.OpenTank(TANKPATH,'R');
    if (res == 0) 
        error ('failed opening tank');
    end

    hotblock = ttx.GetHotBlock;

    if (isempty(hotblock))
        error('no block is currently being recorded');
    end

    ttx.SelectBlock(hotblock);

    % build the viz
    t = ((1:488)-122) / 12207.03;
    viz = CCEPVisualizer(64, t, t > 5e-3 & t < 50e-3);


    curtime = 0;
    prevstimcurrent = 0;

    ttx.SetGlobals('T1=0');

    while (true)
        % check for new events
    %     nrecs = ttx.ReadEventsV(1, 'AvEP', 0, 0, curtime);
        nrecs = ttx.ReadEventsSimple('Blck');

        if (nrecs >= 1)
            fprintf('new event found\n');

            % get the waveform data
            newWaves = ttx.ParseEvV(0, 64);

            % get the event timing
            curtime = ttx.ParseEvInfoV(0, 1, 6);

            % now load the current stimulator amplitude in to memory.
            % note, the Blck event is now gone...
            ttx.ReadEventsSimple('Valu');
            stimcurrent = ttx.ParseEvInfoV(0, 1, 7);

            % update T1, meaning we'll only see events later than this when we
            % check again
            curtime = curtime + 0.10; % add 100 msec
            ttx.SetGlobals(sprintf('T1=%f',curtime));

            % if the stimulus current has changed, clear the figure
            if (stimcurrent ~= prevstimcurrent)
                % do reset
                fprintf('new current found, reset display\n');
                viz.reset();
                prevstimcurrent = stimcurrent;
            end

            % draw the new waveform, update the mean
            viz.update(newWaves');
        else        
            pause(.5);
        end
    end
catch
    fprintf('cleaning up.');
    ttx.CloseTank;
    ttx.ReleaseServer;
end    
