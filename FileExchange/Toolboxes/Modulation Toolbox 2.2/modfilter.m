function [y Mfilt M C data] = modfilter( x, fs, filterband, filtertype, varargin )
% [Y MFILT M C DATA] = MODFILTER( X, FS, FILTERBAND, FILTERTYPE, <DEMOD>, <SUBBANDS>, <VERBOSE> )
% 
% INPUTS:
%           X - A vector time series.
%          FS - The sampling rate of X, in Hz.
%  FILTERBAND - A two-element vector defining a band in modulation
%               frequency (Hz), in the following format:
%                   [0 FC]  - lowpass or highpass
%                   [F1 F2] - bandpass or bandstop
%  FILTERTYPE - A string indicating the type of modulation filter to
%               implement: 'pass' for lowpass and bandpass, 'stop' for
%               highpass and bandstop.
%     <DEMOD> - A data structure containing demodulation options. This can
%               be a string indicating the demodulation method, or
%               alternatively a cell array specifying parameter values in
%               the fashion of the MODDECOMP... functions. The default
%               setting is {'cog', 0.1, 0.05}.
%                   {'HILB'}
%                   {'COG', <carrwin>, <carrwinhop>}
%                       carrwin - seconds.
%                       carrwinhop - seconds.
%                   {'HARM', <numharmonics>, <voicingsens>, <F0smoothness>}
%                       numharmonics - a positive integer.
%                        voicingsens - a decimal value (0 to 1).
%                       F0smoothness - a positive integer.
%                   {'HARMCOG', <carrwin>, <carrwinhop>, ...
%                               <numharmonics>, <voicingsens>, <F0smoothness>}
%  <SUBBANDS> - A vector containing subband frequency boundaries, or a
%               scalar value specifying the bandwidth for uniform-width
%               subbands. All values are in Hz. One modulator-carrier pair
%               derives from each subband. The default is SUBBANDS = 150.
%   <VERBOSE> - When equal to the string 'verbose', this option prints
%               internal information and plots time-frequency carrier
%               trajectories. The 'verbose' tag can appear anywhere after
%               the required parameters, as long as it is the last.
% 
% OUTPUTS:
%           Y - The final modulation-filtered audio signal.
%       MFILT - The filtered (downsampled) modulators used to synthesize Y.
%           M - The original (downsampled) modulators detected from X.
%           C - The original (downsampled) carriers detected from X, and
%               used to synthesize Y.
%        DATA - A data structure containing decomposition and filtering
%               information.
% 
% See also modspectrum, moddecomp, modsynth, modop_shell
%          moddecomphilb, moddecompcog, moddecompharm, moddecompharmcog

% Revision history:
%   P. Clark - created for version 2.1, 04-17-10
%   A. Greenhall - initial idea and prototype code, 10-xx-09

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


% Make sure the necessary directories are in the search path.
checksubfolders( 'demod', 'filterbank', 'filter' );

% Initial input parsing
if nargin < 4
    error( 'MODFILTER requires at least four input parameters.' )
end

% --- Code From MODOP_SHELL -----------------------------------------------
[decompparams verbose opinputs] = parsedecompinputs( varargin );
[M C data] = moddecomp( x, fs, decompparams{1}, decompparams{2}, 'maximal', verbose );

% --- Modulation Filtering Implementation Starts Here ---------------------

% Checks the filter frequency values in terms of Hz, unlike the internal
% routines within DESIGNFILTER which produce error messages in terms of
% normalized frequency (Nyquist = 1).
checkmodfilterparams( filterband, fs );

% Filter each modulator using a linear-phase multirate implementation.
% Filter transients are truncated so that the size of M2 equals that of M.
h = designfilter( filterband/data.modfs*2, filtertype );
Mfilt = narrowbandfilter( M, h, 1 );

if strcmpi( verbose, 'verbose' )
    % Print filtering parameter settings
    printfilterparams( h, fs );
end

% Synthesize using the filtered modulators with the original carriers
y = modsynth( Mfilt, C, data );

% Update the modulation data structure with filtering specifications
data.filterband = h.filterband/2*data.modfs;    % filter passband, Hz
data.transband  = h.transband/2*data.modfs;     % filter transition band, Hz
data.filtertype = h.type;                       % string indicating the filter type, e.g., 'lowpass'

end % End modfilter


% =========================================================================
% Define your operation-specific sub-functions below.
% =========================================================================

%--------------------------------------------------------------------------
function printfilterparams( h, fs )
% Print modulation filtering parameters in verbose mode

    disp( '*************************************************************' )
    disp( '             MODULATION FILTER VERBOSE OUTPUT                ' )
    disp( '             =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=               ' )
    disp( ' ' )
    
    disp( '  Multirate Filter Specifications' )
    disp( '  -------------------------------' )
    disp( ['                        Filter type:  ' h.type] )
    disp( [' Pass/stop-band freq. interval (Hz):  ' num2str( h.filterband/2*fs )] )
    disp( ['          Transition bandwidth (Hz):  ' num2str( h.transband/2*fs )] )
    disp( ['               Passband ripple (dB):  ' num2str( 20*log10( 1+h.dev(1) ) )] )
    disp( ['          Stopband attenuation (dB):  ' num2str( 20*log10( 1/h.dev(2) ) )] )
    disp( ['              Group delay (samples):  ' num2str( h.delay )] )
    disp( ['              Group delay (seconds):  ' num2str( h.delay/fs )] )
    disp( ['         No. of downsampling stages:  ' num2str( length(h.filters)-1 )] )
    
    disp( ' ' )
    disp( '*************************************************************' )
    disp( sprintf( '\n\n' ) )
    
