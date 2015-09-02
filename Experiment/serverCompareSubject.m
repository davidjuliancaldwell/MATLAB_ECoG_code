function serverCompareSubject(sid, doSilent)
    if (nargin < 2)
        doSilent = false;
    end
    
    config = GetDataServerConfig();

    %% get the local list of subject files
    if (~doSilent)
        fprintf('getting local file list: '); tic;
    end
    
    localSubjectDir = fullfile(myGetenv('subject_dir'), sid);
    localFileList = findfiles(localSubjectDir, '', true, true);
    
    searchStr = strrep([stripExtraSlashes(localSubjectDir) filesep], '\', '\\');    
    temp = regexp(localFileList, searchStr, 'split');

    if (strcmp(localSubjectDir, temp{1}{1}))
        temp(1) = []; % drop the root directory
    end
    
    onLocalOnly = cell(size(temp));
    for c = 1:length(onLocalOnly)
        onLocalOnly{c} = temp{c}{2};
    end
    
    if (~doSilent)
        toc;
    end
    
    %% get the remote list of subject files
    if (~doSilent)
        fprintf('getting remote file list: '); tic;
    end
    
    remoteSubjectDir = [config.DataServerRemoteDirectory sid];    
    cmd = BuildDataserverCommand(sprintf('find %s', remoteSubjectDir));

    % execute it
    [result, output] = system(cmd);

    if (result ~= 0 || isempty(output))
        error('failed retrieving info from krang: %s', output);
    end
    
    % and finally, parse the result    
    matchstr = ['(' remoteSubjectDir '.*?)' char(10)];
    toks = regexpi(output, matchstr, 'tokens');
    
    if (strcmp(remoteSubjectDir, toks{1}{1}))
        toks(1) = []; % drop the root directory
    end
    
    remoteFileList = [toks{:}];

    searchStr = [remoteSubjectDir '/'];    
    temp = regexp(remoteFileList, searchStr, 'split');
    
    onServerOnly = cell(size(temp));
    for c = 1:length(onServerOnly)
        onServerOnly{c} = temp{c}{2};
    end
    
    if (~doSilent)     
        toc;
    end
    
    %% no do comparison of file structure
    [onBoth, iRemote, iLocal] = intersect(onServerOnly, strrep(onLocalOnly,filesep, '/'));
    
    onServerOnly(iRemote) = [];
    onLocalOnly(iLocal) = [];
        
    %%
    if (~doSilent)
        fprintf('\n\n\nfiles on server only: \n');
        for c = 1:length(onServerOnly)
            fprintf('[REMOTE SUB DIR]/ %s\n', onServerOnly{c});
        end
        
        fprintf('\n\n\nfiles on local only: \n');
        for c = 1:length(onLocalOnly)
            fprintf('[LOCAL SUB DIR]\\ %s\n', onLocalOnly{c});
        end        
    end
end