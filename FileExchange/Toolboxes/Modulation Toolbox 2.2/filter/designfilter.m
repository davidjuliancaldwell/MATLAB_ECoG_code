function h = designfilter( filterband, filtertype, transband, dev )
% H = DESIGNFILTER( FILTERBAND, FILTERTYPE, <TRANSBAND>, <DEV> )
%
% Designs a multirate narrowband FIR filter with linear phase for use with
% NARROWBANDFILTER.
%
% INPUTS:
%     FILTERBAND - A two-element vector defining a frequency band,
%                  normalized such that Nyquist = 1, formatted as:
%                     [0 FC]  - lowpass or highpass
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
%
% OUTPUTS:
%   H - A struct containing the necessary information for use with
%       NARROWBANDFILTER.
%
%   See also filterfreqz, narrowbandfilter, modlisting

% Revision history:
%   P. Clark - changed name from modfiltdesign(), made transband an
%              optional parameter, altered filter specifications, 02-27-10
%   P. Clark - prepared for beta testing, 02-27-09
%   S. Schimmel - original version, 2005

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


if version('-release')>=14, 
    remord = @firpmord;
    remdsn = @firpm;
else
    remord = @remezord;
    remdsn = @remez;
end

% Standard sampling rate that sets Nyquist to 1.
fs = 2;

if nargin < 2
    error( 'DESIGNFILTER requires at least two inputs.' )
end

% Default transition bandwidth value
if nargin < 3 || isempty( transband )
    if filterband(1) == 0
        % lowpass or highpass filter
        transband = min( filterband(2), 1-filterband(2) ) / 5;
    else
        % bandpass or bandstop filter
        transband = min( filterband(2)-filterband(1), min( filterband(1), 1-filterband(2) ) ) / 5;
    end
end

% Default passband/stopband amplitude deviation values
if nargin < 4 || isempty( dev )
    dev = [0.001 0.01];     % passband and transband amplitude deviation, linear units
end

% Check for errors and decide between lowpass/bandpass/highpass modes
[h fpass fstop] = parseInputs( filterband, filtertype, transband, dev );

% Use the smallest ripple deviation to contrain the half-band filter design
delta0 = min( dev );

idx = 1;
while 1,
    
    % decide between intermediate half-band filter or final kernel filter
    if fs/2<=4*fstop,
        % If fstop is more than half the Nyquist, then any more
        % downsampling will cause aliasing of the passband. But if fstop is
        % more than one quarter of the Nyquist, then there is a possibility
        % of running into unstable half-band filter designs.
        do_hb = 0;
    else
        % further downsampling is possible, but another halfband filter may
        % be inefficient compared to designing the final kernel filter
        nhb = length(halfbandfir('minorder',fstop/(fs/2),delta0))-1;

        % compare to a kernel design
        f = [fpass fstop];
        a = [1 0];
        nfb = remord(f,a,dev,fs);        
        nfb = nfb + mod(nfb,2);

        do_hb = nhb < nfb/4;
    end
    
    % if decimation is needed, design half-band filter
    if do_hb,
        % design half-band filter for /2 decimation and *2 interpolation
        % (half-band filters are special in that approx 1/2 of the filter
        % coefficients are zero, making them ideal for decimation-by-2
        % polyphase implementation. Also, the passband cutoff and stopband
        % cutoff are equidistant from 0 and pi, respectively. So even
        % though the transition band may be quite large, only stopband
        % frequencies will alias over the passband frequencies)
        hb = halfbandfir('minorder',fstop/(fs/2),delta0);
        
        % DC correction (must have DC==1)
        h.filters{idx} = hb / sum(hb);
        
        % halve the sampling rate and advance to next stage
        fs = fs/2;
        idx = idx + 1;
    else
        f = [fpass fstop];
        a = [1 0];
        
        % determine order of desired filter        
        firc = remord(f,a,dev,fs,'cell');
        
        % increase order to next even number for integer delay
		firc{1} = firc{1} + mod(firc{1},2);
        
        % design filter using remez-exchange algorithm
		h.filters{idx} = remdsn(firc{:});
        
        % leave the while-loop
        break;
    end
