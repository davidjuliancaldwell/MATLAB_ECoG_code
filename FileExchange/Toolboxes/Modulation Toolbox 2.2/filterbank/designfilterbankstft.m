function filtbankparams = designfilterbankstft( numhalfbands, sharpness, dfactor, keeptransients )
% FILTBANKPARAMS = DESIGNFILTERBANKSTFT( NUMHALFBANDS, <SHARPNESS>, <DFACTOR>, <KEEPTRANSIENTS> )
% 
% Designs an FIR multirate filterbank based on the short-time Fourier
% transform, with equispaced subbands and least-squares optimal
% reconstruction. Use with FILTERSUBBANDS and FILTERBANKSYNTH.
% 
% INPUTS:
%      NUMHALFBANDS - A scalar specifying the number of complex-valued
%                     subbands spaced evenly around the unit circle. This
%                     will produce M unique subbands where
%                     M = floor(NUMHALFBANDS/2)+1.
%       <SHARPNESS> - An odd integer specifying the subband cutoff
%                     sharpness, with larger values corresponding to a
%                     increasingly rectangular frequency response. The
%                     subband filter is a Hamming-windowed FIR design with
%                     order equal to NUMHALFBANDS*SHARPNESS-1. The default
%                     is SHARPNESS = 1 (just a Hamming window).
%         <DFACTOR> - A scalar specifying the downsampling factor to use on
%                     all of the subbands. If downsampling is specified,
%                     then the subband signals will be frequency-shifted to
%                     baseband first (i.e., centered at 0 Hz). The default
%                     setting is DFACTOR = 1 (no downsampling).
%  <KEEPTRANSIENTS> - A boolean indicating whether or not to keep subband
%                     filter transients, which is useful for perfect
%                     reconstruction at the edges of a signal. Default = 1.
% 
% OUTPUTS:
%    FILTBANKPARAMS - A struct containing filterbank implementation
%                     information for use with FILTERSUBBANDS and
%                     FILTERBANKSYNTH.
% 
%   See also designfilterbank, filterbankfreqz, filtersubbands,
%            filterbanksynth, modlisting

% Revision history:
%   P. Clark - changed default downsampling factor to 1, removed FSHIFT
%              option, added KEEPTRANSIENTS option, 08-12-10
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


% Establish default values if the user leaves them unspecified
if nargin < 2 || isempty( sharpness )
    sharpness = 1;
end
if nargin < 3 || isempty( dfactor )
    dfactor = 1;
end
if dfactor > 1
    fshift = 1;
else
    fshift = 0;
end
if nargin < 4 || isempty( keeptransients )
    keeptransients = 1;
end

winlen = numhalfbands*sharpness;
aOrder = winlen - 1;

errorCheck( numhalfbands, sharpness, dfactor, fshift );

