function [M C data] = moddecomp( x, fs, varargin )
% [M C DATA] = MODDECOMP( X, FS, <DEMOD>, <SUBBANDS>, <DFACTOR>, <VERBOSE> )
% 
% Decomposes a signal into a collection of low-frequency modulator
% envelopes and their corresponding high-frequency carriers.
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
%                       numharmonics - a positive integer
%                        voicingsens - a decimal value (0 to 1)
%                       F0smoothness - a positive integer
%                   {'HARMCOG', <carrwin>, <carrwinhop>, ...
%                               <numharmonics>, <voicingsens>, <F0smoothness>}
%  <SUBBANDS> - A vector containing subband frequency boundaries, or a
%               scalar value specifying the bandwidth for uniform-width
%               subbands. All values are in Hz. One modulator-carrier pair
%               derives from each subband. The default is SUBBANDS = 150.
%   <DFACTOR> - The integer downsampling factor to use on the modulator
%               waveforms, or a string equal to 'maximal' which will
%               downsample the modulators as much as possible without
%               aliasing. The default value is 1 (no downsampling).
%   <VERBOSE> - When equal to the string 'verbose', this option prints
%               internal information and plots time-frequency carrier
%               trajectories. The 'verbose' tag can appear anywhere after
%               the required parameters, as long as it is the last.
%
% OUTPUTS:
%           M - An array of modulator signals. The first row is the
%               modulator corresponding to the lowest-frequency carrier.
%           C - An array of complex-exponential carrier signals, with rows
%               in a one-to-one correspondence with the rows of M.
%        DATA - A data structure containing decomposition information,
%               used in some other Modulation Toolbox functions.
%
% See also modsynth, modop_shell, modspectrum, modfilter
%          moddecomphilb, moddecompcog, moddecompharm, moddecompharmcog

% Revision history:
%   P. Clark - integrated with version 2.1, 09-01-10
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


% Look for the necessary directories in the search path
checksubfolders( 'demod', 'filterbank', 'filter' )

if nargin < 2
    error( 'MODDECOMP requires at least two input parameters.' )
end

% Get the filterbank and demodulation specifications from the list of
% inputs
[filtbankparams demodparams dfactor modfs verbose] = parseinputs( x, fs, varargin );

% Extract modulator waveforms from x, using a time-frequency decomposition
% (fixed filterbank or pitch-based) followed by the specified demodulation
% algorithm
[M C F0 modbandwidth] = demod( x, fs, filtbankparams, demodparams, dfactor );

if verbose
    % Print filterbank and demodulation parameters
    printparams( x, fs, filtbankparams, demodparams, modbandwidth, modfs, size(C,1) );
    
    % Plot the filterbank subband frequency responses
    if ~isempty( filtbankparams )
        filterbankfreqz( filtbankparams, [], fs );
    end
    
    % Overlay a spectrogram of x with the carrier frequencies
    figure, viewcarriers( x, fs, C, filtbankparams );
end

% Consolidate additional side information
data = struct;
data.origlen = length( x );
data.fs = fs;                           % Hz
data.filtbankparams = filtbankparams;   % for use with filtersubbands() and filterbanksynth()
data.demodparams = demodparams;         % for use with demod() sub-function
data.F0 = F0;                           % Hz
data.modbandwidth = modbandwidth;       % Hz
data.modfs = modfs;                     % Hz
data.dfactor = dfactor;                 % modulator downsampling factor

