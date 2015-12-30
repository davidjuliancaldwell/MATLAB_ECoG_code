function [M C F] = moddecomphilb( S )
% [M C F] = MODDECOMPHILB( S )
%
% Uses the Hilbert envelope to (incoherently) demodulate subband signals
% into real non-negative modulators and complex-exponential carriers.
%
% INPUTS:
%   S - An array of row-wise, complex-valued subband signals, which may be
%       bandpass analytic or frequency-shifted to baseband.
%
% OUTPUTS:
%   M - An array of row-wise modulator signals, guaranteed to be real and
%       non-negative.
%   C - An array of row-wise carrier signals, in the form of phase-only
%       complex exponentials.
%   F - An array of row-wise carrier instantaneous-frequency trajectories.
%
% NOTES:
%   Demodulation is a factoring algorithm. Hence S = M.*C;
%
%   See also modrecon, viewcarriers, moddecompcog, moddecompharm,
%            moddecompharmcog, modlisting

% Revision history:
%   P. Clark - prepared for beta testing, 10-29-08

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

% REFERENCE:
%   J. Dugundji, "Envelopes and Pre-Envelopes of Real Waveforms," IRE
%   Trans. Info. Theory, 1958, pp. 53-57.
% -------------------------------------------------------------------------


% If only one subband is submitted, then make sure it is treated as a row vector
if length( S(1,:) ) == 1
    S = S.';
end

% Hilbert envelope and carrier
M = abs( S );
C = exp( j*angle( S ) );

if nargout > 2
    F = carrier2if( C );
end

end % End of moddecomphilb