end

% compute delay of entire filter
h.delay = 0; 
for i=[1:idx idx-1:-1:1],
    h.delay = h.delay + ((length(h.filters{i})-1)/2) * 2^(i-1);
end

end % End designfilter


% =========================================================================
% Helper Functions
% =========================================================================

% -------------------------------------------------------------------------
function [h fpass fstop] = parseInputs( filterband, filtertype, transband, dev )
% Checks for impropertly formatted input parameters and displays error
% messages

    % Check for input errors
    if length( filterband ) ~= 2 || filterband( 1 ) > 1 || filterband( 2 ) > 1 ...
                               || filterband( 1 ) < 0 || filterband( 2 ) < 0
        error( 'The FILTERBAND vector must contain two non-negative elements each less than or equal to 1.' )
    end
    if filterband( 2 ) <= filterband( 1 )
        error( 'FILTERBAND values must be strictly increasing.' )
    end
    if length( transband ) ~= 1 || transband <= 0
        error( 'TRANSBAND must be a non-negative scalar.' )
    end
    
    % Set up the filter implementation topology, where fpass and fstop
    % refer to a prototype lowpass filter. Hence any highpass, bandpass, or
    % bandstop filter is implemented via frequency-shift, decimation,
    % lowpass filtering, and subtraction operations.
    if strcmpi( filtertype, 'pass' ) && filterband(1) == 0
        h.type = 'lowpass';
        
        if filterband(2) < 1/2
            h.wshift = 0;
            h.subtract = false;
            fpass = filterband(2);
        else
            h.wshift = pi;
            h.subtract = true;
            fpass = 1-filterband(2);
        end
        
    elseif strcmpi( filtertype, 'stop' ) && filterband(1) == 0
        h.type = 'highpass';
        
        if filterband(2) < 1/2
            h.wshift = 0;
            h.subtract = true;
            fpass = filterband(2);
        else
            h.wshift = pi;
            h.subtract = false;
            fpass = 1-filterband(2);
        end
        
    elseif strcmpi( filtertype, 'pass' ) && filterband(1) ~= 0
        h.type = 'bandpass';

        h.wshift = 2*pi/2*( filterband(1) + filterband(2) ) / 2;
        h.subtract = false;
        fpass = ( filterband(2) - filterband(1) ) / 2;
        
    elseif strcmpi( filtertype, 'stop' ) && filterband(1) ~= 0
        h.type = 'bandstop';

        h.wshift = 2*pi/2*( filterband(1) + filterband(2) ) / 2;
        h.subtract = true;
        fpass = ( filterband(2) - filterband(1) ) / 2;
        
    else
        error( 'Filter type must be either ''pass'' or ''stop''.' )
    end

    h.filterband = filterband;
    h.transband = transband;
    
    % Check for filter specification errors
    if strcmpi( h.type, 'lowpass' ) && ( filterband(2)+transband > 1 )
        error( 'The specified transition band is too large given the lowpass cutoff frequencies.' )
    end
    if strcmpi( h.type, 'highpass' ) && ( filterband(2)-transband < 0 )
        error( 'The specified transition band is too large given the highpass cutoff frequencies.' )
    end
    if strcmpi( h.type, 'bandpass' ) && ( ( filterband(1)-transband < 0 ) || ( filterband(2)+transband > 1 ) )
        error( 'The specified transition band is too large given the bandpass cutoff frequencies.' )
    end
    if strcmpi( h.type, 'bandstop' ) && 2*transband > ( filterband(2)-filterband(1) )
        error( 'The specified transition band is too large given the bandstop cutoff frequencies.' )
    end

    fstop = fpass + transband;
    
    if length( dev ) ~= 2 || sum( dev <= 0 )
        error( 'The DEV vector must contain two positive elements.' )
    end
    
    h.dev = dev;

end % End parseInputs

