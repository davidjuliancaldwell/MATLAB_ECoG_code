function y = modsynth( M, C, data, verbose )
% Y = MODSYNTH( M, C, DATA, <VERBOSE> )
% 
% Combines modulators and carriers to synthesize an audio signal.
% 
% INPUTS:
%           M - An array of modulator signals. The first row is the
%               modulator of the lowest-frequency carrier.
%           C - To allow a wide range of synthesis modes, C may be one of:
%               * An array of complex-exponential carrier signals, with
%                 rows in a one-to-one correspondence with the rows of M.
%               * A string, 'noise' to use bandlimited Gaussian carriers,
%                 or 'sine' to use fixed-frequency sinusoidal carriers. The
%                 carrier bands will be spaced in frequency according to
%                 filterbank settings or the median F0 value in DATA,
%                 depending on the demodulation method.
%        DATA - A data structure containing modulation decomposition
%               information, returned by MODDECOMP and MODFILTER.
%   <VERBOSE> - When equal to the string 'verbose', this option prints
%               internal information and plots time-frequency carrier
%               trajectories. The 'verbose' tag can appear anywhere after
%               the required parameters, as long as it is the last.
%
% OUTPUTS:
%           Y - The full-bandwidth audio signal consisting of a sum of
%               modulated carriers.
% 
% See also moddecomp, modop_shell, modspectrum, modfilter,
%          moddecomphilb, moddecompcog, moddecompharm, moddecompharmcog,

% Revision history:
%   P. Clark - created for version 2.1, 08-05-10
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
checksubfolders( 'demod', 'filterbank' )

if nargin < 3
    error( 'MODSYNTH requires at least three input parameters.' )
end
if nargin < 4
    verbose = '';
end

if ischar( C )
    % Create bandlimited noise carriers or fixed-frequency sine carriers
    % for a vocoder synthesis
    C = getvocodercarriers( C, data, size( M ) );
end

if isfield( data, 'filtbankparams' ) && ~isempty( data.filtbankparams )
    % Filterbank-based coherent or incoherent modulation
    S = modrecon( M, C );
    y = filterbanksynth( S, data.filtbankparams );
else
    % General coherent modulation, including pitch- or harmonic-based
    y = modreconharm( M, C );
end

% Append zeros to match the length of the original signal (assuming the
% modulators and carriers are derived from an actual source signal)
origlen = data.origlen;
y = matchlen( y, origlen );

if strcmpi( verbose, 'verbose' )
    % Print filterbank and demodulation parameters
    printparams( y, data.fs, data.filtbankparams, data.demodparams, data.modbandwidth, size(C,1) );
    
    % Plot the filterbank subband frequency responses
    if ~isempty( data.filtbankparams )
        filterbankfreqz( data.filtbankparams, [], fs );
    end
    
    % Overlay a spectrogram of x with the carrier frequencies
    figure, viewcarriers( y, data.fs, C, data.filtbankparams );
end

end % End modsynth


% =========================================================================
% Helper sub-functions
% =========================================================================

