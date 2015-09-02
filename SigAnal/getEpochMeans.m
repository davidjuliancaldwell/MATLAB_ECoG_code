%% getEpochMeans.m
%  jdw - 16SEP2013
%
% Changelog:
%   16SEP2013 - originally written
%
% This function breaks signal in to epoch based chunks as specified by 
%   starts and ends.  
%
% Parameters:
%   signal - a vector length M containing the signal to break in to epochs.
%   starts - a vector containing the start offsets of each epoch
%   ends - a vector containing the end offsets of each epoch
%
% Return Values:
%   epochSignal - a matrix containing the signal, divided in to epochs.
%

function epochMeans = getEpochMeans(signal, starts, ends)
    if(length(starts) ~= length(ends))
        error('starts and ends must be of same length');
    end

    if (isempty(starts))
        epochMeans = [];
        return;
    end
    
    epochMeans = zeros(size(signal,2), length(starts));
    
    for c = 1:length(starts)
        epochMeans(:,c) = mean(signal(starts(c):ends(c)-1,:), 1);
    end; clear c;
end