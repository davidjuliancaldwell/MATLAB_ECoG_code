function AnonymizeCodes(subjID, dirToStartIn)

    if dirToStartIn(end) ~= '\'
        dirToStartIn(end+1) = '\';
    end

    patientDir = [dirToStartIn subjID '\'];

    ProcessDir(patientDir, subjID)
%     ProcessDir(dirToStartIn, subjID);
    
    fprintf('DONE\n');
end

function ProcessDir(directory, subjID)

    subDirs = dir(directory);
    subDirs = subDirs([subDirs.isdir]);
    subDirs = {subDirs.name};
    
    subFiles = dir(directory);
    subFiles = subFiles(~[subFiles.isdir]);
    subFiles = {subFiles.name};

    
    for next = subFiles
        fullFile = [directory next{:}];
        locs = regexp(next{:},['(?i)' subjID], 'once');
        if ~isempty(locs)
            fprintf('Converting file %s...\n', fullFile);
            oldFile = fullFile;
            newFile = [directory strrep(next{:},subjID,genPID(subjID))];
            cmd = sprintf('movefile(''%s'', ''%s'');', oldFile, newFile);
            eval(cmd);
        end
    end
    


    
    for target=subDirs
        if strcmp(target{:},'..') == 1 || strcmp(target{:},'.') == 1
            continue
        end
        ProcessDir([directory target{:} '\'], subjID);
    end
    
    slashies = find(directory == '\',2,'last');
    if isempty(slashies)
        return;
    end
    subDirHasSubjID = regexp(directory(slashies(1):slashies(2)),['(?i)' subjID], 'once');
    if isempty(subDirHasSubjID)
        return
    end
    fprintf('Converting directory %s...\n', directory);
    oldDir = directory;
    newDir = [directory(1:slashies(1)) strrep(directory(slashies(1)+1:slashies(2)),subjID,genPID(subjID))];
    cmd = sprintf('movefile(''%s'', ''%s'');', oldDir, newDir);
    eval(cmd);
end
