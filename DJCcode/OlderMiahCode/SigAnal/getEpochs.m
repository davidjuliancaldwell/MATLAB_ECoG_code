%% getEpochs.m
%  jdw - 19JUN2011
%
% Changelog:
%   19JUN2011 - originally written
%   31JUL2012 - added forceEqualLength flag
%
% This function gives the start and stop offsets of data epochs that
%   correspond to the stimulus code specified by interest.
%
% Parameters:
%   codes - the time-variant stimulus codes to search for epochs
%   interest - the stimulus code of interest to search for
%
% Return Values:
%   starts - a vector containing the start offsets of each epoch
%   ends - a vector containing the end offsets of each epoch
%   forceEqualLength (optional) - boolean determining whether or not to
%     eliminate epochs that don't have the same length as the majority of
%     epochs
%

function [starts, ends] = getEpochs(codes, interest, forceEqualLength)
    if (~exist('forceEqualLength', 'var'))
        forceEqualLength = false;
    end
    
    if (size(codes,1) == length(codes))
        codes = codes';
    end
    
    temp = double(codes);
    
    % mask only the code of interest
    masked = (temp == interest);

    % find where these epochs start and stop
    dmasked = diff(masked);
    dmasked = [dmasked(1) dmasked];

    starts = find(dmasked > 0);
    ends   = find(dmasked < 0);
    
    if (temp(1) == interest)
        % add an extra start at the beginning
        starts = [1 starts];
    end
    if (temp(end) == interest)
        % add an extra end at the end
        ends = [ends length(temp)];
    end    
    
    if (forceEqualLength)
         uncommonIdxs = ((ends-starts) ~= mode(ends-starts));
         starts(uncommonIdxs) = [];
         ends(uncommonIdxs) = [];
    end
end