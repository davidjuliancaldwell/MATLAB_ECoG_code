function [M C F Fmeasured] = moddecompcog( S, carrWin, carrWinHop, centers, bandwidths )
% [M C F FPRIME] = MODDECOMPCOG( S, CARRWIN, <CARRWINHOP>, <CENTERS>, <BANDWIDTHS> )
%
% Demodulates subband signals relative to a time-varying carrier frequency
% (spectral center-of-gravity) for each subband.
% 
% INPUTS:
%              S - An array of row-wise, complex-valued subband signals,
%                  which may be bandpass analytic or frequency-shifted to
%                  baseband.
%        CARRWIN - The length (in samples) of the carrier-detection window,
%                  which defines the number of samples to use when computing 
%                  the average subband frequency for one moment in time.
%                  CARRWIN can also be a vector, to specify the shape of the
%                  spectral estimation window (the default is Hamming).
%   <CARRWINHOP> - The skip distance (in samples) to use when computing the
%                  subband carrier frequencies. Increasing this parameter
%                  will decrease computation time at the expense of losing
%                  detail in the carrier frequency estimates. The default
%                  is ceil( CARRWIN/2 ).
%      <CENTERS> - A vector defining the center frequencies of the subbands,
%                  or a scalar defining a common center of all subbands,
%                  with values in normalized frequency units [-1, 1]. The
%                  default is 0.
%   <BANDWIDTHS> - A vector defining the subband bandwidths, or a scalar
%                  defining the common bandwidth of all subbands, with
%                  values in normalized frequency units [0, 2]. The default
%                  is 2.
% 
% OUTPUTS:
%              M - An array of row-wise, complex-valued modulator signals.
%              C - An array of row-wise carrier signals, in the form of
%                  phase-only complex exponentials.
%              F - An array of row-wise carrier instantaneous-frequency
%                  trajectories.
%         FPRIME - the actual measured carrier frequencies, before
%                  upsampling to obtain F. FPRIME therefore has the same
%                  number of rows as S but the number of columns will be
%                  ceil( size(S,2) / CARRWINHOP ).
%
%   Notes:
%   1) Demodulation is a factoring algorithm. Hence S = M.*C;
%   2) Together, <CENTERS> and <BANDWIDTHS> constrain the carrier-frequency
%      of each subband to within the ideal bandlimits of each subband signal.
% 
% See also modrecon, viewcarriers, moddecompharm, moddecompharmcog,
%          moddecomphilb, modlisting

% Revision history:
%   P. Clark - changed carrWin to be a required input, changed default
%              carrWinHop to half the window length, fixed bugs in
%              spectralCOG(), 04-05-10
%   P. Clark - prepared for beta testing, 4-20-09

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

% REFERENCES:
%   [1] P.J. Loughlin and B. Tacer, "On the Amplitude- and
%       Frequency-Modulation Decomposition of Signals," J. Acoust. Soc.
%       Am., vol. 100, no. 3, pp. 1594–1601, 1996.
%   [2] A. Papoulis, "Random Modulation: A Review," IEEE Trans. Acoust.,
%       Speech, Sig. Proc., vol. ASSP-31, no. 1, February 1983.
%   [3] L. Mandel, "Complex Representation of Optical Fields in Coherence
%       Theory," J. Opt. Soc. Am., vol. 57, no. 5, May 1967.
% -------------------------------------------------------------------------


if nargin < 5 || isempty( bandwidths )
    bandwidths = 2;
end
if nargin < 4 || isempty( centers )
    centers = 0;
end
if nargin < 3
    carrWinHop = [];
end
if nargin < 2
    %carrWin = hamming( length( S(1,:) ) )';
    error( 'MODDECOMPCOG() requires at least two inputs (as of version 2.1).' )
end

% If only one subband is submitted, then make sure it is a row vector
if length( S(1,:) ) == 1
    S = S.';
end

% Subband matrix dimensions
sdim = size( S );
numBands = sdim( 1 );
ncols = sdim( 2 );

% Get parameters and check for errors
[w1 w2 carrWin carrWinLen carrWinHop] = parseInputs( sdim, carrWin, carrWinHop, centers, bandwidths );

numFrames = ceil( ncols / carrWinHop );
Fmeasured = zeros( numBands, numFrames );
F = zeros( numBands, ncols );

% The DFT size is the nearest power of 2 greater than the carrier-detection
% window length
DFTsize = 2^ceil( log2( carrWinLen ) );

