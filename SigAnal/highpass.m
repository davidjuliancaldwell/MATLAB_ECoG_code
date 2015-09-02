%% highpass.m
%  jdw - 28APR2011
%
% Changelog:
%   28APR2011 - originally written
%
% This is a helper function to quickly highpass filter a signal
%
% Parameters:
%   signals - signals to be filtered.  If signals is an MxN array, the
%     vectors of length M, indexed by the N dimension will be treated as
%     independent signals and filtered as such.
%   hpFreq - the haighpass cutoff frequency
%   fSamp - the sampling rate of signals
%   filterOrder (optional) - the filter order of the butterworth filter to
%     be used.  The default value is 4th order.
%
% Return Values:
%   filteredSignals - the filtered signals
%

function filteredSignals = highpass(signals, hpFreq, fSamp, filterOrder, causality)
    if (~exist('filterOrder', 'var'))
        filterOrder = [];
    end
    if (~exist('causality', 'var'))
        causality = 'acausal';
    end

    filteredSignals = ecogFilter(signals, false, 0, true, hpFreq, false, 0, fSamp, filterOrder, causality);
end