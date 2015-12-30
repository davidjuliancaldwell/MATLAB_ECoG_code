function [M C F] = moddecompharm( x, F0, numharmonics, modbandwidth, transbandwidth, dfactor )
% [M C F] = MODDECOMPHARM( X, F0, <NUMHARMONICS>, <MODBANDWIDTH>, <TRANSBAND>, <DFACTOR> )
% 
% Demodulates a fullband signal relative to harmonic carriers based on a
% given fundamental frequency track.
% 
% INPUTS:
%                 X - A real-valued vector time-series.
%                F0 - A vector fundamental frequency track, with the same
%                     length as X, and normalized such that Nyquist = 1.
%    <NUMHARMONICS> - The number of harmonic carriers to use, which is also
%                     the number of modulator waveforms to extract from X.
%                     The default is floor(1/max(F0)), which is the maximum
%                     allowed by the sampling rate of X.
%    <MODBANDWIDTH> - The bandwidth lowpass modulator extraction filter, in
%                     normalized frequency (Nyquist = 1). Hence the kth
%                     modulator is the basebanded version of the frequency
%                     range k*F0 +/- MODBANDWIDTH/2. The default is min( F0 ).
%       <TRANSBAND> - The transition bandwidth of the extraction filter, in
%                     normalized frequency (Nyquist = 1). The default is
%                     MODBANDWIDTH / 10.
%         <DFACTOR> - The integer downsampling factor to use on the modulator
%                     waveforms. The default value is 1 (no downsampling).
%
% OUTPUTS:
%                 M - An array of row-wise, complex-valued modulator signals.
%                 C - An array of row-wise harmonic carrier signals, in the
%                     form of phase-only complex exponentials.
%                 F - An array of row-wise carrier instantaneous-frequency
%                     trajectories, where F(k,:) = k*F0.
%
%   See also detectpitch, modreconharm, viewcarriers, moddecompharmcog,
%            moddecompcog, moddecomphilb, modlisting

% Revision history:
%   P. Clark - replaced array-filtering method with iterative demodulation
%              for less memory overhead, changed default numharmonics,
%              added TRANSBAND parameter, 08-24-10
%   P. Clark - changed reference to narrowbandfilter(), altered lowpass
%              filter cutoff, replaced for-loops with array operations,
%              removed hilbert transform, 06-29-10
%   P. Clark - prepared for beta testing, 04-14-09

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

% REFERENCES:
%   [1] S. Schimmel and L. Atlas, "Target talker enhancement in hearing
%       devices," Proc. IEEE ICASSP, April 2008.
%   [2] B. King and L. Atlas, "Coherent modulation comb filtering for
%       enhancing speech in wind noise," Proc. IWAENC, September 2008.
%   [3] C.S. Ramalingam and R. Kumaresan, "Voiced-speech analysis based on
%       the residual interfering signal canceler (RISC) algorithm," Proc.
%       IEEE ICASSP, April 1994.
% -------------------------------------------------------------------------


% Check for the required multirate filter functions
if isempty( which( 'designfilter' ) ) || isempty( which( 'narrowbandfilter' ) )
    error( 'MODDECOMPHARM requires the DESIGNFILTER() and NARROWBANDFILTER() functions located in the FILTER subfolder of the Modulation Toolbox.' )
end

% Set the sampling frequency for 2 Hz so that Nyquist = 1 (this is the
% standard frequency normalization scheme used throughout the toolbox)
fs = 2;

if nargin < 2 || isempty( F0 )
    error( 'MODDECOMPHARM requires F0 as an input.' )
end
if nargin < 3 || isempty( numharmonics )
    numharmonics = max( 1, floor( fs/2 / max( F0 ) ) );
end
if nargin < 4 || isempty( modbandwidth )
    modbandwidth = min( F0 );
end
if nargin < 5 || isempty( transbandwidth )
    transbandwidth = modbandwidth / 10;
end
if nargin < 6 || isempty( dfactor )
    dfactor = 1;
end

% Check for improperly formatted input parameters
[x F0] = parseInputs( x, F0, numharmonics, modbandwidth, dfactor );

% The factor of 2 ensures that real( M.*C ) is approximately equal to x).
x = 2*x;

% Demodulation filtering parameters: time-varying frequency shift followed
% by lowpass filtering with approximate -3dB cutoff of modbandwidth/2.
filtorder = nearestEven( 6.6 / transbandwidth );

try
    % Instantaneous-frequency and carrier signal arrays, where each row is
    % one carrier signal over time. This may result in an out-of-memory
    % error, in which case the less memory intensive recursive method will
    % execute in the catch.
    F = full( diag( sparse( 1:numharmonics ) ) * repmat( F0, numharmonics, 1 ) );
    C = if2carrier( F );
    M = repmat( x, numharmonics, 1 ).*conj( C );
    M = arrayfilter( M, length( x ), filtorder, modbandwidth, transbandwidth, dfactor );
