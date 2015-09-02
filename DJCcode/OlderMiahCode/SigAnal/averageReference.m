%% averageReference.m
%  jdw - 11APR2011
%
% Changelog:
%   11APR2011 - originally written
%
% This function returns the common average referenced version of data.
%   data must be an MxN matrix where averaging will be done across the
%   second (N) dimension. NOTE: this function assumes all channels given
%   are good and includes them in the CAR.
%
% Parameters:
%   data - the data to be common average referenced
%
% Return Values:
%   rData - the resultant referenced data
%

function rData = averageReference(data)
    avg = mean(data,2);
    avg = repmat(avg, 1, size(data,2));
    rData = data - avg;    
end
