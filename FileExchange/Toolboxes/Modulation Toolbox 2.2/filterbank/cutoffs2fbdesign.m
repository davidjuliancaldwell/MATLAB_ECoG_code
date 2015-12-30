function [centers bandwidths] = cutoffs2fbdesign( cutoffs )
% [CENTERS BANDWIDTHS] = CUTOFFS2FBDESIGN( CUTOFFS )
%
% Converts frequency cutoff values to subband center frequencies and
% bandwidths, compatible with DESIGNFILTERBANK.
% 
% INPUTS:
%   CUTOFFS - A list of subband cutoff frequencies, non-decreasing, in the
%             interval [0, 1] inclusive. Each pair of adjacent cutoff
%             values defines the bandlimits of one subband. Include 0
%             and/or 1 to define baseband and highpass subbands.
%
%             EXAMPLE 1:
%               CUTOFFS = [0.2 0.4 0.7] indicates two subbands with
%               bandwidths equal to 0.2 and 0.3
%
%             EXAMPLE 2:
%               CUTOFFS = [0 0.2 0.4 0.7 1] indicates four subbands with
%               bandwidths equal to 0.4 (symmetric baseband around zero),
%               0.2, 0.3, and 0.6 (symmetric highpass about Nyquist).
% 
% OUTPUTS:
%             CENTERS - A list of subband center frequencies normalized between
%                       0 and 1, compatible with DESIGNFILTERBANK.
%          BANDWIDTHS - A list of subband -6dB bandwidths, normalized between
%                       0 and 2, compatible with DESIGNFILTERBANK.
% 
% See also designfilterbank, modlisting

% Revision history:
%   P. Clark - modified input format, 08-05-10
%   P. Clark - created, 11-16-09

% Contact:
%   Pascal Clark (UW EE)    : clarkcp @ u.washington.edu
%   Prof. Les Atlas (UW EE) :   atlas @ u.washington.edu
%   
%   http://modulation.ee.washington.edu/
%   http://isdl.ee.washington.edu/projects/modulationtoolbox/

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                    %
%    Modulation Toolbox version 2.1                                  %
%    Copyright (c) ISDL, University of Washington, 2010.             %
%                                                                    %
%    This software is distributed for evaluation purposes only,      %
%    and may not be used for any commercial activity. It remains     %
%    the property of ISDL, University of Washington.                 %
%    Modification of this software for personal use is allowed.      %
%    Redistribution of this software is prohibited.                  %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Default parameter values
if cutoffs(1) == 0
    cutoffs = cutoffs( 2:end );
    includeBaseband = 1;
else
    includeBaseband = 0;
end
if cutoffs(end) == 1
    cutoffs = cutoffs( 1:end-1 );
    includeNyquist = 1;
else
    includeNyquist = 0;
end

% Check inputs for errors
if length( cutoffs ) > 1 && sum( cutoffs( 2:end ) < cutoffs( 1:end-1 ) ) > 0
    error( 'Subband cutoff frequencies must be strictly increasing.' );
elseif min( cutoffs ) <= 0  || max( cutoffs ) >= 1
    error( 'Subband cutoff frequencies must be in the range (0 1) non-inclusive.' );
end

% Determine the subband center frequencies and banwidths based on how the
% given cutoffs partition of the frequency axis 
bandwidths = [2*cutoffs(1) cutoffs(2:end)-cutoffs(1:end-1) 2*(1-cutoffs(end))];
centers    = [0 (cutoffs(1:end-1)+cutoffs(2:end))/2 1];

% Remove the baseband and/or Nyquist subbands if necessary
if ~includeBaseband
    bandwidths = bandwidths( 2:end );
    centers    = centers( 2:end );
end
if ~includeNyquist
    bandwidths = bandwidths( 1:end-1 );
    centers    = centers( 1:end-1 );
end

