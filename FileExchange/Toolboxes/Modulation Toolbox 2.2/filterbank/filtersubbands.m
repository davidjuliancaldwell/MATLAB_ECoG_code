function S = filtersubbands( x, filtbankparams )
% S = FILTERSUBBANDS( X, FILTBANKPARAMS )
%
% Filters an input audio signal into a collection of subband signals based
% on a filterbank design obtained from DESIGNFILTERBANK or DESIGNFILTERBANKSTFT.
%
% INPUTS:
%                X - A vector time-series.
%   FILTBANKPARAMS - A struct containing filterbank implementation information
%                    obtained from DESIGNFILTERBANK or DESIGNFILTERBANKSTFT.
% 
% OUTPUTS:
%                S - An array of row-wise complex subband signals. The
%                    first row corresponds to the lowest-frequency subband.
%                    If X is real-valued, then S will consist only of
%                    subbands with non-negative center frequencies. If X is
%                    complex-valued, then S will contain all subbands with
%                    center frequencies 0 up to the sampling rate.
%
%   See also filterbanksynth, designfilterbank, designfilterbankstft,
%            filterbankfreqz, modlisting

% Revision history:
%   P. Clark - updated for version 2.1, 09-02-10
%   P. Clark - prepared for beta testing, 02-02-09

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


parseInputs( x, filtbankparams );

% The rest of the function assumes a column-vector input
if size( x, 1 ) == 1
    x = x.';
end

if filtbankparams.stft

    win    = filtbankparams.afilters{1};
    hop    = filtbankparams.dfactor(1);
    nfft   = filtbankparams.numhalfbands;
    fshift = filtbankparams.fshift;
    
    % Uniform filterbank based on the short-time Fourier transform
    S = STFT( x, win, hop, nfft, fshift );

    % Remove the causal phase characteristic of the analysis filter, which
    % will otherwise cause neighboring subbands to destructively interfere
    % in the transition bands (assuming a symmetric filter here).
    nmid = ( length( win ) - 1 ) / 2;     % window midpoint
    W = windowphaseterm( nmid, nfft );
    S = diag( conj( W ) ) * S;
    
    % Keep only the first half of the STFT rows, or the analytic subbands
    % corresponding to the upper half of the unit circle (if input is
    % real-valued)
    if ~any( imag( x ) )
        S = S( 1:filtbankparams.numbands, : );
    end
    
else
    % General multirate filterbank using different filters for each
    % subband, so each frequency band must be filtered separately
    maxLen = maxSubbandLen( length(x), filtbankparams );
    
    % Determine whether or not to filter the negative frequencies of X,
    % which is necessary when X is complex-valued in the time domain.
    if isreal( x )
        S = zeros( filtbankparams.numbands, maxLen );
    else
        S = zeros( filtbankparams.numhalfbands, maxLen );
    end
    
    for k = 1:filtbankparams.numbands

        % Obtain subband-specific parameters
        center  = index( filtbankparams.centers, k );    % center frequency
        h       = index( filtbankparams.afilters, k );   % FIR analysis kernel
        dfactor = index( filtbankparams.dfactor, k );    % downsample factor
        
        % Filter one analytic subband
        subband = bandpassFilter( x, center, h, dfactor, filtbankparams.fshift );
        S( k, : ) = padToMatch( subband, maxLen );
        
        if center == 0 || center == 1
            continue;
        end
        
        % Complex phase term for undoing the causal phase
        % characteristic of the subband filter (simulating a
        % modulate-then-shift operation on a non-causal lowpass
        % prototype filter). See also windowphaseterm()
        n0 = ( length( h ) - 1 ) / 2;
        W  = exp( j*pi*center*n0 );
        S( k, : ) = conj( W )*S( k, : );
        
        if any( imag( x ) )
            % Repeat the filter operation for the negative frequencies, but
            % only if the subband filter is not centered on 0 or Nyquist.
            subband = bandpassFilter( x, -center, h, dfactor, filtbankparams.fshift );
            
            % Index into the S array, where row numbers 1:L go
            % around the unit circle of frequencies 0:2*pi*(L-1)/L.
            if filtbankparams.centers(1) == 0
                ind = filtbankparams.numhalfbands - k + 2;
            else
                ind = filtbankparams.numhalfbands - k + 1;
            end
            
            % IND is the conjugate symmetric index of the for-loop index K.
            S( ind, : ) = W*padToMatch( subband, maxLen );
        end
    end
