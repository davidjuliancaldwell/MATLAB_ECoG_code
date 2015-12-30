function F = carrier2if( C )
% F = CARRIER2IF( C )
% 
% Extracts the instantaneous frequency trajectories from an ensemble of
% complex-exponential carrier signals.
% 
% INPUTS:
%   C - A vector containing one complex exponential carrier signal, or an 
%       array of multiple row-wise carriers.
%
% OUTPUTS:
%   F - A vector or array of instantaneous frequency trajectories over
%       time. Frequency values are in normalized units (Nyquist = 1).
% 
% See also if2carrier

% Revision history:
%   P. Clark - created for version 2.1, 02-25-10

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


if numel( C ) == length( C ) && size( C, 1 ) > 1
    warning( 'carrier2if:vectorCarrier', 'The modulation toolbox uses row vectors for modulators and carriers.' )
    
    C = C.';
end

% Standard normalized sampling rate for the Modulation Toolbox, which sets
% Nyquist = 1.
fs = 2;

% The first-difference operation approximates a temporal derivative of the
% carrier phases.
F = fs/(2*pi)*filter( [1 -1], 1, unwrap( angle( C ).' ) ).';    % works for Hilbert

