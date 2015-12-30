function [M C F] = moddecompharmcog( x, F0, carrWin, carrWinHop, numcarriers, modbandwidth, transbandwidth, dfactor )
% [M C F] = MODDECOMPHARMCOG( X, F0, CARRWIN, <CARRWINHOP>, <NUMCARRIERS>, <MODBANDWIDTH>, <TRANSBAND>, <DFACTOR> )
% 
% Demodulates a fullband signal relative to quasi-harmonic carriers, which
% are based on a given fundamental frequency reference but refined with
% individual spectral center-of-gravity refinement.
% 
% INPUTS:
%                 X - A real-valued vector time-series.
%                F0 - A vector fundamental frequency track, with the same
%                     length as X, and normalized such that Nyquist = 1.
%           CARRWIN - The length (in samples) of the carrier-detection window,
%                     which defines the number of samples to use when computing 
%                     the average subband frequency for one moment in time.
%                     CARRWIN can also be a vector, to specify the shape of the
%                     spectral estimation window (the default is Hamming).
%      <CARRWINHOP> - The skip distance (in samples) to use when computing the
%                     subband carrier frequencies. Increasing this parameter
%                     will decrease computation time, at the expense of
%                     losing detail in the carrier frequency estimates. The
%                     default is ceil( CARRWIN/2 ).
%     <NUMCARRIERS> - The number of harmonic carriers to use, which is also
%                     the number of modulator waveforms to extract from X.
%                     The default 1/max(F0), which is the maximum allowed
%                     by the sampling rate of X.
%    <MODBANDWIDTH> - The bandwidth of the lowpass modulator extraction
%                     filter normalized frequency (Nyquist = 1). Hence the
%                     kth modulator is the basebanded version of the
%                     frequency range k*F0 +/- MODBANDWIDTH/2. The default
%                     is min( F0 ).
%       <TRANSBAND> - The transition bandwidth of the extraction filter, in
%                     normalized frequency (Nyquist = 1). The default is
%                     MODBANDWIDTH / 10.
%         <DFACTOR> - The integer downsampling factor to use on the modulator
%                     waveforms. The default value is 1 (no downsampling).
%
% OUTPUTS:
%                 M - An array of row-wise, complex-valued modulator signals.
%                 C - An array of row-wise of quasi-harmonic carrier
%                     signals, in the form of phase-only complex exponentials.
%                 F - An array of row-wise carrier instantaneous-frequency
%                     trajectories.
%
%   See also detectpitch, modreconharm, viewcarriers, moddecompharm,
%            moddecompcog, moddecomphilb, modlisting

% Revision history:
%   P. Clark - integrated with version 2.1, 08-20-10
%   E. Saba - created and alpha tested, 12-14-09
%   B. King - initial concept, xx-xx-07

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

% REFERENCE:
%   [1] Q. Li and L. Atlas, "Coherent modulation filtering for speech,"
%       Proc. IEEE ICASSP, April 2008.
% -------------------------------------------------------------------------


% Set the sampling frequency for 2 Hz so that Nyquist = 1 (this is the
% standard frequency normalization scheme used throughout the toolbox)
fs = 2;

% Provide default values for the optional parameters if they are left
% unspecified
if nargin < 3 || isempty( F0 ) || isempty( carrWin )
    error( 'MODDECOMPHARMCOG requires F0 and carrWin as inputs.' )
end
if nargin < 4
	carrWinHop = [];    % default hop is dependent on carrWin so leave empty for now
end
if nargin < 5 || isempty( numcarriers )
    numcarriers = max( 1, floor( fs/2 / max( F0 ) ) );
end
if nargin < 6 || isempty( modbandwidth )
    modbandwidth = min( F0 );
end
if nargin < 7 || isempty( transbandwidth )
    transbandwidth = modbandwidth / 10;
end
if nargin < 8 || isempty( dfactor )
    dfactor = 1;
end

% Check for improperly formatted input parameters
[x F0] = parseharminputs( x, F0, numcarriers, modbandwidth, dfactor );
[carrWin carrWinLen carrWinHop] = parsecoginputs( length(x), carrWin, carrWinHop );

% Set up output arrays
numFrames = ceil( length(x) / carrWinHop );
cogEstimate = zeros( numcarriers, numFrames );
F = zeros( numcarriers, length(x) );

% The factor of 2 ensures that real( M.*C ) is approx. equal to x).
x = 2*x;

% Set the starting 'left-edge' of the sliding window, normally a negative
% number so that the window starts centered at time = 0.
if numFrames > 1
    leftEdge = 1 - ceil( carrWinLen / 2 );
