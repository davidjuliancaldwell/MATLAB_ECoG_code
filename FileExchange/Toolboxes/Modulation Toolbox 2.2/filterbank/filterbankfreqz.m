function filterbankfreqz( filtbankparams, nfft, fs )
% FILTERBANKFREQZ( FILTBANKPARAMS, <NFFT>, <FS> )
% 
% Displays the frequency response, as well as the overall analysis-synthesis
% impulse response, of a multirate filterbank as obtained from DESIGNFILTERBANK
% or DESIGNFILTERBANKSTFT.
%
% INPUTS:
%   FILTBANKPARAMS - A struct containing filter information, as obtained from
%                    DESIGNFILTERBANK or DESIGNFILTERBANKSTFT.
%           <NFFT> - The DFT size to use in evaluating the frequency responses.
%                    The default is 512 or the maximum subband filter length,
%                    whichever is greater.
%             <FS> - The sampling rate to use in displaying the frequency
%                    response (Hz). The default is 2 (normalized, Nyquist = 1).
% 
%   See also designfilterbank, designfilterbankstft, modlisting

% Revision history:
%   P. Clark - prepared for beta testing, 12-24-09

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


% Same as the one used in viewcarriers()
colorVec = ['b' 'r' 'g' 'm'];

% Use default values if the user leaves optional arguments unspecified
if nargin < 3 || isempty( fs )
    fs = 2;
end
if nargin < 2 || isempty( nfft )
    nfft = max( 512, max( filtbankparams.afilterorders ) + 1 );
end
    

% Overlay the frequency responses for all subbands
for k = 1:filtbankparams.numbands
    
    h       = index( filtbankparams.afilters, k );
    center  = index( filtbankparams.centers, k );
    
    % Convert the lowpass prototype to a bandpass filter
    h = vmult( h, exp( j*2*pi/2*center*[0:length(h)-1] ) );
    
    H = freqz( h, 1, nfft, 'whole' );       %sample the DTFT around the unit circle
    H = 20*log10( abs( H( 1:floor(nfft/2)+1 ) ) );
    
    c = colorVec( mod( k-1, length(colorVec) ) + 1 );
    subplot( 2, 1, 1 )
    plot( [0:floor(nfft/2)]/nfft*fs, H, c, 'LineWidth', 2 )
    axis( [0 fs/2 max(H)-60 max(H)+10] )
    hold on
end

title( 'Subband filter frequency responses' )
xlabel( 'Frequency (Hz)' )
ylabel( 'dB magnitude' )
hold off

% Now compute and plot the overall impulse response, by breaking an impulse
% signal into subbands and then recombining the subbands to form the
% filterbank's approximation to the original impulse.
leftPad = floor( (nfft-1)/2 );
rightPad = ceil( (nfft-1)/2 );
impSubbands = filtersubbands( [zeros( leftPad, 1 ); 1; zeros( rightPad, 1 )], filtbankparams );
impResponse = filterbanksynth( impSubbands, filtbankparams );

IR = 20*log10( abs( fft( impResponse ) ) );
minMag = min( IR );
maxMag = max( IR );

subplot( 2, 1, 2 )
f = [0:length(IR)-1] * fs/length(IR);    % Plot vs. frequency
plot( f, IR )

if maxMag - minMag < 10
    minMag = minMag - 5;
    maxMag = maxMag + 5;
end

axis( [0 fs/2 minMag maxMag] )

title( 'Filterbank impulse response (analysis + reconstruction)' )
xlabel( 'Frequency (Hz)' )
ylabel( 'dB magnitude' )


end % End filterbankfreqz


% =========================================================================
% Helper sub-functions
% =========================================================================

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