catch
    % Repeated demodulation and baseband filtering by the fundamental
    % carrier, which uses less memory overhead than array filtering.
    C = if2carrier( F0 );
    M = harmrecursfilt( x, C, numharmonics, filtorder, modbandwidth, transbandwidth, dfactor );
end

end % End moddecompharm


% =========================================================================
% Helper Functions
% =========================================================================

function M = arrayfilter( M, xlen, filtorder, modbandwidth, transbandwidth, dfactor )

    if dfactor >= filtorder/128
        % Polyphase decimation (more efficient for large DFACTOR/MODBANDWIDTH
        % ratio)
        h = fir1( filtorder, modbandwidth/2 );
        M = upfirdn( M.', h, 1, dfactor ).';

        % Truncate transients
        n1 = ceil( ( 1 + filtorder/2 ) / dfactor );
        n2 = n1 + ceil( xlen / dfactor ) - 1;
        M = M( :, n1:n2 );
    else
        % Multirate filter implementation followed by downsampling (more
        % efficient for small DFACTOR/MODBANDWIDTH ratio), with implicit
        % transient truncation
        h = designfilter( [0 (modbandwidth-transbandwidth)/2], 'pass', transbandwidth, [0.001 0.01] );
        M = downsample( narrowbandfilter( M, h, 1 ).', dfactor ).';
    end

end % End arrayfilt


% -------------------------------------------------------------------------
function M = harmrecursfilt( x, C0, numharmonics, filtorder, modbandwidth, transbandwidth, dfactor )

    if dfactor >= filtorder/128
        % Polyphase decimation (more efficient for large DFACTOR/MODBANDWIDTH
        % ratio)
        h = fir1( filtorder, modbandwidth/2 );
        filtoption = 1;
        
        % Truncate transients
        n1 = ceil( ( 1 + filtorder/2 ) / dfactor );
        n2 = n1 + ceil( length( x ) / dfactor ) - 1;
        
        finallen = n2 - n1 + 1;
        
    else
        % Multirate filter implementation followed by downsampling (more
        % efficient for small DFACTOR/MODBANDWIDTH ratio), with implicit
        % transient truncation
        h = designfilter( [0 (modbandwidth-transbandwidth)/2], 'pass', transbandwidth, [0.001 0.01] );
        filtoption = 2;
        
        finallen = ceil( length( x ) / dfactor );
    end
    
    xshift = x;
    M = zeros( numharmonics, finallen );
    
    % Demodulate the lowest harmonic from the recursively frequency-shifted
    % input signal
    for k = 1:numharmonics

        xshift = xshift.*conj( C0 );
        
        if filtoption == 1
            temp = upfirdn( xshift, h, 1, dfactor );
            M( k, : ) = temp( :, n1:n2 );
        else
            M( k, : ) = downsample( narrowbandfilter( xshift, h, 1 ), dfactor );
        end
    end

end % End harmrecursfilt


% -------------------------------------------------------------------------
function [x f0] = parseInputs( x, f0, numharmonics, modbandwidth, dfactor )
% Checks for impropertly formatted input parameters and displays error
% messages

    sx = size( x );
    sf = size( f0 );

    % Make sure that the input time series are row vectors
    if prod( sx ) ~= max( sx )
        error( 'The input time series x must be a vector' );
    end
    if prod( sf ) ~= max( sf )
        error( 'The input pitch trajectory f0 must be a vector' );
    end
    
    x = reshape( x, 1, length(x) );
    f0 = reshape( f0, 1, length(f0) );

    if length( f0 ) ~= length( x )
        error( 'The length of the pitch trajectory must equal the length of the time series.' )
    end
    if sum( f0 <= 0 ) > 0
        warning( 'moddecompharm:minF0', 'The pitch values should be greater than zero.' )
    end
    if max( f0 ) > 1
        warning( 'moddecompharm:maxF0', 'The pitch values do not appear to be properly normalized for Nyquist rate = 1. All values of F0 must be between +/- 1.' )
    end
    
    if numharmonics <= 0 || numharmonics > 1/max(f0) || mod( numharmonics, 1 ) ~= 0
        error( 'NUMHARMONICS must be a positive integer less than or equal to 1/max(F0)' )
    end
    
    if modbandwidth <= 0 || modbandwidth >= 2
        error( 'MODBANDWIDTH must be between 0 and 2, non-inclusive.' )
    end
    
    if dfactor < 1 || mod( dfactor, 1 ) ~= 0
        error( 'DFACTOR must be a positive integer.' )
    end
    
end % End parseInputs


% -------------------------------------------------------------------------
function y = nearestEven( x )
% Converts the floating-point value x to the nearest even integer.

    y = x;
    
    if mod( x, 2 ) == 0
        return;
    elseif mod( x, 2 ) < 1
        y = floor( x );
    elseif mod( x, 2 ) > 1
        y = ceil( x );
    elseif mod( x, 2 ) == 1
        y = x + 1;
    end

end   % End nearestEven

