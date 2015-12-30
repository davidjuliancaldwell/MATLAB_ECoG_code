function filtbankparams = designfilterbank( centers, bandwidths, transbands, dfactor, keeptransients )
% FILTBANKPARAMS = DESIGNFILTERBANK( CENTERS, BANDWIDTHS, <TRANSBANDS>, <DFACTOR>, <KEEPTRANSIENTS> )
%
% Designs an FIR multirate filterbank with arbitrary subband spacing for
% use with FILTERSUBBANDS and FILTERBANKSYNTH.
%
% INPUTS:
%           CENTERS - A vector containing subband center frequencies,
%                     strictly increasing, normalized between 0 and 1 (i.e,
%                     Nyquist = 1).
%        BANDWIDTHS - A vector containing subband bandwidths (between -6dB
%                     cutoffs), normalized between 0 and 2, of length equal
%                     to that of CENTERS.
%      <TRANSBANDS> - A vector containing subband transition bandwidths,
%                     each less than the corresponding subband bandwidth.
%                     The default values are BANDWIDTHS/10.
%         <DFACTOR> - A scalar specifying the downsampling factor to use on
%                     all of the subbands. If downsampling is specified,
%                     then the subband signals will be frequency-shifted to
%                     baseband first (i.e., centered at 0 Hz). The default
%                     setting is dfactor = 1 (no downsampling).
%  <KEEPTRANSIENTS> - A boolean indicating whether or not to keep subband
%                     filter transients, which is useful for perfect
%                     reconstruction at the edges of a signal. Default = 1.
%
% OUTPUTS:
%    FILTBANKPARAMS - A struct containing filterbank implementation
%                     information for use with FILTERSUBBANDS and
%                     FILTERBANKSYNTH.
% 
%   See also designfilterbankstft, filterbankfreqz, filtersubbands,
%            filterbanksynth, modlisting
%   

% Revision history:
%   P. Clark - changed downsamplefactors to be a scalar only, removed
%              the FSHIFT option, added KEEPTRANSIENTS option, 08-12-10
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
if nargin < 4 || isempty( dfactor )
    dfactor = 1;
end
if dfactor > 1
    fshift = 1;
else
    fshift = 0;
end
if nargin < 3 || isempty( transbands )
    transbands = bandwidths / 10;
end
if nargin < 5 || isempty( keeptransients )
    keeptransients = 1;
end

% Check for improperly formatted input
filtbankparams = parseInputs( centers, bandwidths, transbands, dfactor, fshift, keeptransients );

% Design a filter for each subband. These are lowpass filters that will be
% modulated to form bandpass filters.
for i = 1:length( filtbankparams.bandwidths )

    % The default filter is a truncated sinc function tapered by a Hamming
    % window. Hence the transition bandwidth is roughly equivalent to the
    % bandwidth of the Hamming window, with the -6 dB (half-magnitude)
    % cutoff point located halfway through the transtion band.
    B     = filtbankparams.bandwidths( i );    % symmetric -6dB bandwidth
    wc    = B/2;                               % -6dB cutoff frequency
    trans = index( transbands, i );            % transition bandwidth
    order = nearestEven( ceil( 6.6/trans ) );  % specific to the Hamming window, fs = 2
    
    % Windowed sinc FIR design using a Hamming window
    h = fir1( order, wc )';
    
    filtbankparams.afilters{ i } = h;
    filtbankparams.afilterorders( i ) = order;

    dfactor = index( filtbankparams.dfactor, i );

    % If a downsampling factor is specified, then provide the same filter
    % for use as an interpolating (synthesis) filter. Otherwise, default to
    % a zeroth-order identity filter.
    if  dfactor > 1
        filtbankparams.sfilters{ i } = dfactor*h;
        filtbankparams.sfilterorders( i ) = order;
    else
        filtbankparams.sfilters{ i } = 1;
        filtbankparams.sfilterorders( i ) = 0;
    end
end

end % End designfilterbank


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function filtbankparams = parseInputs( centers, bandwidths, transbands, dfactor, fshift, keeptransients )
% Check inputs for errors and form the filterbank parameters data structure

    if length( centers ) > 1 && sum( centers( 2:end ) < centers( 1:end-1 ) ) > 0
        error( 'Subband center frequencies must be strictly increasing.' );
    elseif min( centers ) < 0  || max( centers ) > 1
        error( 'Subband center frequencies must be in the range [0 1].' );
    end

    numbands = length( centers );
    
    if min( bandwidths ) <= 0  || max( bandwidths ) >= 2
        error( 'Subband bandwidths must be in the range (0 2), non-inclusive.' );
    elseif length( bandwidths ) > 1 && length( bandwidths ) ~= numbands
        error( 'The number of subband bandwidths must be one or equal to the number of subband centers.' )
    end
    
    if length( transbands ) > 1 && length( transbands ) ~= numbands
        error( 'The number of transition bandwidths must be one or equal to the number of subband centers.' )
    elseif sum( double( transbands <= 0 ) ) || sum( double( transbands > bandwidths ) )
        error( 'Subband transition bandwidths must be nonzero positive and less than the -6dB bandwidths.' )
    end
    
    if length( dfactor ) > 1
        error( 'DFACTOR must be a scalar (as of version 2.1).' )
    elseif dfactor < 1 || mod( dfactor, 1 ) ~= 0
        error( 'DFACTOR must be a positive integer greater than zero.' )
    end
    
    if fshift ~= 0 && fshift ~= 1
        error( 'FSHIFT must be a boolean, 1 or 0.' )
    end

    if centers(1) == 0 && centers(end) == 1
        numhalfbands = 2*numbands - 2;          % subbands at zero and pi
    elseif centers(1) == 0 || centers(end) == 1
        numhalfbands = 2*numbands - 1;          % one subband at zero or pi
    else
        numhalfbands = 2*numbands;              % no subbands at zero or pi
    end
    
    % Initialize the filerbank parameters structure
    filtbankparams = struct;

    filtbankparams.numbands = numbands;             % number of subbands between 0 and pi on the unit circle
    filtbankparams.numhalfbands = numhalfbands;     % number of half-subbands around the entire unit circle (DFT size for an STFT filterbank)
    filtbankparams.dfactor = dfactor;               % subband down-sampling factors
    filtbankparams.centers = centers;               % subband center frequencies
    filtbankparams.bandwidths = bandwidths;         % subband bandwidths, measured between -6dB points
    filtbankparams.afilters = {};                   % array of lowpass analysis filters
    filtbankparams.afilterorders = [];              % array of analysis filter orders
    filtbankparams.sfilters = {};                   % array of lowpass synthesis filters
    filtbankparams.sfilterorders = [];              % array of analysis filter orders
    filtbankparams.fshift = fshift;                 % boolean: 1 = center-shifted subbands
    filtbankparams.stft = 0;                        % boolean: 1 = this is an STFT filterbank
    filtbankparams.keeptransients = keeptransients; % boolean: 1 = keep subband filter transients

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

