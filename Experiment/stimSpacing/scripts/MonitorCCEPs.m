%% this script is used in conjunction with the TDT CCEP Mapping circuit and program to monitor CCEPs in real time.

%% what tank are we going to be collecting data from?
TANKPATH = 'C:\TDT\OpenEx\MyProjects\EvokedPotentials\DataTanks\9ab7ab_EvokedPotentials';
HARDBLOCK = 'EP-1';

% TANKPATH = 'C:\TDT\OpenEx\MyProjects\EvokedPotentials\DataTanks\7dbdec_EvokedPotentials';
% HARDBLOCK = 'EP-9';

% TANKPATH = 'C:\TDT\OpenEx\MyProjects\EvokedPotentials\DataTanks\c91479_EvokedPotentials';
% HARDBLOCK = 'EP-6';

% TANKPATH = 'C:\TDT\OpenEx\MyProjects\EvokedPotentials\DataTanks\d5cd55_EvokedPotentials';
% HARDBLOCK = 'Block-15';

% CHANS = [1:4 9:12 17:20 25:28];
CHANS = 1:64;
% CHANS = [35:38 43:46 51:54 59:62];

% CHANS = 1:8;
NCHANS = length(CHANS);    

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
    
    if (exist('HARDBLOCK', 'var'))
        warning('hotblock is hardcoded for debugging purposes');
        hotblock = HARDBLOCK;
    end
    
    if (isempty(hotblock))
        error('no block is currently being recorded\n');
    end

    ttx.SelectBlock(hotblock);

    % build the viz
    t = ((1:488)-122) / 12207.03;
    viz = CCEPVisualizer(CHANS, t, t > 5e-3 & t < 50e-3);


    curtime = 0;
    prevstimcurrent = 0;
    count = 0;
    
    ttx.SetGlobals('T1=0');
    
    while (true)
        % check for new events
        
        nrecs = ttx.ReadEventsSimple('Blck');
        
        if (nrecs >= 1)
            fprintf('new event found\n');

%             % get the waveform data
            newWaves = ttx.ParseEvV(0, 64);
            mapping = ttx.ParseEvInfoV(0, 64, 4);
            
        
            newWaves = newWaves(:, mapping(CHANS));

            % get the event timing
            curtime = ttx.ParseEvInfoV(0, 64, 6);
            curtime = curtime(end);
            
            % now load the current stimulator amplitude in to memory.
            % note, the Blck event is now gone...
            ttx.ReadEventsSimple('Valu');
            stimcurrent = ttx.ParseEvInfoV(0, 1, 7);

            % update T1, meaning we'll only see events later than this when we
            % check again
            curtime = curtime + 0.10; % add 100 msec
            ttx.SetGlobals(sprintf('T1=%f',curtime));
            
            % if the stimulus current has changed, clear the figure
            if (~isnan(stimcurrent))
                if (stimcurrent ~= prevstimcurrent)
                    % do reset
                    fprintf('new current found (%d), reset display\n', stimcurrent);
                    viz.reset();
                    prevstimcurrent = stimcurrent;
                    count = 0;
                end

                % draw the new waveform, update the mean
                tempWaves = newWaves - repmat(median(newWaves,1), size(newWaves, 1), 1);
                viz.update(tempWaves');
                                
                count = count + 1;
                fprintf('received %d stimuli at this current (%d)\n', count, stimcurrent);
            end
        else        
            pause(.5);
        end
    end
catch ex
    fprintf(ex.message);
    fprintf('cleaning up.\n');
    ttx.CloseTank;
    ttx.ReleaseServer;
end    