% Design the analysis window as a Hamming-windowed Dirichlet kernel with
% order winlen-1 and bandwidth equal to 2*pi/winlen*sharpness =
% 2*pi/numhalfbands.
n = -(winlen-1)/2:(winlen-1)/2;
analysisWin = hamming( winlen );
analysisWin = analysisWin .* diric( 2*pi/winlen*n', sharpness );
analysisWin = analysisWin / sum( analysisWin );

% Compute the least-squares optimal reconstruction synthesis window
% associated with the specified analysis window
synthWin = STFTwindow( analysisWin, dfactor, numhalfbands );
sOrder = length( synthWin ) - 1;

% Compute the bandwidth of the analysis window (between 71%-magnitude points,
% i.e., the -3 dB points)
bandwidths = windowBandwidth( analysisWin, 1/sqrt(2) );

% Subband center frequencies
numbands = floor( numhalfbands / 2 ) + 1;
centers = 0:2/numhalfbands:2*(numbands-1)/numhalfbands;

filtbankparams = struct;

filtbankparams.numbands = numbands;             % number of subbands between 0 and pi on the unit circle
filtbankparams.numhalfbands = numhalfbands;     % number of half-subbands around the entire unit circle (DFT size for an STFT filterbank)
filtbankparams.dfactor = dfactor;               % subband down-sampling factors
filtbankparams.centers = centers;               % subband center frequencies
filtbankparams.bandwidths = bandwidths;         % subband bandwidths (everything outside the stopband)
filtbankparams.afilters{1} = analysisWin;       % array of lowpass analysis filters
filtbankparams.afilterorders = aOrder;          % array of analysis filter orders
filtbankparams.sfilters{1} = synthWin;          % array of lowpass synthesis filters
filtbankparams.sfilterorders = sOrder;          % array of synthesis filter orders
filtbankparams.fshift = fshift;                 % boolean: 1 = center-shifted subbands
filtbankparams.stft = 1;                        % boolean: 1 = this is an STFT filterbank
filtbankparams.keeptransients = keeptransients; % boolean: 1 = keep subband filter transients

end   % End designprfilterbank


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function compWin = STFTwindow( window, hopDistance, DFTsize )
% Design a reconstruction window for a Short-Time Fourier Transform
% that is downsampled in time (with rate equal to hopDistance) and also
% possibly downsampled in frequency (with rate equal to length(window)/DFTsize).
% Perfect reconstruction is possible when hopDistance <= length(window) and
% DFTsize = length(window). Near-perfect reconstruction is possible with
% careful balance of frequency and time downsampling.

    % Convert to a column vector
    if length( window(1,:) ) > length( window(:,1) )
        window = window.';
        transposed = 1;
    else
        transposed = 0;
    end

    L1 = length( window );
    L2 = DFTsize;

    M  = L1 / L2;       % frequency downsampling rate
    M2 = (M-1) / 2;
    R  = hopDistance;

    if mod( M, 1 ) ~= 0
        error( 'Window length must be divisible by DFTsize' );
    end
    
    if mod( M, 2 ) == 0
        error( 'The window length divided by the DFTsize must be odd (this is the frequency dowmsampling rate).' )
    end

    % The F matrix contains downsampled subsets of the analysis window that
    % weight the corresponding coefficients of the reversed synthesis window
    F = zeros( M*min( R, L2 ), L2 );

    % The D vector contains the constraints imposed on each inner product,
    % either 0 or 1
    D = zeros( M*min( R, L2 ), 1 );

    % Using Portnoff's equation for perfect reconstruction, the product of 
    % each downsamled sub-set of the reversed analysis window and synthesis
    % window must sum to 1. That is,
    %
    %   f( n-sR ) dotprod h( sR-n+p*L2 ) = 1, p  = 0, for all n
    %                                    = 0, p ~= 0, for all n
    %
    %   where s indexes f and h, R is the downsample rate, and n is the
    %   downsample offset. Written in matrix notataion:
    %
    %   F*compWin = D
    %
    %   where the rows of F are downsampled subsets of the window, compWin
    %   is the inverse window, and D is a vector of 1's and 0's.
    % 
    % (M.R. Portnoff, "Time-frequency representations of digital signals and
    % systems based on short-time Fourier analysis," Eq. 64, 1980.)
    for p = 0:M-1
        for n = 1:min( R, L2 )
            temp = upsample( downsample( window( 1+p*L2:(p+1)*L2 ), R, n-1 ), R, n-1 );

            if length( temp ) < L2
                temp = [temp; zeros( L2-length(temp), 1 )];
            elseif length( temp ) > L2
                temp = temp( 1:L2 );
            end

            F( p*min(R,L2)+n, : ) = temp;
            D( p*min(R,L2)+n, 1 ) = p==M2;
        end
    end

    % F * compWin = D, which might be over- or under-determined depending on
    % parameters. The pseudo-inverse based on SVD achieves a least-squares
    % solution.
    compWin = pinv( F )*D;
    compWin = compWin( end:-1:1 );
    
    % Set the complementary window to the same orientation as the input
    % window
    if transposed
        compWin = compWin.';
    end

end   % End STFTwindow


% -------------------------------------------------------------------------
function bandwidth = windowBandwidth( window, magnitude )
% Assuming the window is lowpass in nature, this function returns the
% bandwidth with respect to the normalized magnitude provided as
% input. The bandwidth is returned in normalized frequency (1 = Nyquist),
% and is the full spectral width, including negative frequencies.

    nfft = 4*length( window );
    nyq = ceil( (nfft+1) / 2 );
    H = abs( fft( window, nfft ) );
    H = H( 1:nyq ) / max( H( 1:nyq ) );
    
    k = find( H < magnitude, 1, 'first' );
    
    bandwidth = 2*( k/nfft*2 );
    
end   % End windowBandwidth


% -------------------------------------------------------------------------
function errorCheck( numhalfbands, sharpness, dfactor, fshift )
% Check for improperly formatted input parameters

    if numel( sharpness ) ~= 1 || sharpness < 1 || mod( sharpness, 2 ) ~= 1 || mod( sharpness, 1 ) ~= 0
        error( 'SHARPNESS must be an odd integer greater than 0.' )
    end

    if numel( numhalfbands ) ~= 1 || numhalfbands < 1 || mod( numhalfbands, 1 ) ~= 0
        error( 'NUMHALFBANDS must be an integer greater than 0.' )
    end
    
    if numel( fshift ) ~= 1 || ( fshift ~= 0 && fshift ~= 1 )
        error( 'FSHIFT must be a boolean, 1 or 0.' )
    end

    if numel( dfactor ) ~= 1 || dfactor < 1 || mod( dfactor, 1 ) ~= 0
        error( 'DFACTOR must be a positive integer scalar.' )
    end

end   % End errorCheck

