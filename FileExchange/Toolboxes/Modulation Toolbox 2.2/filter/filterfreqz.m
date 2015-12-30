function [HF F] = filterfreqz( h, nfft, fs, full )
% [HMAG F] = FILTERFREQZ( H, <NFFT>, <FS>, <FULL> )
% 
% Displays the theoretical frequency response of a multirate filter as
% obtained from DESIGNFILTER.
%
%   INPUTS:
%            H - A struct containing filter information, as obtained from
%                DESIGNFILTER.
%       <NFFT> - The DFT size to use in evaluating the frequency response.
%                This must be a multiple of the overall downsampling rate.
%         <FS> - The sampling rate to use in displaying the frequency
%                response (Hz). The default is 2 (normalized, Nyquist = 1).
%       <FULL> - Set this to 1 to see the entire frequency response from 0
%                to FS, or to 0 to see only 0 to FS/2. The default is 0.
% 
%   OUTPUTS:
%         HMAG - A vector containing the magnitude frequency response, in
%                linear units, showing the entire spectrum from 0 to FS.
%            F - A vector containing the frequency values corresponding to
%                each point in HMAG.
%
%   See also designfilter, narrowbandfilter, modlisting

% Revision history:
%   P. Clark - changed the name from modfiltfreqz(), 11-14-09
%   P. Clark - prepared for beta testing, 10-29-08
%   S. Schimmel - original version, xx-xx-05

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

if nargin < 3 || isempty( fs )
    fs = 2;
end
if nargin < 4 || isempty( full )
    full = 0;
end

% determine overall decimation factor
downsampling = 2^(length(h.filters)-1);

% using 4x frequency sampling points for lowest response,
% compute total number of frequency sampling points 
if nargin < 2 || isempty( nfft )
    points = 4*length(h.filters{end}) * downsampling;
else
    points = nfft;
end

if mod( points/downsampling, 1 ) ~= 0
    num = num2str( downsampling );
    error( ['NFFT must be a multiple of the overall filter downsampling rate, which is ' num '.'] )
end

% initialize omega vector
W = linspace(0,2*pi,points+1); 
W = W(1:end-1);

% initialize frequency response
H = ones(size(W));

% add half-band filters and decimation
for i = 1:length(h.filters)-1,
    % determine current half-band filter's response
    Hi = fft(h.filters{i},points);
    
    % multiply total response with current response
    H(1:points) = H(1:points) .* Hi;

    % alias
    H(1:points/2+1) = H(1:points/2+1) + H([points/2+1:points 1]);
    H(points/2+2:points) = 0;
    
    % decimate
    points = points / 2;
end;

% add desired final filter
Hi = fft(h.filters{end},points); 
H(1:points) = H(1:points) .* Hi;

% add interpolation and half-band filters
for i = length(h.filters)-1:-1:1,
    
    % interpolation
    H(points+1:2*points) = H(1:points);
    points = points * 2;
    
    % determine current half-band filter's response
    Hi = fft(h.filters{i},points);
    
    % multiply total response with current response
    H(1:points) = H(1:points) .* Hi;
end;

% Rotate the frequency response according to the frequency-shift parameter
% in the case of bandpass or highpass filtering.
if h.wshift == 0 || h.wshift == pi
    shift = round( h.wshift/2/pi*length(H) );
    H = circshift( H, [0 shift] );
else
    shift = round( h.wshift/2/pi*length(H) );
    H = circshift( H, [0 shift] ) + circshift( H, [0 -shift] );
end

% Invert the frequency response according to the subtraction flag
if h.subtract
    Hmag = 1 - abs( H );
else
    Hmag = abs( H );
end

HF = Hmag;

% keep full spectrum or 0..pi
if ~full
    W = W(1:end/2+1);
    Hmag = abs( Hmag(1:end/2+1) );
end;

F = fs/2/pi*W;

% only plot when no output is requested
if nargout==0,
    % Plot in dB
    newplot;
    plot( F, 20*log10( Hmag ) );
    title( 'Magnitude frequency response' )
    xlabel( 'Frequency' )
    ylabel( 'dB Magnitude' )
    clear;
end;
