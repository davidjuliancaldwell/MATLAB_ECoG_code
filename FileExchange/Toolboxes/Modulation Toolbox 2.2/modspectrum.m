function [P mfreqs afreqs data] = modspectrum( x, fs, varargin )
% [P MFREQS AFREQS DATA] = MODSPECTRUM( X, FS, <DEMOD>, <SUBBANDS>, <SPECOPT>, <VERBOSE> )
% 
% Computes and displays the joint-frequency modulation spectrum of a signal,
% with modulation frequency on the horizontal axis and acoustic (carrier)
% frequency on the vertical.
%
% INPUTS:
%           X - A vector time series.
%          FS - The sampling rate of X, in Hz.
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
%   <SPECOPT> - Spectral estimation options, in no particular order:
%                    Data taper: 'rect', 'bart', 'hamming', or 'hann'
%                                (default is rectangular).
%                   'normalize': Equalizes subband energies.
%                      'demean': Subtracts individual modulator means prior
%                                to windowing and taking the DFT.
%                    An integer: Sets the modulation DFT size.
%   <VERBOSE> - When equal to the string 'verbose', this option prints
%               internal information and plots time-frequency carrier
%               trajectories. The 'verbose' tag can appear anywhere after
%               the required parameters, as long as it is the last.
% 
% OUTPUTS:
%           P - An array containing the complex-valued modulator Fourier
%               transforms. The first row is the modulator transform
%               corresponding to the lowest-frequency carrier.
%      MFREQS - A vector of modulation frequency values in correspondence
%               with the horizontal dimension of P.
%      AFREQS - A vector of acoustic frequency values in correspondence
%               with the vertical dimension of P.
%        DATA - A data structure containing decomposition information,
%               used in some other Modulation Toolbox functions.
%
% See also modspecgramgui, modfilter, moddecomp, modsynth, modop_shell,
%          moddecomphilb, moddecompcog, moddecompharm, moddecompharmcog

% Revision history:
%   P. Clark - simplified the user interface and integrated with high-level
%              modulation operation functions, 09-01-10
%   P. Clark - prepared for beta testing, 04-14-09

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

% REFERENCES
% [1] S. Greenberg and B.E.D. Kingsbury, "The modulation spectrogram: in
%     pursuit of an invariant representation of speech," IEEE ICASSP 1997.
% [2] M. Vinton and L.E. Atlas, "Scalable and progressive audio codec," 
%	  IEEE ICASSP 2001.
% [3] S.M. Schimmel, L.E. Atlas and K. Nie, "Feasibility of single channel
%     speaker separation based on modulation frequency analysis," IEEE
%     ICASSP 2007.
% -------------------------------------------------------------------------


% Look for the necessary directories in the search path
checksubfolders( 'demod', 'filterbank' )

% Initial input parsing
if nargin < 2
    error( 'MODSPECTRUM requires at least two input parameters.' )
end

% --- Code From MODOP_SHELL -----------------------------------------------
[decompparams verbose opinputs] = parsedecompinputs( varargin );
[M C data] = moddecomp( x, fs, decompparams{1}, decompparams{2}, 'maximal', verbose );

% --- Modulation Spectral Analysis Starts Here ----------------------------

% Get the spectral analysis parameters
[modnfft modtaper modtapername demean normalize] = parsespectralinputs( opinputs, size(M,2) );

% Optional energy normalization, scaling each modulator signal to unit energy
if normalize
    M = diag( sparse( 1./sqrt( sum( abs(M).^2, 2 ) ) ) ) * M;
end