end

% If the input signal is real-valued, then we adopt the convention of
% multiplying each analytic subband signal by a factor of 2. This means
% that x \approx real( sum( S ) ). Of course, the factor of 2 only applies
% to truly analytic (bandpass) signals, which excludes the lowpass
% (center=0) and Nyquist (center=1) bands. The synthesis function
% FILTERBANKSYNTH undoes the factor of 2.
if ~any( imag( x ) )
    hilbertGain = 1 + ( filtbankparams.centers ~= 0 & filtbankparams.centers ~= 1 );
    S = full( diag( sparse(hilbertGain) )*S );
end

% Trim subband filter transients
if ~filtbankparams.keeptransients
    S = trimfiltertransients( S, filtbankparams, length( x ) );
end

end % End filtersubbands


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function S = STFT( x, win, hop, nfft, fshift )
% Computes the short-time Fourier transform of x, where win is the analysis
% window, hop is the window skip (or downsampling factor), and fshift is a
% boolean. If fshift = 1, the demodulated STFT is computed, where each
% subband is frequency-shifted to baseband. This implementation of the STFT
% ensures that the resulting matrix is identical to the output of a
% CAUSAL multirate filterbank.
    
    % Undersampling the DFT results in time aliasing for each frame, so if
    % nfft < window length, we can segment the analysis window into
    % multiple aliasing components
    winLen = length( win );
    winpoly = convbuffer( win(end:-1:1), nfft, 0, nfft );
    
    % Buffer the data into frames and apply the first window component,
    % making sure that the first frame contains only the first sample of x
    % as if starting at the far left edge in a convolution operation.
    S = convbuffer( x, nfft, -winLen+1, hop );
    S = diag( sparse( winpoly(:,1) ) ) * S;
    
    % Separately add any time-aliasing terms
    for k = 2:ceil( winLen / nfft )
        Stemp = convbuffer( x, nfft, -winLen+1+(k-1)*nfft, hop );
        Stemp = diag( sparse( winpoly(:,k) ) ) * Stemp;
        Ltemp = length( Stemp(1,:) );
        S( :, 1:Ltemp ) = S( :, 1:Ltemp ) + Stemp;
    end
    
    % Rotate each frame of data according to a modulo shift operation,
    % referenced either to a window sliding through time (first case) or to
    % a fixed global time in the case of sliding the signal through a
    % stationary window (second case). These cases relate to whether the
    % STFT subbands are respectively shifted to baseband or left at their
    % original center frequencies.
    if fshift
        S = colcircshift( S, mod( -winLen+1:hop:length(x), nfft ) );
    else
        S = circshift( S, -winLen+1 );
    end

    % Compute the DFT along each column (for each frame), truncating or
    % zero-padding as dictated by nfft
    S = fft( S, nfft );
    
end % End STFT


% -------------------------------------------------------------------------
function subband = bandpassFilter( x, center, h, dfactor, fshift )
% Implements a bandpass filter using a lowpass filter kernel, where the
% resulting subband signal can be either bandpass or frequency-shifted to
% baseband.

    % Subbands can either be bandpass signals or lowpass signals (after
    % a frequency shift).
    if fshift
        % Downshift x to obtain lowpass subband signals
        xmod = vmult( x, exp( -j*pi*center*(0:length(x)-1) ) );
    else
        % Upshift the filter to obtain bandpass subband signals
        xmod = x;
        h = vmult( h, exp( j*pi*center*(0:length(h)-1) ) );
    end

    % Decimate (filter and downsample)
    if dfactor >= (length(h)-1)/128
        % Poly-phase implementation is efficient for large downsampling
        % factors and small-order filters
        subband = upfirdn( xmod, h, 1, dfactor );
    else
        % fastconv(), which uses fftfilt(), is efficient for small
        % downsampling factors and large-order filters
        subband = downsample( fastconv( h, xmod ), dfactor );
    end

