function Mhat = narrowbandfilter( M, varargin )
% MHAT = NARROWBANDFILTER( M, H, <TRUNCATE> )
% MHAT = NARROWBANDFILTER( M, FILTERBAND, FILTERTYPE, <TRANSBAND>, <DEV>, <TRUNCATE> )
%
% Implements a narrowband multirate FIR filter on a collection of given
% input signals.
%
% INPUTS:
%              M - An array of row-wise signals.
%              H - A struct containing filter design information, obtained
%                  from DESIGNFILTER.
%     FILTERBAND - A two-element vector defining a frequency band,
%                  normalized such that Nyquist = 1, formatted as:
%                     [0  FC] - lowpass or highpass
%                     [F1 F2] - bandpass or bandstop
%     FILTERTYPE - A string indicating the type of filter to implement:
%                  'pass' for lowpass and bandpass, 'stop' for highpass
%                  and bandstop.
%    <TRANSBAND> - A scalar defining the transition bandwidth between
%                  passband and stopband, in normalized frequency units.
%                  The default is 1/5 the passband bandwidth.
%          <DEV> - A two-element vector defining passband and stopband
%                  ripple, in linear units. The default is [.001 and .01],
%                  or approximately 0.01 and -40 dB.
%     <TRUNCATE> - Set this to 1 to truncate starting and ending transients
%                  after filtering, which also undoes group delay. Set this
%                  to 0 to keep transients. The default is 1.
%
% OUTPUTS:
%           MHAT - An array of filtered row-wise signals, compensated for
%                  group delay if TRUNCATE = 1.
%
%   See also designfilter, filterfreqz, modlisting

% Revision history:
%   P. Clark - changed name and user interface, 04-05-10 
%   P. Clark - prepared for beta testing, 02-27-09

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

% Check input parameters
[h truncate]   = parsefilterspecs( varargin );
[M transposed] = parsefilterobjects( M, h, truncate );

L = size( M, 2 );

if h.wshift == 0
    % No frequency shift needed; simply use a lowpass multirate filter
    Mhat = multiratelowpass( M, h, truncate );
    
elseif h.wshift == pi;
    % Shift the signal by pi rads/s in frequency to convert a lowpass
    % filter into a highpass filter, then undo the frequency shift
    Mhat = full( M * diag( sparse( cos( pi*(0:L-1) ) ) ) );
    Mhat = multiratelowpass( Mhat, h, truncate );
    L2   = size( Mhat, 2 );
    Mhat = full( Mhat * diag( sparse( cos( pi*(0:L2-1) ) ) ) );
else
    % Shift the signal by the bandpass center frequency, filtering the
    % positive and negative frequencies separately (since the signals in M
    % might be complex-valued)
    Mhat0 = full( M * diag( sparse( exp( -j*h.wshift*(0:L-1) ) ) ) );
    Mhat0 = multiratelowpass( Mhat0, h, truncate );
    L2    = size( Mhat0, 2 );
    Mhat  = full( Mhat0 * diag( sparse( exp( j*h.wshift*(0:L2-1) ) ) ) );
    
    Mhat0 = full( M * diag( sparse( exp( j*h.wshift*(0:L-1) ) ) ) );
    Mhat0 = multiratelowpass( Mhat0, h, truncate );
    Mhat  = full( Mhat + Mhat0 * diag( sparse( exp( -j*h.wshift*(0:L2-1) ) ) ) );
end

% Perform a final subtraction operation (sometimes it is more economical to
% implement a highpass filter as 1 minus a lowpass filter, for example)
if h.subtract && size( M, 2 ) == size( Mhat, 2 )
    Mhat = M - Mhat;
elseif h.subtract && size( M, 2 ) ~= size( Mhat, 2 )
    n1 = 1 + floor( h.delay );
    n2 = n1 + size( M, 2 ) - 1;

    Mhat = -Mhat;
    Mhat( :, n1:n2 ) = Mhat( :, n1:n2 ) + M;
end

% Correct any residual imaginary artifacts that might result from the
% bandpass filter operation
realVecs = ~any( imag( M ), 2 );
Mhat( realVecs, : ) = real( Mhat( realVecs, : ) );

% Convert back to a column vector, if needed
if transposed
    Mhat = Mhat.';
end

end % End narrowbandfilter


