function viewcarriers( x, fs, C, filtbankparams, inds )
% VIEWCARRIERS( X, FS, C, <FBPARAMS>, <INDS> )
%
% Overlays a spectrogram of a signal with the instantaneous frequency
% trajectories of the provided carrier signals.
%
% INPUTS:
%            X - A vector time-series.
%           FS - The sampling rate of X, in Hz.
%            C - An array of row-wise carrier signals obtained from one of
%                the MODDECOMP... functions.
%     <FBDATA> - A struct containing the parameters of the filterbank used
%                to obtain C, applicable in the COG and Hilbert methods. 
%                The default is [], or no filterbank, assuming that the
%                carrier array C is sampled at the same rate as X. FBDATA
%                can also be the DATA object returned by MODDECOMP.
%       <INDS> - An array of positive integers giving the indices of the
%                carriers to plot. For example, INDS = [2 4 10] will plot
%                the frequency trajectories of C(2,:), C(4,:) and C(10,:).
%                The default is to plot every carrier.
%   
% See also moddecompcog, moddecompharm, moddecompharmcog, moddecomphilb,
%          modlisting

% Revision history:
%   P. Clark - created for version 2.1, 04-05-10

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


if numel( C ) == length( C ) && size( C, 1 ) ~= 1
    % Make sure C is a row vector
    C = transpose( C );
end

% Default parameters
if nargin < 3
    error( 'VIEWCARRIERS requires at least three inputs.' )
end
if nargin < 4
    filtbankparams = [];
end
if nargin < 5
    inds = 1:size(C,1);
    indsAreUserSpecified = 0;
else
    indsAreUserSpecified = 1;
end

% Check to see if the input struct is really a filterbank parameter object,
% or if it is a more general MODDECOMP "data" object which contains a
% filterbank parameter object.
if isfield( filtbankparams, 'filtbankparams' )
    filtbankparams = filtbankparams.filtbankparams;
end

% Growable array of carrier indexes to skip
skipInds = [];

if ~isempty( filtbankparams )
    % If the carriers come from multirate filterbank subbands (as in the
    % STFT method), then the carriers might be frequency-shifted to
    % baseband and possibly downsampled. In the following, the carrier
    % instantaneous-frequencies are computed with these considerations in
    % mind.
    
    % Extract instantaneous frequency tracks
    decfactor = filtbankparams.dfactor;
    F = (fs/decfactor)/2*carrier2if( C );
    
    % Trim filter transients from the beginning and end of each IF track
    F = undogroupdelay( F, filtbankparams.afilterorders, decfactor );
    
    if filtbankparams.fshift
        % Undo the frequency shift (i.e., convert lowpass frequencies back
        % to bandpass)
        centerfreqs = filtbankparams.centers/2*fs;
        centerfreqs = centerfreqs(:);
        
        if size(F,1) == filtbankparams.numhalfbands
            % For complex signals, account for all halfbands between -fs/2
            % and +fs/2
            centerfreqs = formatcenterfreqs( centerfreqs, fs );
        elseif size(F,1) ~= filtbankparams.numbands
            error( 'Filterbank data is incompatible with the provided carrier signal array.' )
        end
        
        % Add the frequency-shift offset to each IF track
        F = F + repmat( centerfreqs, 1, size(F,2) );
    end

    % Skip trivial carrier detections at baseband (centered on 0 Hz) and at
    % Nyquist (centered on fs/2), *unless* the user has explicitly
    % requested those carriers to be plotted.
    baseband = find( filtbankparams.centers == 0 );
    nyquist  = find( filtbankparams.centers == 1 );
    if ~isempty( baseband ) && ~( indsAreUserSpecified && any( inds == baseband ) )
        skipInds = [skipInds, baseband];
    end
    if ~isempty( nyquist ) && ~( indsAreUserSpecified && any( inds == nyquist ) )
        skipInds = [skipInds, nyquist];
    end
    
else
    % In this case the carriers are assumed to be bandpass signals sampled
    % at the same rate as X.
    decfactor = 1;
    F = fs/2*carrier2if( C );
end

% Compute the signal spectrogram
winlen = round( 0.075*fs );
winhop = ceil( winlen / 4 );
numframes = ceil( length(x) / winhop );
win = hamming( winlen );
win = win / norm( win );

X = buffer2( x(:), winlen, winhop, -floor(winlen/2), numframes );
X = diag( sparse( win ) ) * X;

if isreal( x )
    minfreq = 0;
    maxfreq = fs/2;
    X = 20*log10( abs( fft( X ) ) );
    X = X( 1:ceil(winlen/2), : );
    f  = (0:size(X,1)) * (fs/winlen);