% -------------------------------------------------------------------------
function C = getvocodercarriers( method, data, modsize )
% Returns a vector (for one carrier in harmonic mode) or an array of
% carrier signals, using the specified vocoder method, the struct data, and
% the modulator-array size (two-element vector) modsize.

    numcarriers = modsize( 1 );

    if strcmpi( method, 'noise' )
        % Noise-vocoding option
        if isfield( data, 'filtbankparams' ) && ~isempty( data.filtbankparams )
            % Noise-excited user-defined filterbank
            C = filtersubbands( randn( data.origlen, 1 ), data.filtbankparams );
        else
            % Noise-excited filterbank consisting of subbands spaced at
            % integer multiples of the average pitch value
            medF0 = median( data.F0 / data.fs * 2 );
            filtbank = designfilterbank( (1:numcarriers)*medF0, medF0, [], 1 );
            C = filtersubbands( randn( data.origlen, 1 ), filtbank );
            difflen = size( C, 2 ) - data.origlen;
            C = C( :, 1+ceil(difflen/2):end-floor(difflen/2) );
            C = 2/medF0/numcarriers*C;
        end
    elseif strcmpi( method, 'sine' )
        % Sine-vocoding option
        if isfield( data, 'filtbankparams' ) && ~isempty( data.filtbankparams )
            % Sine-carriers are implicit in the user-defined filterbank
            C = ones( modsize );
        else
            % Construct the sinusoidal carriers as harmonics of the average
            % pitch
            medF0 = median( data.F0 / data.fs * 2 );
            C = exp( j*pi*medF0*(1:numcarriers)'*(0:data.origlen-1) );
        end
    else
        error( ['Unrecognized vocoder method: ' method] )
    end
    
end % End getvocodercarriers
    
    
% -------------------------------------------------------------------------
function xmatched = matchlen( x, L )
% Zero-pads or truncates the row-vector x to length L

    if length( x ) < L
        xmatched = [x, zeros( 1, L - length(x) )];
    else
        xmatched = x( 1:L );
    end

end % End matchLen


%--------------------------------------------------------------------------
function checksubfolders( varargin )
% Automatically adds the toolbox subfolders needed for the parent function.

    % Get the toolbox directory
    toolboxDir = which( 'modsynth' );
    toolboxDir = toolboxDir( 1:end-10 );

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
function printparams( x, fs, fbparams, demodparams, modbandwidth, numcarriers )
% Prints filterbank and demodulation parameters in verbose mode.

    disp( sprintf( '\n\n' ) )
    disp( '*************************************************************' )
    disp( '           MODULATION SYNTHESIS VERBOSE OUTPUT               ' )
    disp( '          =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=              ' )
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
        modfs = fs/fbparams.dsamplefactor;
        
        disp( ['    Number of subbands (0 to Nyquist):  ' num2str( fbparams.numbands )] )
        disp(  '      Subband center frequencies (Hz):  Uniform' )
        disp( ['            -6 dB subband widths (Hz):  ' num2str( fbparams.bandwidths*fs/2 )] )
        disp( ['            Subband decimation factor:  ' num2str( fbparams.dsamplefactor )] )
        disp( ['           Subband sampling rate (Hz):  ' num2str( modfs )] )
    else
        modfs = fs/fbparams.dsamplefactor;
        
        disp( ['    Number of subbands (0 to Nyquist):  ' num2str( fbparams.numbands )] )
        disp(  '      Subband center frequencies (Hz):  Nonuniform' )
        disp(  '            -6 dB subband widths (Hz):  Variable' )
        disp( ['            Subband decimation factor:  ' num2str( fbparams.dsamplefactor )] )
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
        disp( '    Carrier frequency range, relative to subband centers:' )
        
        if length( demodparams{4} ) == 1 && length( demodparams{5} ) == 1
            disp( ['               Left bound (Hz):  ' num2str( demodparams{4}/2*modfs-demodparams{5}/4*modfs )] )
            disp( ['              Right bound (Hz):  ' num2str( demodparams{4}/2*modfs+demodparams{5}/4*modfs )] )
        else
            disp(  '               Left bound (Hz):  Variable' )
            disp(  '              Right bound (Hz):  Variable' )
        end            
        
    elseif strcmpi( demodparams{1}, 'harm' )
        disp(  '    Method:  Harmonic pitch-tracking (coherent)' )
        disp(  ' ' )
        disp( ['             Number of harmonic carriers:  ' num2str( numcarriers )] )
        disp( ['               Modulation bandwidth (Hz):  ' num2str( modbandwidth )] )
        disp( ['       Pitch contour median filter order:  ' num2str( demodparams{2} )] )
        disp( ['       Pitch detection decimation factor:  ' num2str( demodparams{4} )] )
        disp( ['    Voiced detector sensitivity (0 to 1):  ' num2str( demodparams{3} )] )
        
    elseif strcmpi( demodparams{1}, 'hilb' )
        disp( '    Method:  Subband Hilbert envelope (incoherent)' )
    else
        disp( ['    Unrecognized demodulation method:  ''' demodparams{1} ''''] )
    end
    
    disp( ' ' )
    disp( '*************************************************************' )
   disp( sprintf( '\n\n' ) )
    
end % End printparams

