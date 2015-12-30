function y = modreconharm( M, C )
% Y = MODRECONHARM( M, C )
% 
% Synthesizes an audio signal from modulator and carrier waveforms. This
% function is primarily intended as the inverse of the MODDECOMPHARM and
% MODDECOMPHARMCOG functions.
%
% INPUTS:
%   M - An array of row-wise modulator signals. These may be downsampled by
%       an integer factor with respect to the sampling rate of the carriers
%       in C.
%   C - An array of row-wise complex exponential carrier signals. If C is a
%       vector, then integer harmonics of C will be used for however many
%       modulator signals are contained in M.
%
% OUTPUTS:
%   Y - The final synthesized audio signal, sampled at the same rate as the
%       carriers in C. Hence length(Y) = size(C,2).
%
%   See also moddecompharm, moddecompharmcog, modsynth, modlisting

% Revision history:
%   P. Clark - adapted for arbitrary carriers as well as harmonics, removed
%              residual input, changed factorinterp() to resample(), 04-21-10
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


% Check for improperly-formatted input parameters, and deduce the
% downsampling factor relating the sampling rate of the carrier(s) to that
% of the modulators.
[C dfactor] = parseInputs( M, C );

% Upsample each modulator waveform
M = resample( M.', dfactor, 1 ).';

% Correct for length mismatch between the modulator and carrier arrays,
% compensating for lost samples during downsampling/upsampling
if size(M,2) >= size(C,2)
    M = M( :, 1:size(C,2) );
else
    M = [M, zeros( size(M,1), size(C,2)-size(M,2) )];
end

if size( C, 1 ) > 1
    % C is an array of individual row-wise carrier signals
    y = real( sum( M.*C ) );
else
    % C is a vector containing a single fundamental-frequency carrier signal
    numbands = size( M, 1 );
    len = size( C, 2 );

    y = zeros( 1, len );
    
    for k = 1:numbands
        y = y + real( M( k, : ) .* C.^k );
    end
end
    
end % End modreconharm


% =========================================================================
% Helper Functions
% =========================================================================

% -------------------------------------------------------------------------
function [C dfactor] = parseInputs( M, C )

    if size( M, 1 ) ~= size( C, 1 ) && length( C ) ~= numel( C )
        error( 'The number of carriers should be either one (the fundamental) or equal to the number of modulators.' );
    end
    
    if length( C ) == numel( C ) && size( C, 1 ) ~= 1
        % Make sure the carrier is a row vector
        C = transpose( C );
    end
    
    len1 = size( C, 2 );
    len2 = size( M, 2 );
    
    dfactor = ceil( len1 / len2 );
    
    % Check upsampling dimensions
    if ceil( len1 / dfactor ) ~= len2
        warning( 'moddecompharm:dim_mismatch', 'Possible dimension mismatch: the length of the modulators should be ceil( L/D ), where L = size(C,2) and D is an integer.' )
    end
    
end % End parseInputs

