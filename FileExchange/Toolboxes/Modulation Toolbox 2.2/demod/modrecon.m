function S = modrecon( M, C )
% S = MODRECON( M, C )
%
% Synthesizes complex subband signals from modulator and carrier waveforms.
% This function is primarily intended as the inverse of the MODDECOMPHILB
% and MODDECOMPCOG functions.
%
% INPUTS:
%   M - An array of row-wise modulator signals.
%   C - An array of row-wise complex exponential carrier signals, with
%       equal dimensions to that of M.
%
% OUTPUTS:
%   S - The final synthesized subband signals, with equal dimensions to
%       that of M and C.
%
%   See also moddecomphilb, moddecompcog, modsynth, modlisting

% Revision history:
%   P. Clark - prepared for beta testing, 10-29-08

% Contact:
%   Pascal Clark (UWEE)    : clarkcp @ u.washington.edu
%   Prof. Les Atlas (UWEE) :   atlas @ u.washington.edu
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


if prod( double( size( M ) == size( C ) ) ) == 0
    error( 'M and C must have the same matrix dimensions.' )
end

S = M .* C;

