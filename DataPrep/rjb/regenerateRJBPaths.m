function result = regenerateRJBPaths(files)
    % files is a list of files BCI2000 recording files for which to
    % generate paths
    result = arrayfun(@regenerateRJBPath, files);
end

function result = regenerateRJBPath(filepath)
    TEMP_DIR = 'd:\temp\rjb';
    
    filepath = filepath{:};
    
    if (~strendswith(filepath, '.dat'))
        result = 0;
        return;
    end
    
    [directory, filebase, fileext] = fileparts(filepath);
    indat  = fullfile(TEMP_DIR, [filebase fileext]);
    outpar = fullfile(TEMP_DIR, [filebase '.prm']);
    
    TouchDir(TEMP_DIR);
    
    [sig, sta, par] = load_bcidat(filepath);
    
    % force the application window on to the primary screen
    par.WindowLeft.NumericValue = 0;
    par.WindowLeft.Value = {'0'};
    
    par.DataDirectory.Value = {TEMP_DIR};
    
    % get rid of any cyberglove or data glove data
    fields = fieldnames(sta);
    
    for c = 1:length(fields)
        if (strfind(fields{c}, 'Cyber'))
            sta = rmfield(sta, fields{c});
        end
    end
    
    par = checkForFieldAndRemove(par, 'EnableGlove');
    par = checkForFieldAndRemove(par, 'COMPort');
    par = checkForFieldAndRemove(par, 'BaudRate');
    par = checkForFieldAndRemove(par, 'Handedness');
    par = checkForFieldAndRemove(par, 'VisualizeCyberglove');
    
    % write out the new BCI2000 dat file to be used for playback
    save_bcidat(indat, sig, sta, par);

    % determine the target sequence order
    sequence = extractTargetSequence(sta);
    
    % build a text string that corresponds to the pararmeter file
    partext = convert_bciprm(par);
    partext{end+1} = ...
        sprintf('Source:Playback:FilePlaybackADC string PlaybackFileName= %s // the path to the existing BCI2000 data file (inputfile)', indat);
%     partext{end+1} = ...
%         sprintf('Source:Playback:FilePlaybackADC int PlaybackStates= 1 0 0 1 // play back state variable values (except timestamps)? (boolean)');
    seqstr = [num2str(length(sequence)) ' ' sprintf('%d ', sequence)];
    partext{end+1} = ...
        sprintf('Application:Targets:FeedbackTask intlist TargetSequence= %s%% %% // fixed sequence in which targets should be presented (leave empty for random)', seqstr);

    writehandle = fopen(outpar, 'w');
    
    for l = 1:length(partext)
        % due to a 'bug' in fileplayback module
        if (~isempty(strfind(partext{l}, 'Expressions')))
            partext{l} = strrep(partext{l}, 'Expressions= 1 1', 'Expressions= 1 0');
        end
        
        fprintf(writehandle, '%s\n', partext{l});
    end
    
    fclose(writehandle);
    
    result = 1;
end

function par = checkForFieldAndRemove(par, fieldname)
    if (isfield(par, fieldname))
        par = rmfield(par, fieldname);
    end    
end