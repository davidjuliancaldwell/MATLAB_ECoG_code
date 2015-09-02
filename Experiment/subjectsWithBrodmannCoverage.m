function sids = subjectsWithBrodmannCoverage(brodmannAreas)
% function sids = subjectsWithBrodmannCoverage(brodmannAreas)
%
% retuns a list of subjects that have coverage of a given Brodmann area.
% brodmannAreas is a single integer or an array of integers.
%
% ex. say I'm interested in knowing which subjects had coverage of BA 6, 
% I would execute 
%
%  sids = subjectsWithBrodmannCoverage(6);
%
% Author: JDW

    % setup    
    config = GetDataServerConfig();
    
    % build the remote command
    for brodmannArea = brodmannAreas
        cmd = BuildDataserverCommand(sprintf('grep --include=*brod_areas.txt -rl %s -e BRODMANN_%d', config.DataServerRemoteDirectory, brodmannArea));
        
        % execute it
        [result, output] = system(cmd);

        if (result ~= 0 || isempty(output))
            warning('received empty result from data server');
        else

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
    end    
end