else
    leftEdge = 1;
end

% Set up sliding-window endpoints
n1 = 1;
n2 = leftEdge + carrWinLen - 1;

% The DFT size is the nearest power of 2 greater than the carrier-detection
% window length
DFTsize = 2^ceil( log2( carrWinLen ) );

% This loop calculates the spectral center-of-gravity in several frequency
% bands, each corresponding to a different carrier, within a sliding
% temporal window.
for f = 1:numFrames

    if n1 == 1
        % The sliding window is at the beginning of the signal
        zeropad = zeros( 1, n2 );
        frame = [zeropad, carrWin( end-n2+1:end ) .* x( n1:n2 )];
    elseif n2 == length(x)
        % The sliding window is at the end of the signal
        zeropad = zeros( 1, carrWinLen-n2+n1-1 );
        frame = [carrWin( 1:n2-n1+1 ) .* x( n1:n2 ), zeropad];
    else
        % The sliding window is anywhere in the middle of the signal
        frame = carrWin .* x( n1:n2 );
    end
    
    % Periodogram estimate of the short-time power spectral density
    P = abs( fft( frame, DFTsize ) ).^2;
    
    % Estimate the spectral COG for each carrier frequency band of interest
    for k = 1:numcarriers
        w1 = k*F0( (f-1)*carrWinHop+1 ) - modbandwidth/2;
        w2 = k*F0( (f-1)*carrWinHop+1 ) + modbandwidth/2;
        cogEstimate( k, f ) = spectralCOG( P, w1, w2 );
    end
    
    % Advance the frame position in time
    leftEdge = leftEdge + carrWinHop;
    n1 = max( leftEdge, 1 );
    n2 = min( leftEdge + carrWinLen - 1, length(x) );
end

% Interpolate the instantaneous frequency estimates and demodulate the
% input signal x by each carrier estimate
for k = 1:numcarriers
    % Upsample the instantaneous frequency estimate, so that each point in
    % time has an IF measurement
    if size( cogEstimate, 2 ) > 1
        L = min( 4, floor( (numFrames-1)/2 ) );
        temp = factorinterp( cogEstimate( k, : ), carrWinHop, L, 0.25 );
        F( k, : ) = temp( 1:length(x) );
    else
        F( k, : ) = cogEstimate( k ) + zeros( 1, length(x) );
    end
end

% Carrier and modulator definitions follow directly from the
% instantaneous frequency estimate
C = if2carrier( F );

% Demodulate: time-varying frequency shift followed by lowpass filtering
% with approximate -3dB cutoff of modbandwidth/2
filtorder = nearestEven( 6.6 / transbandwidth );
M = repmat( x, numcarriers, 1 ).*conj( C );

