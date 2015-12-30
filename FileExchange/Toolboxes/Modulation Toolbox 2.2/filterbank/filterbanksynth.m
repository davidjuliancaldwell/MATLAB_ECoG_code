function y = filterbanksynth( S, filtbankparams )
% Y = FILTERBANKSYNTH( S, FILTBANKPARAMS )
%
% Combines complex subband signals to form an audio signal, acting as the
% inverse operation of FILTERSUBBANDS.
% 
% INPUTS:
%                S - An array of row-wise complex-valued subband signals.
%   FILTBANKPARAMS - A struct containing filterbank implementation information,
%                    obtained from DESIGNFILTERBANK or DESIGNFILTERBANKSTFT.
%
% OUTPUTS:
%                Y - The output row-vector time-series representing the
%                    synthesized time-domain signal.
%
%   See also filtersubbands, designfilterbank, designfilterbankstft,
%            filterbankfreqz, modlisting

% Revision history:
%   P. Clark - removed TRUNCATE option, 09-02-10
%   P. Clark - updated for version 2.1, 04-21-10
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


parseInputs( S, filtbankparams );

if filtbankparams.stft
    % Synthesis based on the inverse short-time Fourier transform
    
    % Get STFT parameters
    win    = filtbankparams.sfilters{1};
    hop    = filtbankparams.dfactor(1);
    nfft   = filtbankparams.numhalfbands;
    fshift = filtbankparams.fshift;
    freqdownsample = length( filtbankparams.afilters{1} ) / filtbankparams.numhalfbands;
    
    % If the number of rows in S is equal to NUMBANDS, then that means S
    % is associated with subband signals from an analytic signal. This
    % if-statement undoes the analytic-signal transform so that the final
    % synthesis results in a real-valued signal output.
    if size( S, 1 ) == filtbankparams.numbands

        % Undo the gain factor of 2 (see FILTERSUBBANDS)
        hilbertGain = 1 + ( filtbankparams.centers ~= 0 & filtbankparams.centers ~= 1 );
        S = full( diag( 1./sparse(hilbertGain) )*S );
        
        % Complete the unit circle by adding Hermitian symmetric replicas
        % of the non-DC subbands (and non-Nyquist for an even number of
        % subbands)
        if mod( filtbankparams.numhalfbands, 2 ) == 1
            % Odd number of subbands --> there is no Nyquist band
            S = [S; conj( S(end:-1:2, : ) )];
        else
            % Even number of subbands --> there is a Nyquist band
            S = [S; conj( S(end-1:-1:2, : ) )];
        end
    end
    
    % This restores the causal phase characteristic of the subbands prior
    % to applying the causal ISTFT. See also the counterpart operation in
    % filtersubbands().
    nmid = ( length( filtbankparams.afilters{1} ) - 1 ) / 2;
    W = windowphaseterm( nmid, nfft );
    S = diag( W ) * S;
    
    if ~filtbankparams.keeptransients
        % Delay the subband array so that S is properly reference to the
        % absolute time reference used by ISTFT (do this only if the
        % start-up transients have been cut off)
        n1 = ceil( ( 1 + filtbankparams.afilterorders(1) / 2 ) / filtbankparams.dfactor );
        S = [zeros( size(S,1), n1-1 ), S];
    end
    
    % Apply the inverse short-time Fourier transform and remove initial
    % group delay
    [y grpDelay] = ISTFT( S, win, hop, fshift, freqdownsample );
    y = y( 1+floor(grpDelay) : end );
    
    if filtbankparams.keeptransients
        % floor() and ceil() accomodate non-integer group delay
        y = y( 1 : end-ceil(grpDelay) );
    else
        % Remove just the synthesis-stage transients, since the analysis
        % stage transients have already been trimmed
        synthDelay = ( length( win ) - 1 ) / 2;
        y = y( 1 : end-ceil(synthDelay) );
    end
    
    % The synthesized signal might have a small imaginary part due to
    % processing error - this heurstic removes trivial imaginary artifact
    if norm( imag(y) ) / norm( real(y) ) < 1e-3
        y = real( y );
    end
    
