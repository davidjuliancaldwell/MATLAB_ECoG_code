%% notch.m
%  jdw - 28APR2011
%
% Changelog:
%   28APR2011 - originally written
%
% This is a helper function to quickly notch filter a signal
%
% Parameters:
%   signals - signals to be filtered.  If signals is an MxN array, the
%     vectors of length M, indexed by the N dimension will be treated as
%     independent signals and filtered as such.
%   lnFreqs - the frequencies around which to center the notch filters
%   fSamp - the sampling rate of signals
%   filterOrder (optional) - the filter order of the butterworth filter to
%     be used.  The default value is 4th order.
%
% Return Values:
%   filteredSignals - the filtered signals
%

function filteredSignals = notch(signals, lnFreqs, fSamp, filterOrder)
    if (~exist('filterOrder', 'var'))
        filteredSignals = ecogFilter(signals, true, lnFreqs, false, 0, false, 0, fSamp);
    else
        filteredSignals = ecogFilter(signals, true, lnFreqs, false, 0, false, 0, fSamp, filterOrder);
    end
end