% This loop iterates over subbands, computing the time-varying spectral
% center-of-gravity for each one.
for k = 1:numBands
    
    subband = S( k, : );
    
    if carrWinLen == ncols
        % This case computes the stationary IF estimate using one spectral
        % COG computation over the entire time interval for one subband.
        P = abs( fft( carrWin.*subband, DFTsize ) ).^2;
        Fmeasured( k, : ) = spectralCOG( P, index( w1, k ), index( w2, k ) );
        F( k, : ) = Fmeasured( k, 1 );
        continue
    end

    % For the nonstationary case, the spectral COG is allowed to vary with
    % time as measured by a sliding window. This operation could use a
    % buffer command instead of a for-loop, but a loop eliminates the
    % potentially large overhead of storing a matrix of frames.
    leftEdge = 1 - ceil( carrWinLen / 2 );
    n1 = 1;
    n2 = leftEdge + carrWinLen - 1;
    
    % Iterate over frame locations within the subband signal
    for i = 1:numFrames
        
        % Compute the spectral COG for one time-limited frame of data,
        % where the first frame is centered on the first sample of the
        % subband. The last frame will end centered on the last sample of
        % the subband, provided that ncols = k*carrWinHop + 1, where k is
        % an integer.
        if n1 == 1
            % The sliding window is at the beginning of the signal
            zeropad = zeros( 1, n2 );
            frame = [zeropad, carrWin( end-n2+1:end ) .* subband( n1:n2 )];
        elseif n2 == ncols
            % The sliding window is at the end of the signal
            zeropad = zeros( 1, carrWinLen-n2+n1-1 );
            frame = [carrWin( 1:n2-n1+1 ) .* subband( n1:n2 ), zeropad];
        else
            % The sliding window is anywhere in the middle of the signal
            frame = carrWin .* subband( n1:n2 );
        end
        
        % Periodogram estimate of the short-time power spectral density
        P = abs( fft( frame, DFTsize ) ).^2;
        Fmeasured( k, i ) = spectralCOG( P, index( w1, k ), index( w2, k ) );
        
        % Advance the frame position in time
        leftEdge = leftEdge + carrWinHop;
        n1 = max( leftEdge, 1 );
        n2 = min( leftEdge + carrWinLen - 1, ncols );
    end
    
    % Upsample the instantaneous frequency estimate, so that each point in
    % time has an IF measurement
    L = min( 4, floor( (numFrames-1)/2 ) );
    Ftemp = factorinterp( Fmeasured( k, : ), carrWinHop, L, 0.25 );
    F( k, : ) = Ftemp( 1:ncols );
end

% DEPRECATED: resample() assumes the signal is zero before and after the
% given samples, so it causes bad transient responses at both ends of the
% signal after lowpass filtering. Using interp(), as above, avoids
% transients by symmetrizing the signal before n = 0 in order to
% estimate sensible initial conditions.
% if carrWinHop > 0
%     F = resample( Fmeasured.', carrWinHop, 1, 100 ).';
%     F = F( 1:numBands, 1:ncols );
% end

C = if2carrier( F );
M = S .* conj( C );

end % End moddecompcog


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

    factors = factor( R );
    
    y = x;
    
    for i = 1:length( factors )
        y = interp( y, factors( i ), L, cutoff );
    end
    
end % End factorinterp


% -------------------------------------------------------------------------
function obj = index( vec, k )
% Extracts the kth element from the the vector vec, except when vec is a
% scalar or single-element array

    if iscell( vec ) && numel( vec ) == 1   % cell array with one element
        obj = vec{ 1 };
    elseif iscell( vec )        % cell array with (presumably) at least k elements
        obj = vec{ k };
    elseif numel( vec ) == 1    % scalar
        obj = vec;
    else
        obj = vec( k );     % array with (presumably) at least k elements
    end

end % End index


% -------------------------------------------------------------------------
function [w1 w2 carrWin carrWinLen carrWinHop] = parseInputs( sdim, carrWin, carrWinHop, centers, bandwidths )
% Determine algorithm parameters based on user-provided inputs, and check
% for errors.
    
    numBands = sdim( 1 );
    ncols = sdim( 2 );

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
    
    if carrWinLen >= ncols
        % The carrier detection window is larger than the data, so it
        % doesn't make sense to have a time-varying estimate. Instead,
        % a single spectral COG for the entire length of data will be
        % computed.
        warning( 'moddecompcog:stationaryCOG_1', 'The carrier window length is greater than the subband length. Defaulting to stationary spectral COG carrier estimate.' )
        carrWinLen = ncols;
        carrWin = hamming( carrWinLen );
        carrWinHop = ncols;
    elseif ceil( ncols / carrWinHop ) < 8
        % If the carrier window-hop distance is too large, then the
        % interpolation of the full IF trajectory will be noisy. This
        % warning alerts the user to a potential problem in computing the
        % carrier with a large window hop.
        warning( 'moddecompcog:stationaryCOG_2', 'Not enough IF data points for interpolation. Defaulting to stationary spectral COG carrier estimate.' )
        carrWinLen = ncols;
        carrWin = hamming( carrWinLen );
        carrWinHop = ncols;
    end

    % Convert the carrier detection window to a row vector
    if length( carrWin(1,:) ) == 1
        carrWin = transpose( carrWin );
    end
    
    % If given an empty vector, assume that the spectral COG should be
    % taken over the entire frequency axis
    if isempty( bandwidths )
        bandwidths = 2;
    end

    % If given an empty vector, assume that the spectral COG interval
    % should center at 0
    if isempty( centers )
        centers = 0;
    end
    
    % Check for improperly formated subband centers and bandwidths
    if length( centers ) ~= 1 && length( centers ) ~= numBands
        error( 'The number of subband centers must be one or equal to the number of subbands.' )
    end
    if length( bandwidths ) ~= 1 && length( bandwidths ) ~= numBands
       error( 'The number of subband bandwidths must be one or equal to the number of subbands.' )
    end
    if min( centers ) < -1 || max( centers ) > 1
        error( 'Subband center frequencies must be normalized between -1 and 1 inclusive.' )
    end
    if min( bandwidths ) < 0 || max( bandwidths ) > 2
        error( 'Subband bandwidths must be normalized between 0 and 2 inclusive.' )
    end
    
    % Orient both as column vectors for easier addition in the next
    % if-statement
    centers = centers(:);
    bandwidths = bandwidths(:);

    % Compute subband frequency bounds
    w1 = centers - bandwidths / 2;
    w2 = centers + bandwidths / 2;
    
end % End parseInputs

