function C = if2carrier( F )
% C = IF2CARRIER( F )
% 
% Converts an ensemble of instantaneous frequency trajectories into
% complex-exponential carrier signals.
% 
% INPUTS:
%   F - A vector containing one instantaneous frequency (IF) trajectory
%       over time, or an array of row-wise IF trajectories. Frequency
%       values must be in normalized units (Nyquist = 1).
%
% OUTPUTS:
%   C - A vector or array of phase-only complex exponentials representing
%       carrier signals corresponding to the given IF trajectories.
% 
% See also carrier2if

% Revision history:
%   P. Clark - created for version 2.1, 12-23-09

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

if numel( F ) == length( F ) && size( F, 1 ) > 1
    warning( 'if2carrier:vectorIF', 'The modulation toolbox uses row vectors for modulators and carriers.' )
    
    F = F.';
end

% Standard normalized sampling rate for the Modulation Toolbox, which sets
% Nyquist = 1.
fs = 2;

% The cumulative-sum operation approximates a temporal integration of the
% instantaneous frequency trajectories.
C = exp( j*2*pi/fs*cumsum( F.' ) ).';

