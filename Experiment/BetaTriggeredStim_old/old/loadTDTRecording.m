function [ecog, states] = loadTDTRecording(subjid, experiment, block)
    tankpath = ['C:\TDT\OpenEx\MyProjects\' experiment '\DataTanks\' subjid '_' experiment '\'];
    
    ttx = actxcontrol('TTank.X');
    ttx.ConnectServer('Local','Me');
    ttx.OpenTank(tankpath,'R');
    ttx.SelectBlock(['Block-' num2str(block)]);
    
    start = ttx.CurBlockStartTime;
    stop = ttx.CurBlockStopTime;

    ttx.SetGlobalV('WavesMemLimit', 1024^3);
    
    ecog.data = cat(2, ...
        ttx.ReadWavesV('ECO1'), ...
        ttx.ReadWavesV('ECO2'), ...
        ttx.ReadWavesV('ECO3'), ...
        ttx.ReadWavesV('ECO4'));
        
    notesStr = ttx.CurBlockNotes;
    tokens = regexp(notesStr, 'HeadName;.*?VALUE=(\w\w\w\w).*?SampleFreq;.*?VALUE=([0-9\.]+);', 'tokens');
    
    found = false;
    for idx = 1:length(tokens)
        if (strcmp(tokens{idx}{1}, 'ECO1') && found == false)
            ecog.fs = str2num(tokens{idx}{2});
            found = true;
        end
    end
    
    states.data = cat(2, ...
        ttx.ReadWavesV('TDAT'), ...
        ttx.ReadWavesV('SMon'));

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