else
    % General multirate filterbank synthesis
    
    % Compute the final post-processing length
    L = length( S(1,:) );
            
    % Cut off transients from both ends in order to make the reconstructed
    % signal equal in length to the original. To do this properly, we need
    % to estimate the original signal length
    if filtbankparams.keeptransients
        finallen = min( L*filtbankparams.dfactor - filtbankparams.afilterorders );
    else
        finallen = min( L*filtbankparams.dfactor );
    end
    
    y = zeros( 1, finallen );

    for k = 1:filtbankparams.numbands

        % Obtain subband-specific parameters
        center  = index( filtbankparams.centers, k );         % center frequency
        g       = index( filtbankparams.sfilters, k );        % FIR synthesis kernel
        dfactor = index( filtbankparams.dfactor, k );         % downsample factor
        order1  = index( filtbankparams.afilterorders, k );   % decimating filter order
        order2  = index( filtbankparams.sfilterorders, k );   % interpolating filter order
        
        if center ~= 1
            % Complex phase term for undoing the causal phase
            % characteristic of the subband filter (simulating a
            % modulate-then-shift operation on a non-causal lowpass
            % prototype filter)
            n0 = ( length( g ) - 1 ) / 2;
            W = exp( j*pi*center*n0 );
            S( k, : ) = conj( W )*S( k, : );
        end
        
        % This function call upsamples, filters, and/or frequency-shifts
        % each subband signal, depending on the filterbank specifications
        yk = bandpassExpansion( S( k, : ), center, g, dfactor, filtbankparams.fshift );
        
        if size( S, 1 ) == filtbankparams.numbands
            % In this case, S came from a real-valued signal (i.e.,
            % the rows of S correspond only to positive center frequencies)
            yk = real( yk );
            
        elseif size( S, 1 ) == filtbankparams.numhalfbands && center ~= 0 && center ~= 1
            % In this case, S came from a complex-valued signal and each
            % bandpass component yk consists of contributions from
            % half-bands centered at positive and negative frequencies
            if filtbankparams.centers(1) == 0
                ind = filtbankparams.numhalfbands - k + 2;
            else
                ind = filtbankparams.numhalfbands - k + 1;
            end
            
            yk = yk + bandpassExpansion( W*S( ind, : ), -center, g, dfactor, filtbankparams.fshift );
        end
        
        % Compensate for group delay (considering both analysis and
        % synthesis stages) so that all subbands align temporally
        if filtbankparams.keeptransients
            % Cut off filter transients (analysis and synthesis)
            grpdelay = order1 + order2;
            yk = yk( 1+grpdelay/2:end-grpdelay/2 );
        else
            % Only cut off synthesis filter transients
            grpdelay = order2;
            yk = yk( 1+grpdelay/2:end-grpdelay/2 );
        end
        
        y = y + matchLen( yk, finallen );
    end
end