% =========================================================================
% Helper Functions
% =========================================================================

% -------------------------------------------------------------------------
function Xhat = multiratelowpass( X, h, truncate )
% Applies a cascade of lowpass filtering and downsampling operations
% (decimation) followed by a cascade of upsampling and lowpass operations
% (interpolation). All filtering is done row-wise (i.e., treating each row
% of X as a separate signal).

    numstages = length( h.filters );
    
    % It's computationally more efficient to operate on column vectors
    Xhat = X.';
    
    % Decimation: apply halfband filters and successively downsample
    for i = 1:numstages-1
        Xhat = upfirdn( Xhat, 2*h.filters{i}, 1, 2 );
    end

    % Apply the low sampling-rate kernel
    Xhat = fastconv( h.filters{numstages}, Xhat );
    
    % Interpolation: successively upsample and reapply the halfband filters
    for i = numstages-1:-1:1
        Xhat = upfirdn( Xhat, h.filters{i}, 2, 1 );
    end
    
    Xhat = Xhat.';
    
    if truncate
        % Trim group delay transients, assuming linear phase filtering
        n1 = 1 + floor( h.delay );
        n2 = n1 + size( X, 2 ) - 1;
        Xhat = Xhat( :, n1:n2 );
    end
    
end % End multiratelowpass


% -------------------------------------------------------------------------
function y = fastconv( h, x )
% Convolve the columns of X with the filter H, using the overlap-add FFT
% method as implemented by an augmented version of fftfilt().

    y = fftfilt( h, [x; zeros( length(h)-1, size(x,2) )] );
    
end % End fastconv


% -------------------------------------------------------------------------
function [h truncate] = parsefilterspecs( filterspecs )

    % Default value for transient truncation
    truncate = 1;
    
    if isa( filterspecs{1}, 'struct' )
        h = filterspecs{1};
        
        if length( filterspecs ) == 2
            truncate = filterspecs{2};
        end
    else
        switch length( filterspecs )
            case 1, error( 'Not enough filter specifications NARROWBANDFILTER( M, FREQBAND, FILTERTYPE, <TRANSBAND>, <DEV>, <TRUNCATE> )' )
            case 2, h = designfilter( filterspecs{1}, filterspecs{2} );
            case 3, h = designfilter( filterspecs{1}, filterspecs{2}, filterspecs{3} );
            case 4, h = designfilter( filterspecs{1}, filterspecs{2}, filterspecs{3}, filterspecs{4} );
            case 5, h = designfilter( filterspecs{1}, filterspecs{2}, filterspecs{3}, filterspecs{4} ); truncate = filterspecs{5};
            otherwise, error( 'Too many inputs for NARROWBANDFILTER( M, FREQBAND, FILTERTYPE, <TRANSBAND>, <DEV>, <TRUNCATE> )' );
        end
    end

end % End parsefilterspecs


% -------------------------------------------------------------------------
function [M transposedVec] = parsefilterobjects( M, h, truncate )

    % Convert a column vector to a row vector
    if length( M(1,:) ) == 1
        M = M.';
        transposedVec = 1;
    else
        transposedVec = 0;
    end
    
    nofilter = 0;
    notype = 0;
    noshift = 0;
    nosub = 0;
    
    % Look for the necessary fields in the h data structure
    try
        h.filters;
    catch
        nofilter = 1;
    end
    
    try
        h.type;
    catch
        notype = 1;
    end
    
    try
        h.wshift;
    catch
        noshift = 1;
    end
    
    try
        h.subtract;
    catch
        nosub = 1;
    end
    
    if nofilter || ~isa( h.filters, 'cell' )
        error( 'The filter object H must contain a cell array of filter kernels: H.FILTERS' );
    end
    if notype || ~isa( h.type, 'char' )
        error( 'The filter object H must contain a string specifying the type of filter: H.TYPE' );
    end
    if noshift || ~isa( h.wshift, 'double' )
        error( 'The filter object h must contain a shift-frequency: H.WSHIFT' );
    end
    if nosub || ~isa( h.subtract, 'logical' )
        error( 'The filter object h must contain a boolean (logical): H.SUBTRACT' );
    end
    
    if truncate ~= 0 && truncate ~= 1
        error( 'The TRUNCATE flag must be either 0 or 1 (boolean)' )
    end

end % End parseinputs

