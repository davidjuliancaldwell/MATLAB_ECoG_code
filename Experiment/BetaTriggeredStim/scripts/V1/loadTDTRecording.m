function [ecog states] = loadTDTRecording(subjid, day, experiment, block, chans)
%     tankpath = ['C:\TDT\OpenEx\MyProjects\' experiment '\DataTanks\' subjid '_' experiment];
    tankpath = fullfile(myGetenv('subject_dir'), subjid, 'data', day, [subjid '_' experiment]);
    
    ttx = actxcontrol('TTank.X');
    ttx.ConnectServer('Local','Me');
    res = ttx.OpenTank(tankpath,'R'); % add error state here
    
    if (res == 0)
        ttx.ReleaseServer;
        error('unable to open tank');
    end
    
    ttx.SelectBlock(['Block-' num2str(block)]);
    
    start = ttx.CurBlockStartTime;
    stop = ttx.CurBlockStopTime;

    ttx.SetGlobalV('WavesMemLimit', 1024^3);
    
    [str, tchan] = setForChannel(chans(1));
    ttx.SetGlobals(sprintf('Channel=%d', tchan));
    temp = ttx.ReadWavesV(str);

    ecog.data = zeros(length(temp), length(chans));
    ecog.data(:,1) = temp;
    clear temp;
    
    for idx = 2:length(chans)
        [str, tchan] = setForChannel(chans(idx));
        fprintf('pulling from %s:%d to %d\n', str, tchan, idx);
        
        ttx.SetGlobals(sprintf('Channel=%d', tchan));
        ecog.data(:, idx) = ttx.ReadWavesV(str);
    end
        
    notesStr = ttx.CurBlockNotes;
    tokens = regexp(notesStr, 'HeadName;.*?VALUE=(\w\w\w\w).*?SampleFreq;.*?VALUE=([0-9\.]+);', 'tokens');
    
    found = false;
    for idx = 1:length(tokens)
        if (strcmp(tokens{idx}{1}, 'ECO1') && found == false)
            ecog.fs = str2num(tokens{idx}{2});
            found = true;
        end
    end
    
    fprintf('Loading trigger data');
    ttx.SetGlobals('Channel=2');  
    states.data(:,1) = ttx.ReadWavesV('SMon');
    
    fprintf('Loading mode data');    
    ttx.SetGlobals('Channel=2');  
    states.data(:,2) = ttx.ReadWavesV('Wave');
    
    found = false;
    for idx = 1:length(tokens)
        if (strcmp(tokens{idx}{1}, 'TDAT') && found == false)
            states.fs = str2num(tokens{idx}{2});
            found = true;
        end
    end     
    
    ttx.CloseTank;
    ttx.ReleaseServer;
    
end

function [str, tdtchan] = setForChannel(channel)
    if (channel <= 16)
        str = 'ECO1';
    elseif (channel <= 32)
        str = 'ECO2';
        tdtchan = channel - 16;
    elseif (channel <= 48)
        str = 'ECO3';
        tdtchan = channel - 32;
    elseif (channel <= 64)
        str = 'ECO4';
        tdtchan = channel - 48;
    end                
end