else
    minfreq = -fs/2;
    maxfreq = fs/2;
    X = 20*log10( abs( fftshift( fft( X ), 1 ) ) );
    f  = (0:size(X,1)) * (fs/winlen) - fs/2;
end

% Plot the signal spectrogram
tx = (0:size(X,2)-1) / ( fs / winhop );
imagesc( tx, f, X ); axis xy, climdb( 60 );
colormap( 'gray' );
hold on

% Resample the IF trajectories on the same time grid as the signal
% spectrogram for faster plotting. The straight-line interpolation is
% suboptimal but sufficient for viewing purposes.
tc = (0:size(F,2)-1) / ( fs / decfactor );
F = interp1( tc, F.', tx ).';

if numel( F ) == length( F ) && size( F, 1 ) ~= 1
    % Make sure F is a row vector, because interp1 is buggy
    F = transpose( F );
end

% Same color vector used in FILTERBANKFREQZ
colors = ['b' 'r' 'g' 'm'];

% Overlay the carrier frequency trajectories
for k = 1:length(inds)
    if any( inds(k) == skipInds )
        continue;
    end
    plot( tx, F( inds(k), : ), colors( mod( k-1, length(colors) ) + 1 ), 'LineWidth', 2.0 )
end

title( 'Signal spectrogram overlaid with carrier frequency tracks' )
xlabel( 'Time (s)' )
ylabel( 'Frequency (Hz)' )
hold off;
axis( [tx(1) tx(end) minfreq maxfreq] );

end % End viewcarriers


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function centerfreqs = formatcenterfreqs( nonnegfreqs, fs )
% Mirrors the non-negative subband center frequencies in order to fill out
% the rest of the frequencies between -Nyquist and +Nyquist.

    negfreqs = sort( nonnegfreqs, 'ascend' );
    
    % Be sure to not include 0 and Nyquist twice
    if negfreqs(1) == 0
        negfreqs = negfreqs(2:end);
    end
    if negfreqs(end) == fs/2
        negfreqs = negfreqs(1:end-1);
    end
    
    % Every halfband (except the bands at 0 and Nyquist) have a symmetric
    % negative-frequency counterpart
    negfreqs = -negfreqs;
    
    centerfreqs = [nonnegfreqs; negfreqs(end:-1:1)];
    
end % End formatcenterfreqs


% -------------------------------------------------------------------------
function X = undogroupdelay( X, filtorders, decfactor )
% Compensates the row-wise signals in the array X for linear-phase group
% delay, based on the provided filter orders and decimation factor.

    delays = ceil( ( filtorders/2+1 ) / decfactor ) - 1;

    % Trim start-up transients
    for k = 1:size( X, 1 )
        kdelay = index( delays, k );
        X( k, 1:end-kdelay ) = X( k, 1+kdelay:end );
    end
    
    % Trim ending transients (this is the same for all subbands regardless
    % of subband filter order, because FILTERSUBBANDS zeropads subbands
    % with short transients so that they all have equal lengths)
    X( :, end-max(delays):end ) = 0;

end % End undogroupdelay


% -------------------------------------------------------------------------
function B = buffer2( x, winlen, hop, startindex, numframes )
% Buffer the column vector x with window length winlen and skip distance
% hop. The signal is appended with zeros in order to achieve the specified
% number of frames. The startindex specifies where the first frame begins,
% supposing that x begins at time sample index 0.

    if startindex <= 0
        prepend = zeros( -startindex, 1 );
        x = [prepend; x];
    else
        x = x( 1+startindex : end );
    end
    
    len = winlen + ( numframes-1 )*hop;
    
    x = [x; zeros( len - length(x), 1 )];
    
    if hop <= winlen
        B = buffer( x, winlen, winlen-hop, 'nodelay' );
    else
        B = buffer( x, winlen, winlen-hop, 0 );
    end

end % End buffer2


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
function climdb( range )
% CLIMDB Set axis color limits to a meaningful dB range
%    CLIMDB(RANGE) sets the color limits of the current axis to the desired
%    range. RANGE can be a scalar, in which case the color limits will be
%    set to [MAX-RANGE MAX]. Or RANGE can be a 2 element vector, which
%    specifies the color range directly. Since colorbars are not
%    automatically updated, it is best to call this function before
%    displaying a colorbar.
%    Thanks to Steven Schimmel for writing this!

    % determine clim if not fully specified
    switch numel(range),
    case 1,
        clim = get(gca,'clim');
        clim(1) = clim(2)-range;
    case 2,
        clim = range;
    otherwise,
        error('RANGE must be a scalar or a 2 element vector');
    end;

    % set new color limits on current axis 
    set(gca,'clim',clim);

end % End climdb