if dfactor >= filtorder/128
    % Polyphase decimation (more efficient for large DFACTOR/MODBANDWIDTH
    % ratio)
    h = fir1( filtorder, modbandwidth/2 );
    M = upfirdn( M.', h, 1, dfactor ).';
    
    % Truncate transients
    n1 = ceil( ( 1 + filtorder/2 ) / dfactor );
    n2 = n1 + ceil( length( x ) / dfactor ) - 1;
    M = M( :, n1:n2 );
else
    % Multirate filter implementation followed by downsampling (more
    % efficient for small DFACTOR/MODBANDWIDTH ratio), with implicit
    % transient truncation
    h = designfilter( [0 (modbandwidth-transbandwidth)/2], 'pass', transbandwidth, [0.001 0.01] );
    M = downsample( narrowbandfilter( M, h, 1 ).', dfactor ).';
end

end % End moddecompharmcog


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function w0 = spectralCOG( P, w1, w2 )
% w0 = spectralCOG( P, w1, w2 )
%
% Given a positive spectral estimate, this function computes the spectral
% center of gravity (aka, center of energy, first moment, etc.) between the
% frequency bounds w1 and w2 (normalized such that 1 = Nyquist).

% In the event that w1 = w2, this function will compute the spectral COG
% over the entire frequency axis. Any real-valued signal (with symmetric
% spectrum) will then output a spectral COG of zero.

    if w1 > w2
        error( 'The left frequency bound of the subband must be less than or equal to the right bound.' )
    end

    N = length( P );

    k1 = mod( round( w1*N/2 ), N ) + 1;
    k2 = mod( round( w2*N/2 ), N ) + 1;

    % An ambiguity arises when w1 and w2 are equivalent, which is
    % indistinguishable from the case where k1 = k2 because w1 and w2 are
    % close together. Here we detect the wideband case and nudge k1 over so
    % that k1 > k2 and w0 will be the COG over the entire spectrum.
    if k1 == k2 && w2-w1 == 2
        k1 = k1+1;
    end
        
    if k1 <= k2
        % No circularity (w1 and w2 are both positive/negative)
        kRange = (k1:k2);
        omega = 2/N*(0:1:N-1);       % freq axis, 0 to 2
    elseif k1 > k2
        % Account for circularity (w1 is negative while w2 is positive)
        kRange = [k1:N, 1:k2];
        omega = 2/N*[0:1:floor(N/2), floor(N/2)+1-N:1:-1];    % -1 to 1
    end
    
    if sum( P ) > 0
        % The center-of-gravity, or first-moment, calculation, treating the
        % spectrum as a probability distribution
        w0 = sum( omega( kRange ).*P( kRange ) ) / sum( P( kRange ) );
    else
        % There is no energy in the spectrum, so return the
        % midpoint of the frequency range
        w0 = mean( [w1 w2] );
    end
    
end % End spectralCOG


% -------------------------------------------------------------------------
function y = factorinterp( x, R, L, cutoff )
% Successively interpolates the vector x by the factors of R, which greatly
% speeds up execution time for large R. Of course, there is an advantage
% only when R is not prime. 2*L is the number of original samples to use in
% each interpolation stage, meaning the interpolation filter is of order
% 2*Rk*L at the kth stage. Cutoff is the presumed bandlimit of x. The
% interp() function will design an interpolating filter with "don't care"
% regions in frequency based on the bandwidth of x.

    if R == 1
        y = x;
        return
    end
    
    factors = factor( R );
    
    y = x;
    
    for i = 1:length( factors )
        y = interp( y, factors( i ), L, cutoff );
    end
    
end % End factorinterp


% -------------------------------------------------------------------------
function [x f0] = parseharminputs( x, f0, numharmonics, modbandwidth, dfactor )
% Checks for impropertly formatted input parameters and displays error
% messages. This code is a direct copy from the sub-function parseInputs()
% in moddecompharm().

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

end % End parseharminputs


% -------------------------------------------------------------------------
function [carrWin carrWinLen carrWinHop] = parsecoginputs( xlen, carrWin, carrWinHop )
% Determine algorithm parameters based on user-provided inputs, and check
% for errors. This code is a mostly copied from the parseInputs()
% sub-function in moddecompcog().
    
    % Determine the carrier detection window
    if numel( carrWin ) == 1
        if carrWin < 1 || mod( carrWin, 1 ) ~= 0
            error( 'The carrier window length must be a positive integer.' )
        end
        % Default Hamming window shape
        carrWinLen = carrWin;
        carrWin = hamming( carrWinLen )';
        
    elseif numel( carrWin ) > 1
        % User-defined window shape
        carrWinLen = length( carrWin );
    else
        % An empty array, in which case throw an error (user-defined window
        % length is a required input as of version 2.1)
        error( 'Please specify a carrier-detection window length.' )
    end

    % Check for errors in the carrier window hop distance
    if isempty( carrWinHop )
        carrWinHop = ceil( carrWinLen / 2 );
    end
    if carrWinHop < 1 || mod( carrWinHop, 1 ) ~= 0
        error( 'The carrier window hop distance must be a positive integer.' )
    end
    
    if carrWinLen >= xlen
        % The carrier detection window is larger than the data, so it
        % doesn't make sense to have a time-varying estimate. Instead,
        % a single spectral COG for the entire length of data will be
        % computed.
        warning( 'moddecompharmcog:stationaryCOG_1', 'The carrier window length is greater than or equal to the signal length. Defaulting to stationary spectral COG carrier estimate.' )
        carrWinLen = xlen;
        carrWin = hamming( carrWinLen );
        carrWinHop = xlen;
    elseif ceil( xlen / carrWinHop ) < 8
        % If the carrier window-hop distance is too large, then the
        % interpolation of the full IF trajectory will be noisy. This
        % warning alerts the user to a potential problem in computing the
        % carrier with a large window hop.
        warning( 'moddecompharmcog:stationaryCOG_2', 'Not enough IF data points for reliable interpolation. Consider decreasing the COG carrier window hop distance.' )
    end

    % Convert the carrier detection window to a row vector
    if length( carrWin(1,:) ) == 1
        carrWin = transpose( carrWin );
    end
    
end % End parsecoginputs


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