end % End moddecomp


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function [filtbankparams fulldemodparams dfactor modfs verbose] = parseinputs( x, fs, inputs )
% Extracts the filterbank and demodulation specifications from the
% variable-length list of input parameters.

    % Check the required input parameters for errors
    % -------------------------------------------------------------------
    if numel( x ) ~= length( x )
        error( 'The time series X must be a 1D vector.' )
    end
    if isempty( fs )
        error( 'Please specify a sampling rate.' )
    elseif fs <= 0
        error( 'FS must be a positive number.' )
    end

    % Check for the 'verbose' parameter (always at the end of the optional
    % input list, if present at all)
    % -------------------------------------------------------------------
    if ~isempty( inputs ) && isa( inputs{end}, 'char' ) && strcmpi( inputs{end}, 'verbose' )
        verbose = 1;
        inputs = indexcellarray( inputs, 1:length(inputs)-1 );
    else
        verbose = 0;
    end
        
    numInputs = length( inputs );
    
    % Retrieve the given demodulation parameters (optional input #1)
    % -------------------------------------------------------------------
    if numInputs > 0 && ~isempty( inputs{1} )
        % User-specified demodulation parameters
        if isa( inputs{1}, 'char' )
            % String denoting method of demodulation
            demodparams = {};
            demodparams{1} = inputs{1};
        elseif isa( inputs{1}, 'cell' )
            % Cell array containing demodulation method and parameters
            demodparams = inputs{1};
        else
            error( 'DEMODPARAMS must be a string or a cell array.' )
        end
    else
        % Default demodulation method
        demodparams = {'cog'};
    end
    
    % Retrive the frequency-division resolution (optional input #2)
    % -------------------------------------------------------------------
    if numInputs > 1 && ~isempty( inputs{2} )
        % User-specified frequency resolution
        freqdiv = inputs{2};
    elseif strcmpi( demodparams{1}, 'harm' ) || strcmpi( demodparams{1}, 'harmcog' )
        % The default bandwidth will depend on the detected pitch
        freqdiv = [];
    else
        % Default subband bandwidth (Hz)
        if 150 < fs
            freqdiv = 150;
        else
            freqdiv = fs / 4;
        end
    end
    
    % Check the SUBBANDS (previously FREQDIV) parameter for errors
    % ------------------------------------------------------------------
    if numel( freqdiv ) > 1 && ( min( freqdiv ) < 0  || max( freqdiv ) > fs/2 )
        error( 'Subband cutoffs (SUBBANDS) must be in the range [0 FS/2] inclusive.' );
    elseif numel( freqdiv ) == 1 && ( min( freqdiv ) <= 0  || max( freqdiv ) >= fs/2 )
        error( 'Subband bandwidth (SUBBANDS) must be in the range (0 FS/2) non-inclusive.' );
    end
    
    
    % Retrieve the modulation downsampling factor (optional input #3)
    % -------------------------------------------------------------------
    if numInputs > 2 && ~isempty( inputs{3} )
        % User-specified downsampling factor
        dfactor = inputs{3};
    else
        % The default option is no downsampling
        dfactor = 1;
    end
    
    % Check the DECFACTOR parameter for errors
    % ------------------------------------------------------------------
    if isa( dfactor, 'double' )
        if numel( dfactor ) > 1 || dfactor < 1 || mod( dfactor, 1 ) ~= 0
            error( 'The numeric value of DFACTOR must be a positive scalar integer.' )
        end
    elseif isa( dfactor, 'char' ) && ~strcmpi( dfactor, 'maximal' )
        error( ['Unrecognized DFACTOR option ' dfactor '.'] )
    end


    % Get filterbank and demodulation parameters, deliverable to the
    % DEMOD() sub-function
    % ------------------------------------------------------------------
    [filtbankparams freqdiv dfactor] = parsefilterbank( fs, demodparams, freqdiv, dfactor );
    modfs = fs / dfactor;
    fulldemodparams = parsedemod( fs, demodparams, filtbankparams, freqdiv, dfactor, modfs );
    
end % End parseinputs


% -------------------------------------------------------------------------
function [filtbankparams freqdiv dfactor] = parsefilterbank( fs, demodparams, freqdiv, dfactor )
% Constructs filterbank-related specifications from user-provided inputs as
% well as default values for non-provided inputs. FREQDIV will be empty if
% the user has left it unspecified for harmonic-based demodulation.

    if strcmpi( demodparams{1}, 'harm' ) || strcmpi( demodparams{1}, 'harmcog' )
        % Harmonic-based demodulation
        
        if ~isempty( freqdiv ) && numel( freqdiv ) > 1
            error( 'For harmonic-based demodulation, FREQDIV must be a scalar number less than FS/2.' )
        end
        
        % Use no filterbank for harmonic-based demodulation
        filtbankparams = [];
        
        if isa( dfactor, 'char' ) && strcmpi( dfactor, 'maximal' )
            % Under the 'maximal' option the modulators will be downsampled
            % as much as possible without aliasing. In the case where
            % FREQDIV is unspecified, we force a default value of 75 Hz so
            % that DECFACTOR is clearly defined.
            if isempty( freqdiv )
                freqdiv = 75;
            end
            
            dfactor = floor( fs/2/freqdiv );
        end
        
    elseif numel( freqdiv ) == 1
        % Uniformly-spaced filterbank subband demodulation
        
        numhalfbands = floor( fs / freqdiv );
        sharpness = 15;
        
        if isa( dfactor, 'char' ) && strcmpi( dfactor, 'maximal' )
            % Under the 'maximal' option the modulators will be downsampled
            % as much as possible without aliasing the subbands.
            dfactor = floor( fs/2/freqdiv );
        end
        
        % STFT filterbank with uniform subband spacing equal to the
        % user-supplied FREQDIV argument
        filtbankparams = designfilterbankstft( numhalfbands, sharpness, dfactor, 0 );
        
    elseif numel( freqdiv ) > 1
        % Non-uniformly spaced filterbank subband demodulation
        
        [subbandcenters subbandwidths] = cutoffs2fbdesign( freqdiv/fs*2 );
        
        if strcmpi( dfactor, 'maximal' )
            % Under the 'maximal' option the modulators will be downsampled
            % as much as possible without aliasing the subbands.
            dfactor = max( 1, floor( 1/max( subbandwidths ) ) );
        end
        
        % Non-overlapping subband filterbank, with user-specified subband
        % edges contained in FREQDIV, and decimation in each subband.
        filtbankparams = designfilterbank( subbandcenters, subbandwidths, [], dfactor, 0 );
    end
    
    % Alert the user to possible aliasing of the modulators when using a
    % decimated filterbank
    if ~isempty( filtbankparams ) && fs/dfactor < max( fs/2*filtbankparams.bandwidths )
        warning( 'MODDECOMP:DOWNSAMPLING', 'The specified downsampling factor may cause aliasing of the modulator signals. To avoid aliasing, FS/DFACTOR should be greater than min( SUBBANDS ).' );
    end

end % End parsefilterbank


% -------------------------------------------------------------------------
function fulldemodparams = parsedemod( fs, demodparams, filtbankparams, freqdiv, dfactor, modfs )
% Constructs demodulation-related specifications from user-provided inputs
% as well as default values for non-provided inputs.

    if strcmpi( demodparams{1}, 'cog' ) || strcmpi( demodparams{1}, 'harmcog' )
        % Demod parameters shared by the filterbank-based COG and
        % harmonic-based COG demodulation methods
        
        if length( demodparams ) < 2 || isempty( demodparams{2} )
            % Carrier-detection window length (seconds)
            cogwinlen = 0.1;
        else
            cogwinlen = demodparams{2};
        end
        if length( demodparams ) < 3 || isempty( demodparams{3} )
            % Carrier-detection hop distance (seconds)
            cogwinhop = cogwinlen / 2;
        else
            cogwinhop = demodparams{3};
        end
    end
    
    if strcmpi( demodparams{1}, 'cog' )
        % Subband center frequencies (see filterbank design above)
        if filtbankparams.fshift == 1
            % All subband signals are frequency-shifted to baseband
            cogcenters = 0;
        else
            % All subband signals are bandpass
            cogcenters = filtbankparams.centers;
        end
        
        % Subband bandwidths in normalized frequency
        cogbandwidths = dfactor*filtbankparams.bandwidths;
        
        if any( cogbandwidths > 2 )
            % Make sure the bandwidths don't exceed the modulation sampling
            % rate
            cogbandwidths = min( cogbandwidths, 2+zeros( size(cogbandwidths) ) );
        end
    end
    
    if strcmpi( demodparams{1}, 'harm' ) || strcmpi( demodparams{1}, 'harmcog' )
        % Demod parameters shared by pure-harmonic and harmonic-based COG
        % demodulation methods
        
        index = 2*strcmpi( demodparams{1}, 'harm' ) + 4*strcmpi( demodparams{1}, 'harmcog' );

        if length( demodparams ) < index
            % The default number of carriers depends on the pitch estimate,
            % which is detected in the demod() subfunction
            numcarriers = [];
        else
            numcarriers = demodparams{index};
        end
        if length( demodparams ) < index+1 || isempty( demodparams{index+1} )
            % The default F0 voicing sensitivity penalizes false voiced
            % detection the same as false unvoiced detection.
            voicingsens = 0.5;
        else
            voicingsens = demodparams{index+1};
        end
        if length( demodparams ) < index+2 || isempty( demodparams{index+2} )
            % The default 'F0 smoothness' factor corresponds to a median
            % filter order of 3 and a sampling rate of 2000 Hz.
            F0smoothness = 2;
        else
            F0smoothness = demodparams{index+2};
        end

        % Convert the 'F0 smoothness' parameter into F0 median filter
        % length and an F0-detection frequency range. For smoothness
        % factors 1, 2 and 3, the median filter length is 1, 3 and 5. For
        % increasing smoothness, the median filter remains constant but the
        % frequency range doubles for each increment, which increases
        % temporal resolution for autocorrelation peak-picking.
        if F0smoothness < 1 || mod( F0smoothness, 1 ) ~= 0
            error( 'The F0smoothness parameter must be a positive integer.' )
        elseif F0smoothness <= 3
            medfiltlen = 1+2*(F0smoothness-1);
            F0freqrange = min( 2000, fs/2 );
        else
            medfiltlen = 5;
            F0freqrange = min( 2000*(F0smoothness-2), fs/2 );
        end
        
        % Modulation bandwidth in normalized frequency units (if this is
        % empty, then the modulation bandwidth will adapt according to the
        % minimum detected pitch value)
        modbandwidth = freqdiv/fs*2;
    end
    
    % Construct final demodulation parameter vectors, to be used later by
    % the demod() subfunction
    if strcmpi( demodparams{1}, 'hilb' ) || strcmpi( demodparams{1}, 'hilbert' )
        fulldemodparams = {'hilb'};
    elseif strcmpi( demodparams{1}, 'cog' )
        fulldemodparams = {'cog', ceil( modfs*cogwinlen ), ceil( modfs*cogwinhop ), cogcenters, cogbandwidths};
    elseif strcmpi( demodparams{1}, 'harm' ) || strcmpi( demodparams{1}, 'harmonic' )
        fulldemodparams = {'harm', voicingsens, medfiltlen, F0freqrange, numcarriers, modbandwidth};
    elseif strcmpi( demodparams{1}, 'harmcog' )
        fulldemodparams = {'harmcog', voicingsens, medfiltlen, F0freqrange, ceil( fs*cogwinlen ), ceil( fs*cogwinhop ), numcarriers, modbandwidth};
    else
        error( ['Unrecognized demodulation method: ''' demodparams{1} ''''] )
    end 

end % End parsedemod


% -------------------------------------------------------------------------
function [M C F0 modbandwidth] = demod( x, fs, filtbankparams, demodparams, dfactor )
% Demodulates the vector x according to the given filterbank and
% demodulation parameters. The outputs are the resulting modulator array M,
% carrier array C, and the detected pitch F0 (harmonic methods only). The
% last output is the modulation bandwidth, which is computed from filterbank
% settings in the Hilbert and COG methods or from the F0 trajectory in
% harmonic methods.

    if ~isa( demodparams, 'cell' )
        error( 'demodparams must be a cell array.' )
    end
    
    if strcmpi( demodparams{1}, 'hilb' ) || strcmpi( demodparams{1}, 'hilbert' )
        % Incoherent Hilbert-envelope demodulation (subband magnitudes)
        S = filtersubbands( x, filtbankparams );
        [M C] = moddecomphilb( S );
        modbandwidth = min( fs/filtbankparams.dfactor, max(filtbankparams.bandwidths/2*fs) );
        
    elseif strcmpi( demodparams{1}, 'cog' )
        % Coherent spectral-center-of-gravity demodulation (complex subband
        % envelopes)
        S = filtersubbands( x, filtbankparams );
        [M C] = moddecompcog( S, demodparams{2}, demodparams{3}, demodparams{4}, demodparams{5} );
        modbandwidth = min( fs/filtbankparams.dfactor, max(filtbankparams.bandwidths/2*fs) );
        
    elseif strcmpi( demodparams{1}, 'harm' ) || strcmpi( demodparams{1}, 'harmonic' )
        % Coherent harmonic demodulation (complex envelopes of
        % pitch-synchronous time-varying subbands)
        F0 = detectpitch( x, fs, demodparams{2}, demodparams{3}, demodparams{4} );
        
        if ~isempty( demodparams{5} ) && demodparams{5} > floor( 1/max(F0) )
            % Check the number-of-harmonics parameter
            demodparams{5} = floor( 1/max(F0) );
            warning( 'MODDECOMP:NUMHARMONICS', ['Given the maximum detected pitch and the sampling rate, the requested number of harmonics is too large. Defaulting to the maximum allowable number of ' num2str( floor(1/max(F0)) ) '.'] )
        end
        
        [M C] = moddecompharm( x, F0, demodparams{5}, demodparams{6}, [], dfactor );
        
        % Convert units to Hz
        if ~isempty( demodparams{6} )
            modbandwidth = fs/2*demodparams{6};
        else
            modbandwidth = fs/2*min( F0 );
        end
        F0 = fs/2*F0;
        
    elseif strcmpi( demodparams{1}, 'harmcog' )
        % Coherent harmonic-COG demodulation (complex envelopes of
        % quasi-harmonic time-varying subbands)
        F0 = detectpitch( x, fs, demodparams{2}, demodparams{3}, demodparams{4} );
        
        if ~isempty( demodparams{7} ) && demodparams{7} > floor( 1/max(F0) )
            % Check the number-of-harmonics parameter
            demodparams{7} = floor( 1/max(F0) );
            warning( 'MODDECOMP:NUMCARRIERS', ['Given the maximum detected pitch and the sampling rate, the requested number of harmonics is too large. Defaulting to the maximum allowable number of ' num2str( floor(1/max(F0)) ) '.'] )
        end
        
        [M C] = moddecompharmcog( x, F0, demodparams{5}, demodparams{6}, demodparams{7}, demodparams{8}, [], dfactor );
        
        % Convert units to Hz
        if ~isempty( demodparams{6} )
            modbandwidth = fs/2*demodparams{8};
        else
            modbandwidth = fs/2*min( F0 );
        end
        F0 = fs/2*F0;
        
    else
        error( ['Unrecognized demodulation method: ''' demodparams{1} '''.'] );
    end

    if ~exist( 'F0', 'var' )
        % 'cog' and 'hilb' demodulation methods do not detect the
        % fundamental frequency
        F0 = [];
    else
        % Warn the user when the modulation bandwidth is broad enough to
        % encompass multiple carriers (in harmonic demodulation modes only)
        if min( F0 ) < modbandwidth
            warning( 'MODDECOMP:MODBANDWIDTH', ['The specified modulation bandwidth (i.e., the SUBBANDS parameter) is greater than the minimum measured pitch frequency of ' num2str(min(F0)) ' Hz.'] )
        end
    end
    
    % Alert the user to possible modulator aliasing after downsampling
    % (applies to harmonic-based demodulation methods, where the modulation
    % bandwidth may be not known until the pitch is detected)
    if fs/dfactor < modbandwidth
        modbandwidth = fs/dfactor;
        warning( 'MODDECOMP:DOWNSAMPLING', 'The specified downsampling factor may cause aliasing of the modulator signals. To avoid aliasing, FS/DFACTOR should be greater than min( SUBBANDS ).' )
    end

end % End demod


%--------------------------------------------------------------------------
function checksubfolders( varargin )
% Automatically adds the toolbox subfolders needed for the parent function.

    % Get the toolbox directory
    toolboxDir = which( 'moddecomp' );
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
% Returns a cell array containing the elements of c1 indicated by the index
% numbers in indx. This function ignores out-of-bound errors, so for
% example, c1 = {1, 2, 3} and indx = 4 will return c2 = {} since there is
% no fourth element.

    c2 = {};
    
    for i = 1:length( indx )
        try c2{ i } = c1{ indx( i ) }; catch end
    end

end % End indexcellarray


%--------------------------------------------------------------------------
function printparams( x, fs, fbparams, demodparams, modbandwidth, modfs, numcarriers )
% Prints filterbank and demodulation parameters in verbose mode. fbparams
% is the structure returned by one of the toolbox filterbank functions,
% demodparams is returned by the parseinputs() sub-function, modbandwidth
% is in Hz, and numcarriers is the integer number of modulator-carrier
% pairs.

    disp( sprintf( '\n' ) )
    disp( '*************************************************************' )
    disp( '         MODULATION DECOMPOSITION VERBOSE OUTPUT             ' )
    disp( '         -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-             ' )
    disp( ' ' )
    
    N = length( x );
    dur = N/fs;
    
    disp( ['  Signal length:  ' num2str(dur) ' seconds (' num2str( length(x) ) ' samples)'] )
    disp( ['  Sampling rate:  ' num2str( fs ) ' Hz'] )
    
    disp( ' ' ), disp( ' ' )
    disp( '  Filterbank Parameters' )
    disp( '  ---------------------' )
    if isempty( fbparams )
        
        disp( '    No filterbank selected, since the demodulation option is ' )
        disp( '    harmonic rather than subband-based.' )

    elseif fbparams.stft == 1
        
        disp( ['    Number of subbands (0 to Nyquist):  ' num2str( fbparams.numbands )] )
        disp(  '      Subband center frequencies (Hz):  Uniform' )
        disp( ['            -6 dB subband widths (Hz):  ' num2str( fbparams.bandwidths*fs/2 )] )
        disp( ['            Subband decimation factor:  ' num2str( fbparams.dfactor )] )
        disp( ['           Subband sampling rate (Hz):  ' num2str( modfs )] )
    else
        
        disp( ['    Number of subbands (0 to Nyquist):  ' num2str( fbparams.numbands )] )
        disp(  '      Subband center frequencies (Hz):  Nonuniform' )
        disp(  '            -6 dB subband widths (Hz):  Variable' )
        disp( ['            Subband decimation factor:  ' num2str( fbparams.dfactor )] )
        disp( ['           Subband sampling rate (Hz):  ' num2str( modfs )] )
    end

    disp( ' ' ), disp( ' ' )
    disp( '  Demodulation Parameters' )
    disp( '  -----------------------' )
    if strcmpi( demodparams{1}, 'cog' )
        disp(  '    Method:  Time-varying subband spectral center-of-gravity' )
        disp(  '             (Coherent)' )
        disp( ' ' )
        disp( ['    Carrier detection window length (seconds):  ' num2str( demodparams{2}/modfs )] )
        disp( ['    Carrier detection window length (samples):  ' num2str( demodparams{2} )] )
        disp( ['    Carrier detection window skip   (seconds):  ' num2str( demodparams{3}/modfs )] )
        disp( ['    Carrier detection window skip   (samples):  ' num2str( demodparams{3} )] )
        disp( ' ' )
        disp( ['                Max. modulator bandwidth (Hz):  ' num2str( modbandwidth )] )
        disp( ['                 Modulator sampling rate (Hz):  ' num2str( modfs )] )
        
    elseif strcmpi( demodparams{1}, 'harm' )
        disp(  '    Method:  Harmonic pitch-tracking (coherent)' )
        disp(  ' ' )
        disp( ['             Number of harmonic carriers:  ' num2str( numcarriers )] )
        disp( ['                Modulator bandwidth (Hz):  ' num2str( modbandwidth )] )
        disp( ['            Modulator sampling rate (Hz):  ' num2str( modfs )] )
        disp( ' ' )
        disp( ['    Voiced detector sensitivity (0 to 1):  ' num2str( demodparams{2} )] )
        disp( ['       Pitch contour median filter order:  ' num2str( demodparams{3} )] )
        disp( ['    Pitch detection frequency range (Hz):  ' num2str( demodparams{4} )] )


    elseif strcmpi( demodparams{1}, 'harmcog' )
        disp(  '    Method:  Harmonic with carrier-independent center-of-gravity refinement' )
        disp(  '             (Coherent)' )
        disp( ' ' )
        disp( ['    Carrier detection window length (seconds):  ' num2str( demodparams{5}/fs )] )
        disp( ['    Carrier detection window length (samples):  ' num2str( demodparams{5} )] )
        disp( ['    Carrier detection window skip   (seconds):  ' num2str( demodparams{6}/fs )] )
        disp( ['    Carrier detection window skip   (samples):  ' num2str( demodparams{6} )] )
        disp(  ' ' )
        disp( ['       Number of quasi-harmonic carriers:  ' num2str( numcarriers )] )
        disp( ['           Max. modulator bandwidth (Hz):  ' num2str( modbandwidth )] )
        disp( ['            Modulator sampling rate (Hz):  ' num2str( modfs )] )
        disp( ' ' )
        disp( ['       Pitch contour median filter order:  ' num2str( demodparams{2} )] )
        disp( ['       Pitch detection decimation factor:  ' num2str( demodparams{4} )] )
        disp( ['    Voiced detector sensitivity (0 to 1):  ' num2str( demodparams{3} )] )

        
    elseif strcmpi( demodparams{1}, 'hilb' )
        disp( '    Method:  Subband Hilbert envelope (incoherent)' )
        disp( ' ' )
        disp( ['                Max. modulator bandwidth (Hz):  ' num2str( modbandwidth )] )
        disp( ['                 Modulator sampling rate (Hz):  ' num2str( modfs )] )
    else
        disp( ['    Unrecognized demodulation method:  ''' demodparams{1} ''''] )
    end
    
    disp( ' ' )
    disp( '*************************************************************' )
    disp( sprintf( '\n\n' ) )
    
end % End printparams

