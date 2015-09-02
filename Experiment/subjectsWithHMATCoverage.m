function sids = subjectsWithHMATCoverage(coverageIdentifier)
% function sids = subjectsWithHMATCoverage(coverageIdentifier)
%
% retuns a list of subjects that have coverage of a given HMAT area.
% Identifier can be given as an array of integers, corresponding the the 
% numeric % associations as listed in any given hmat_areas.mat file, or 
% can be a cell array of strings corresponding to the labels themselves.
%
% key value associations are also listed here for convenience:
%  1 'RM1'
%  2 'LM1'
%  3 'RS1'    
%  4 'LS1'
%  5 'RSMA'
%  6 'LSMA'
%  7 'RpSMA'
%  8 'LpSMA'
%  9 'RPMd'
% 10 'LPMd'
% 11 'RPMv'
% 12 'LPMv'
%
% ex. say I'm interested in knowing which subjects had S1 coverage, but I
% don't care if it was left or right sided.  I would execute 
%
%  sids = subjectsWithHMATCoverage([3 4]);
%    - or alternatively -
%  sids = subjectsWithHMATCoverage({'RS1', 'LS1'});
%
% Author: JDW

    % constants
    key = {'RM1'    'LM1'    'RS1'    'LS1'    'RSMA'    'LSMA'    'RpSMA'    'LpSMA'    'RPMd'    'LPMd'    'RPMv'    'LPMv'};
    
    % setup    
    config = GetDataServerConfig();
    
    % convert coverageIdentifier if necessary
    if (isnumeric(coverageIdentifier))
        coverageInts = coverageIdentifier;
    else
        if (~iscell(coverageIdentifier))
            coverageIdentifier = {coverageIdentifier};
        end
        
        coverageInts = zeros(size(coverageIdentifier));
        
        for c = 1:length(coverageIdentifier)
            str = coverageIdentifier{c};
            [res, idx] = ismember(str, key);
            
            if (~res)
                warning('unknown string key entered: %s', str);
            else
                coverageInts(c) = idx;
            end
        end        
    end
    
    sids = {};
    
    % build the remote command
    for coverageInt = coverageInts
        cmd = BuildDataserverCommand(sprintf('grep --include=*hmat_areas.txt -rl %s -e HMAT_%d', config.DataServerRemoteDirectory, coverageInt));
        
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

function result = inputWithDefault(prompt, defaultValue)
    result = input([prompt '[' defaultValue '] :'], 's');
    
    if (isempty(result))
        result = defaultValue;
    end
end