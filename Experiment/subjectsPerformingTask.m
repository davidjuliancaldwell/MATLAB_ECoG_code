function sids = subjectsPerformingTask(str)
% function sids = subjectsPerformingTask(str)
%
% retuns a list of subjects that performed a given task
% or rather, queries krang for a list of file paths within the data
% directory that contain a given keyword, and then extract subject ids from
% the results of that query.
%
% ex. say I'm interested in knowing which subjects performed goal_bci, I
% would execute 
%  sids = subjectsPerformingTask('goal');
%
% and sids is a cell array of subject ids for whom there were one or more
% file paths with the term goal in them.

    config = GetDataServerConfig();
    
    % build the remote command
    cmd = BuildDataserverCommand(sprintf('find %s -name ''*%s*''', config.DataServerRemoteDirectory, str));

    % execute it
    [result, output] = system(cmd);

    if (result ~= 0 || isempty(output))
        error('failed retrieving info from krang: %s', output);
    end

    % and finally, parse the result
    res = textscan(output, '%s ');
    res = res{1};

    sids = {};

    for c = 1:length(res)
        val = regexp(res{c}, '/m-gridlab/gridlab/subjects/([a-z0-9]+)/', 'tokens');

        if ~isempty(val)
            sid = val{1}{1};
            
            if (~ismember(sid, sids))
                sids{end+1} = sid;
            end
        end
    end
end

function result = inputWithDefault(prompt, defaultValue)
    result = input([prompt '[' defaultValue '] :'], 's');
    
    if (isempty(result))
        result = defaultValue;
    end
end