end % End filterbanksynth


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function [y grpDelay] = ISTFT( S, win, hop, fshift, freqdownsample )
% Computes the inverse short-time Fourier transform of x, where win is the
% synthesis window, hop is the upsampling factor, fshift is a boolean that
% flags whether or not the input subbands are demodulated to baseband, and
% freqdownsample is the ratio of the length of the analysis window to the
% DFT size. This is the inverse function of STFT inside of
% filtersubbands().

    % Convert the window vector to a column vector
    if length( win(1,:) ) > length( win(:,1) )
        win = win.';
    end
    
    % Compute the STFT dimensions, plus determine leading and trailing
    % zeropadding that will make the following buffer() operation behave
    % like a convolution operation with a causal window (ie, the first
    % frame contains all zeros except for the first sample of x at the end
    % of the frame).
    winLen = length( win );
    numFrames = length( S( 1, : ) );
    nfft = length( S( :, 1 ) );

    % Determine the length of the window that was used to compute S, used
    % later for group delay compensation
    if freqdownsample == 1
        analysisWinLen = winLen;
    else
        analysisWinLen = freqdownsample*nfft;
    end

    % Allocate space for the output vector
    y = zeros( 1, (numFrames-1)*hop + winLen );

    % Inverse-DFT each frame (column)
    S = ifft( S );
    
    % We think of the window as sliding forward in time in the case of a
    % demodulated STFT, and of the signal x sliding backward in the case of
    % a non-demodulated STFT. Either way, the window starts with its left
    % edge at index -winLen+1. This is consistent with the convolution
    % interpretation of the STFT.
    winPosition = -winLen+1;

    % Recombine the frames into the final output vector
    for i = 1:numFrames

        % Compute circularly shifted vector indices. This modulo operation
        % undoes the time-aliasing performed in the STFT sub-function
        % inside filtersubbands().
        ind = mod( winPosition:winPosition+winLen-1, nfft ) + 1;
        
        % Apply the synthesis window. Trailing data beyond the length of
        % the window is truncated, assuming the window is zero-valued
        % outside its finite support range.
        frame = win .* S( ind, i );

        % Overlap-add synthesis
        n1 = (i-1)*hop + 1;
        n2 = n1 + winLen - 1;
        y( n1:n2 ) = y( n1:n2 ) + frame.';
        
        if fshift
            % Move the window's position reference forward in time
            winPosition = winPosition + hop;
        end
    end
    
    % Based on the frequency downsampling rate, we can infer the
    % original length of the analysis window used to compute S, so
    % the overall analysis/synthesis group delay results from the
    % cascade of both filters (assuming linear phase, and that the
    % filters are both even or both odd in length).
    grpDelay = ( length( win ) - 1 + analysisWinLen - 1 ) / 2;

end % End ISTFT


% -------------------------------------------------------------------------
function yk = bandpassExpansion( subband, center, g, dfactor, fshift )
% Implements a bandpass expansion operation where the subband signal,
% possibly downsampled and frequency-shifted to baseband, is interpolated
% and returned to a bandpass signal

    if ~fshift
        % Convert to a modulated bandpass filter
        g = vmult( g, exp( j*pi*center*(0:length(g)-1) ) );
    end

    % Interpolate (upsample and filter)
    if dfactor >= (length(g)-1)/128
        % Poly-phase implementation is efficient for large upsampling
        % factors and small-order filters.
        yk = upfirdn( subband, g, dfactor, 1 );
    else
        % fastconv(), which uses fftfilt(), is efficient for small
        % upsampling factors and large-order filters.
        yk = fastconv( g, upsample( subband.', dfactor ) ).';
    end
    
    % Shift the subband in frequency back to its original position
    if fshift
        yk = vmult( yk, exp( j*pi*center*(0:length(yk)-1) ) );
    end
    
end % End bandpassExpansion


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
function xmatched = matchLen( x, L )
% Zero-pads or truncates the row-vector x to length L

    if length( x ) < L
        xmatched = [x, zeros( 1, L - length(x) )];
    else
        xmatched = x( 1:L );
    end

end % End matchLen


% -------------------------------------------------------------------------
function y = vmult( x1, x2 )
% Multiplies two vectors element-wise, regardless of orientation. The
% output orientation matches that of x1.

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
function parseInputs( S, fbparams )
% Similar to the parseInputs() function in filtersubbands, except has
% different checks on S

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
    
    % Now check to make sure that the S matrix is consistent with the
    % filterbank parameters
    if size( S, 1 ) ~= fbparams.numbands && size( S, 1 ) ~= fbparams.numhalfbands
        error( 'The number of rows in the S matrix must equal the number of subbands specified by FILTBANKPARAMS.' )
    end

end % End parseInputs