% De-mean the modulators individually prior to windowing
if demean
    M = detrend( M.', 'constant' ).';
end

% Window the modulators and compute their periodogram spectral estimates
P = fft( M*diag( sparse( modtaper ) ), modnfft, 2 );

% Acoustic frequency axis labels
if strcmpi( data.demodparams{1}, 'harm' ) || strcmpi( data.demodparams{1}, 'harmcog' )
    afreqs = 1:size(M,1);
    axislabel = 'Harmonic number';
else
    afreqs = round( data.filtbankparams.centers*fs/2 );
    axislabel = 'Acoustic frequency (Hz)';
end

% Modulation frequency axis labels
mfreqs = (0:modnfft-1)/modnfft*data.modfs;

if strcmpi( verbose, 'verbose' )
    % Print spectral analysis parameter settings
    printspectralparams( modtapername, modnfft, data.modfs, size(M,2) );
end

% Display the modulation spectrum
if nargout == 0
    if strcmpi( verbose, 'verbose' )
        % Make a new figure in addition to the 'verbose' output
        figure;
    end

    temp = 20*log10( fftshift( abs( P ), 2 ) );
    
    if 	~all( diff( afreqs ) == min( diff( afreqs ) ) )
        % This is the case where the subband center frequencies are
        % non-uniformly spaced. The following code interpolates P along the
        % acoustic-frequency axis using a base granularity set by STEPSIZE.
        % As a result the modulation spectra of broad subbands will appear
        % as thicker rows in the displayed joint-frequency plot.
        stepsize = min( 50, min( diff( afreqs ) / 2 ) );
        afreqs2 = afreqs(1):stepsize:afreqs(end);
        temp = interp1( afreqs, temp, afreqs2, 'nearest' );
        imagesc( mfreqs - data.modfs/2, afreqs2, temp );
    else
        % Uniformly-spaced subbands are much easier to plot.
        imagesc( mfreqs - data.modfs/2, afreqs, temp );
    end
    
    xlabel( 'Modulation frequency (Hz)' )
    ylabel( axislabel )
    title( 'Modulation Spectrogram' )
    axis xy
    climdb( 40 )
    
    % Zoom in on the modulation bandwidth
    xlim( 1.25*[-data.modbandwidth/2, data.modbandwidth/2] )
    
    % This ensures that nothing is returned as output when the function
    % call terminates
    clear P
end

end % End modspectrum


% =========================================================================
% Define your operation-specific sub-functions below.
% =========================================================================

%--------------------------------------------------------------------------
function [modnfft modtaper modtapername demean normalize] = parsespectralinputs( inputs, L )
% Extracts the spectral estimation specifications from the variable-length
% list of input parameters.

    numInputs = length( inputs );
    modnfft = L;

    % Default values for spectral estimation parameters
    modtaper = rectwin( L );
    modtapername = 'rect';
    demean = 0;
    normalize = 0;
    
    k = 1;
    
    % Extract spectral estimation parameters in no particular order
    while k <= numInputs
        if isempty( inputs{k} )
            k = k + 1;
            continue;
        end
        
        % If the kth user-supplied input is itself a cell array, then
        % append its contents to the inputs vector
        if isa( inputs{k}, 'cell' )
            extras = inputs{k};
            inputs(k) = [];
            inputs = [reshape(inputs,1,length(inputs)), reshape(extras,1,numel(extras))];
            numInputs = length( inputs );
            continue;
        end
        
        % If the argument is numeric, interpret it as the DFT size
        if isnumeric( inputs{k} )
            modnfft = inputs{k};
            
            if mod( modnfft, 1 ) ~= 0 || modnfft < 1
                warning( 'MODSPECTRUM:SPECOPT', ['Modulator DFT size ' num2str(modnfft) ' must be an integer greater than zero.'] );
                modnfft = L;
            end
            
            k = k + 1;
            continue;
        end
        
        % Search among the closed set of possible string tags
        switch inputs{k}
            case 'hamming'
                modtaper = hamming( L );
                modtapername = 'hamming';
            case {'rect', 'rectangle', 'rectangular'}
                modtaper = rectwin( L );
                modtapername = 'rect';
            case {'bartlett', 'bart'}
                modtaper = bartlett( L );
                modtapername = 'bart';
            case {'hann', 'hanning', 'vonhann'}
                modtaper = hanning( L );
                modtapername = 'hann';
            case {'demean', 'de-mean'}
                demean = 1;
            case {'normalize', 'norm'}
                normalize = 1;
            otherwise
                warning( 'MODSPECTRUM:SPECOPT', ['Unrecognized input: ''' inputs{k} '''.'] );
        end
        
        k = k + 1;
    end
    
    modtaper = modtaper / norm( modtaper );

end % End parseSpectralInputs


%--------------------------------------------------------------------------
function printspectralparams( modtapername, modnfft, modfs, L )
% Print modulation spectral estimation parameters in verbose mode

    disp( '*************************************************************' )
    disp( '            MODULATION SPECTRUM VERBOSE OUTPUT               ' )
    disp( '           =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-              ' )
    disp( ' ' )
    
    disp( '  Spectral Estimation Parameters' )
    disp( '  ------------------------------' )
    disp( ['    Modulator signal length (seconds):  ' num2str( L/modfs )] )
    disp( ['         Modulator sampling rate (Hz):  ' num2str( modfs )] )
    disp( ' ' )
    disp( ['    Modulator signal length (samples):  ' num2str( L )] )
    disp( ['                   DFT size (samples):  ' num2str( modnfft )] )
    disp( ['                 Analysis taper shape:  ' modtapername] )
    
    disp( ' ' )
    disp( '*************************************************************' )
    disp( sprintf( '\n\n' ) )
    
end % End printmodspectralparams


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
    toolboxDir = which( 'modspectrum' );
    toolboxDir = toolboxDir( 1:end-13 );

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