end  % End bandpassFilter


% -------------------------------------------------------------------------
function B = convbuffer( x, winlen, startindex, hop )
% A modified version of Matlab's buffer() function that simulates a
% convolution operation, where each window contains the data for one shift
% in a downsampled convolution.
% The signal x contains data samples that start at index 0. Everything
% prior to index 0 is assumed to be zeros.
% The integer winlen is the length of the resulting data frames.
% The integer startindex is the index of the left-most sample in the
% first window position. This is typically less than or equal to zero.
% The integer hop is the amount by which the window skips, or the
% downsampling factor.

    % Make sure x is a column vector
    x = x(:);
    
    % The number of frames to expect given the starting location of the
    % sliding window, and the hop distance
    numframes = ceil( ( length(x) - startindex ) / hop );
    
    % Determine the number of zeros to prepend to x.
    if startindex <= 0
        leadin = zeros( -startindex, 1 );
        n1 = 1;
    else
        leadin = [];
        n1 = startindex + 1;
    end
    
    % Zeros to append to x.
    tail = zeros( (numframes-1)*hop+winlen - length(x) - length(leadin), 1 );
    
    if hop < winlen
        opt = 'nodelay';
    elseif hop > winlen
        opt = 0;
    else
        opt = [];
    end
    
    % Use Matlab's buffer() function with a pre-conditioned version of x
    B = buffer( [leadin; x(n1:end); tail], winlen, winlen-hop, opt );

end % End convbuffer


% -------------------------------------------------------------------------
function X = colcircshift( X, shifts )
% Circularly shift each column of X by a different amount, as specified by
% the shifts vector

    for i = 1:length( X(1,:) )
        X( :, i ) = circshift( X( :, i ), shifts( i ) );
    end

end % End colcircshift


% -------------------------------------------------------------------------
function obj = index( vec, k )
% Extracts the kth element from the the vector vec, except when vec is a
% scalar or single-element array.

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
function xpadded = padToMatch( x, L )
% Zero-pads the signal x (a column vector) to length L.

    xpadded = [x; zeros( L - length(x), 1 )];

end % End padToMatch


%--------------------------------------------------------------------------
function [maxLen k] = maxSubbandLen( L, fbparams )
% Returns the maximum subband length, post-filtering and downsampling,
% given the signal length L and the filterbank parameters fbparams.

    [maxLen k] = max( ceil( ( L + fbparams.afilterorders ) ./ fbparams.dfactor ) );

end % End maxSubbandLen


% -------------------------------------------------------------------------
function y = vmult( x1, x2 )
% Multiplies two vectors element-wise, regardless of orientation.

    s1 = size( x1 );
    s2 = size( x2 );
    
    if numel(x1) ~= max(s1) || numel(x2) ~= max(s2)
        error( 'Vector input is required for vmult()' )
    end
    
    if s1(1) == 1 && s2(1) ~= 1 || s1(2) == 1 && s2(2) ~= 1
        y = x1 .* x2.';
    else
        y = x1 .* x2;
    end

end % End vmult


% -------------------------------------------------------------------------
function y = fastconv( h, x )
% Convolve the columns of X with the filter H, using the overlap-add FFT
% method as implemented by an augmented version of fftfilt().

    y = fftfilt( h, [x; zeros( length(h)-1, size(x,2) )] );
    
end % End fastconv


% -------------------------------------------------------------------------
function W = windowphaseterm( nmid, nfft )
% W is the phase offset between a causal and non-causal window.
% Conceptually, the product conj(W[k])*h_k[n] simulates a filter that was
% modulated and then shifted in time rather than the other way around (or
% alternatively, an STFT using a non-causal window and then delayed at the
% end). This in effect aligns the modulating carrier with the window's
% midpoint as if the window were initially non-causal. It turns out that
% modulating a bunch of causal windows into bandpass filters results in a
% discontinuous filterbank phase response which induces subband
% interference in the transition bands.

    W  = zeros( nfft, 1 );
    if mod( nfft, 2 ) == 0
        % Even-length nfft has a frequency sample at Nyquist
        W( 1:nfft/2 ) = exp( j*2*pi*(0:nfft/2-1)/nfft*nmid );
        W( nfft/2+1 ) = 1;
        W( end:-1:nfft/2+2 ) = conj( W( 2:nfft/2 ) );
    else
        % Odd-length nfft has no Nyquist sample
        W( 1:(nfft+1)/2 ) = exp( j*2*pi*(0:(nfft+1)/2-1)/nfft*nmid );
        W( end:-1:(nfft+1)/2+1 ) = conj( W( 2:(nfft+1)/2 ) );
    end