end % End printmodspectralparams

%--------------------------------------------------------------------------
function checkmodfilterparams( filterband, fs )
% Check filter passband values for errors

    % Check for input errors
    if length( filterband ) ~= 2 || filterband( 1 ) > fs/2 || filterband( 2 ) > fs/2 ...
                                 || filterband( 1 ) < 0 || filterband( 2 ) < 0
        error( 'The frequency band vector must contain two non-negative elements each less than or equal to FS/2.' )
    end
    if filterband( 2 ) <= filterband( 1 )
        error( 'Frequency band values must be strictly increasing.' )
    end

end % End checkmodfilterparams


% =========================================================================
% The following are utility functions from MODOP_SHELL that are probably
% best left unaltered.
% =========================================================================

% -------------------------------------------------------------------------
function [decompparams vflag remaining] = parsedecompinputs( inputs )
% This function extracts the DEMOD and SUBBANDS parameters from a
% variable-length cell array of optional input arguments, and places them
% into the DECOMPPARAMS list. Any remaining optional parameters are
% returned in the REMAINING output list.
% Note that this function does not extract a DFACTOR parameter for the
% DECOMPPARAMS list! From the standpoint of MODOP_SHELL, modulator
% downsampling is considered a 'function-specific' argument.
% Also, the 'verbose' command can follow any argument as long as it is at
% the end.

    % Check the 'verbose' parameter (always at the end of the input list,
    % if present at all)
    % -------------------------------------------------------------------
    if ~isempty( inputs ) && isa( inputs{end}, 'char' ) && strcmpi( inputs{end}, 'verbose' )
        vflag = 'verbose';
        inputs = indexcellarray( inputs, 1:length(inputs)-1 );
    else
        vflag = '';
    end

    % Any missing or empty arguments will be handled internally by
    % moddecomp() and replaced by default values.
    numinputs = length( inputs );
    
    if numinputs == 0 
        decompparams = {[], []};
    elseif numinputs == 1
        decompparams = {inputs{1}, []};
    else
        decompparams = {inputs{1}, inputs{2}};
    end
    
    % Return the remaining optional input arguments
    remaining = indexcellarray( inputs, 3:length(inputs) );
    
end % End parsedecompinputs


%--------------------------------------------------------------------------
function checksubfolders( varargin )
% Automatically adds the toolbox subfolders needed for the parent function.

    % Get the toolbox directory
    toolboxDir = which( 'modfilter' );
    toolboxDir = toolboxDir( 1:end-11 );

    % Get the toolbox directory listing
    d = dir( toolboxDir );

    % Get Matlab's search path
    p = path;
    
    check = ones( 1, length( varargin ) );
    warnStr = [];

    % Look for the subfolder names in the presumed toolbox directory, and
    % add them to Matlab's search path if they are present. This allows
    % modspecgram to be run easily without manually adding paths to the
    % required subfolders.
    for k = 1:length( varargin )

        i = 1;

        % Check to see if the subfolder is already a part of Matlab's search path
        if ~isempty( strfind( p, [toolboxDir '\' varargin{ k }] ) ) || ...
           ~isempty( strfind( p, [toolboxDir '/' varargin{ k }] ) )
            check( k ) = 0;
            continue
        end

        % Search the presumed toolbox directory for the necessary subfolder
        while i <= length( d ) && check( k ) == 1

            if strcmp( d( i ).name, varargin{ k } )
                addpath( [toolboxDir '/' varargin{ k }] );
                check( k ) = 0;
            end

            i = i + 1;
        end

        % Check to see if the subfolder is still absent
        if check( k ) == 1
            warnStr = [warnStr, varargin{ k }, ' '];
        end
    end

    % If any of the folder names were not found, then alert the user to the
    % problem
    if sum( check ) > 0
        msgid = 'MODOP:SUBFOLDERS';
        msg   = ['Could not find the required subfolders(s): '...
                  warnStr '. '...
                  'Refer to filepath.m within the Modulation Toolbox for help.'];

        warning( msgid, msg );
    end

end % End checksubfolders


%--------------------------------------------------------------------------
function c2 = indexcellarray( c1, indx )
% Returns a cell array containing the elements of c1 located at the index
% numbers in indx. This function ignores out-of-bound errors, so for
% example, c1 = {1, 2, 3} and indx = 4 will return c2 = {} since there is
% no fourth element.

    c2 = {};
    
    for i = 1:length( indx )
        try c2{ i } = c1{ indx( i ) }; catch end
    end

end % End indexcellarray