end % End windowphaseterm


% -------------------------------------------------------------------------
function S2 = trimfiltertransients( S, filtbankparams, origlen )    
% Cut off subband filter transients from both ends of each subband signal,
% assuming linear-phase filters and identical downsampling in each band.

    newlen = ceil( origlen / filtbankparams.dfactor );
    S2 = zeros( size(S,1), newlen );
    
    for k = 1:size( S,1 )
        n1 = ceil( ( 1 + index( filtbankparams.afilterorders, k ) / 2 ) / filtbankparams.dfactor );
        n2 = n1 + newlen - 1;
        S2( k, : ) = S( k, n1:n2 );
    end 
    
end % End trimfiltertransients


% -------------------------------------------------------------------------
function parseInputs( x, fbparams )
% Check the parameters for errors

    if numel( x ) > length( x )
        error( 'Vector input is required for x.' )
    end
    
    if fbparams.stft
        % Error checks copied from designfilterbankpr()
        winlen = length( fbparams.afilters{1} );
        
        if winlen < 2
            error( 'winlen must be greater than 1.' )
        elseif mod( winlen, 1 ) ~= 0
            error( 'winlen must be an integer.' )
        end

        if fbparams.fshift ~= 0 && fbparams.fshift ~= 1
            error( 'fshift must be a boolean, 1 or 0.' )
        end

        if length( fbparams.dfactor ) > 1
            error( 'dfactor must be a scalar (one value for all subbands).' )
        end

        if fbparams.dfactor < 1 || mod( fbparams.dfactor, 1 ) ~= 0
            error( 'dfactor must be a positive integer greater than zero.' )
        end

        if fbparams.numhalfbands < 1 || mod( fbparams.numhalfbands, 1 ) ~= 0
            error( 'numhalfbands must be a positive integer greater than zero.' )
        end
        if winlen > fbparams.numhalfbands && mod( winlen / fbparams.numhalfbands, 2 ) ~= 1
            error( 'The analysis window length divided by numhalfbands must be an odd integer.' )
        end

    else
        % Error checks copied from designfilterbank()
        if length( fbparams.centers ) > 1 && sum( fbparams.centers( 2:end ) < fbparams.centers( 1:end-1 ) ) > 0
            error( 'Subband center frequencies must be strictly increasing.' );
        elseif min( fbparams.centers ) < 0  || max( fbparams.centers ) > 1
            error( 'Subband center frequencies must be in the range [0 1].' );
        end

        if min( fbparams.bandwidths ) <= 0  || max( fbparams.bandwidths ) >= 2
            error( 'Subband bandwidths must be in the range (0 2), non-inclusive.' );
        elseif length( fbparams.bandwidths ) > 1 && length( fbparams.bandwidths ) ~= fbparams.numbands
            error( 'The number of subband bandwidths must be one or equal to the number of subband centers.' )
        end

        if length( fbparams.dfactor ) > 1 && length( fbparams.dfactor ) ~= fbparams.numbands
            error( 'The number of downsampling factors must be one or equal to the number of subband centers.' )
        elseif ~prod( double( fbparams.dfactor >= 1 ) ) || ~prod( double( mod( fbparams.dfactor, 1 ) == 0 ) )
            error( 'dsamplefactors must contain positive integers greater than zero.' )
        end

        if fbparams.fshift ~= 0 && fbparams.fshift ~= 1
            error( 'fshift must be a boolean, 1 or 0.' )
        end
    end

end % End parseInputs

