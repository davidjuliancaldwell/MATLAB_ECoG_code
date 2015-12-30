function designfilterbankgui
% DESIGNFILTERBANKGUI
%
% Runs a graphical user interface to design a multirate FIR filterbank with
% specified frequency-domain characteristics.
%
% See also designfilterbank, designfilterbankstft, filterbankfreqz, modlisting

% Revision history:
%   P. Clark - integrated with version 2.1, 08-27-10
%   P. Clark - fixed a bug in the export function, 01-13-10.
%   P. Clark - prepared for beta testing, 10-29-08.

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


% Global variable structure and default values
handles.fs = 2;                 % places Nyquist rate at +/- 1 Hz
handles.bandwidth = 0.25;       % -6dB bandwidth of the subband filter
handles.fc = 0;                 % Sinc cutoff frequency inversely related to the freq-decimation rate
handles.numHalfBands = 16;      % 4*handles.fs/handles.bandwidth / 2 <---> Hamming window
handles.numBands = 9;           % Number of real-valued subbands = floor( numHalfBands/2 ) + 1
handles.freqDec = 1;            % Frequency decimation factor
handles.winLen = 16;            % Length of subband filter impulse response
handles.timeDec = 1;            % Time decimation factor
handles.baseWinType = 'Hamming';
handles.baseWin = hamming( handles.winLen );
handles.aWin = [];                  % STFT analysis window
handles.sWin = [];                  % STFT synthesis window
handles.filtbankparams = struct;    % Filterbank parameter structure


% Create the main GUI window
guiWindow = figure( 'Visible', 'off', 'Position', [0,0,725,555], 'Color', [0.92549 0.913725 0.847059] );
% Move the GUI to the center of the screen.
movegui( guiWindow, 'center' )
% Assign the GUI a name to appear in the window title.
set( guiWindow, 'Name', 'Near-Perfect Reconstruction Filterbank Design' )


% Place GUI controls - left side (user inputs)
% Note: position vectors are in terms of the lower left corner (measured
% from the bottom of the screen), followed by width and height.
uicontrol( guiWindow, 'Style', 'text', 'String', 'Base subband shape',...
                      'Position', [35 545 150 15], 'HorizontalAlignment', 'left' );
uicontrol( guiWindow, 'Style', 'popupmenu', 'Position', [35 520 100 20],...
                      'String', {'Hamming','Hann','Rectangular'},...
                      'BackgroundColor', [1 1 1], 'Callback', @dataTaperPopup_callBack );

uicontrol( guiWindow, 'Style', 'text', 'String', 'Mainlobe width (1 = Nyquist)',...
                      'Position', [35 485 175 15], 'HorizontalAlignment', 'left' );
uicontrol( guiWindow, 'Style', 'edit', 'Position', [35 460 75 20], 'String', '0.25',...
                      'BackgroundColor', [1 1 1], 'Callback', @editBandwidth_callBack);

uicontrol( guiWindow, 'Style', 'text', 'String', 'Subband cutoff sharpness',...
                      'Position', [35 425, 150, 15], 'HorizontalAlignment', 'left' );
uicontrol( guiWindow, 'Style', 'slider', 'Position', [35 400 170 20],...
                      'Min', 1, 'Max', 51, 'SliderStep', [2 2]/50, 'Value', 1,...
                      'BackgroundColor', [.9 .9 .9], 'Callback', @freqDecSlider_callBack,...
                      'Interruptible', 'off' );

uicontrol( guiWindow, 'Style', 'text', 'String', 'Time decimation rate',...
                      'Position', [35 365 150 15], 'HorizontalAlignment', 'left' );
handles.TDslider = uicontrol( guiWindow, 'Style', 'slider', 'Position', [35 340 170 20],...
                      'Min', 1, 'Max', handles.numHalfBands, 'SliderStep', [1 1]/(handles.numHalfBands-1), 'Value', 1,...
                      'BackgroundColor', [.9 .9 .9], 'Callback', @timeDecSlider_callBack, ...
                      'Interruptible', 'off' );

% More left-side GUI objects: filterbank details
panel = uipanel( 'Title', 'Filterbank details', 'Units', 'Pixels', ...
                 'Position', [35 150 170 170] );

uicontrol( panel, 'Style', 'text', 'String', 'Number of subbands:',...
                  'Position', [10 130 120 15], 'HorizontalAlignment', 'left' );
uicontrol( panel, 'Style', 'text', 'String', 'Analysis filter order:',...
                  'Position', [10 100 120 15], 'HorizontalAlignment', 'left' );
uicontrol( panel, 'Style', 'text', 'String', 'Synthesis filter order:',...
                  'Position', [10 70 120 15], 'HorizontalAlignment', 'left' );
uicontrol( panel, 'Style', 'text', 'String', 'Time decimation:',...
                  'Position', [10 40 120 15], 'HorizontalAlignment', 'left' );
uicontrol( panel, 'Style', 'text', 'String', 'Freq. decimation:',...
                  'Position', [10 10 120 15], 'HorizontalAlignment', 'left' );

handles.NBtext = uicontrol( panel, 'Style', 'text', 'String', num2str( handles.numBands ),...
                  'Position', [130 130 30 15], 'HorizontalAlignment', 'left' );
handles.AOtext = uicontrol( panel, 'Style', 'text', 'String', num2str( handles.winLen-1 ),...
                  'Position', [130 100 30 15], 'HorizontalAlignment', 'left' );
handles.SOtext = uicontrol( panel, 'Style', 'text', 'String', num2str( handles.numHalfBands-1 ),...
                  'Position', [130 70 30 15], 'HorizontalAlignment', 'left' );
handles.TDtext = uicontrol( panel, 'Style', 'text', 'String', num2str( handles.timeDec ),...
                  'Position', [130 40 30 15], 'HorizontalAlignment', 'left' );
handles.FDtext = uicontrol( panel, 'Style', 'text', 'String', num2str( handles.freqDec ),...
                  'Position', [130 10 30 15], 'HorizontalAlignment', 'left' );
              
uicontrol( guiWindow, 'Style', 'pushbutton', 'String', 'Filterbank Imp. Response',...
                      'Position', [35 80 150 50], 'HorizontalAlignment', 'center',...
                      'Callback', @impResponse_callBack );
                  
uicontrol( guiWindow, 'Style', 'pushbutton', 'String', 'Export Design to Workspace',...
                      'Position', [35 20 150 50], 'HorizontalAlignment', 'center',...
                      'Callback', @export_callBack );

% Right-side GUI objects: frequency-response plots
uicontrol( guiWindow, 'Style', 'text', 'String', 'Subband frequency response (close up)',...
                      'Position', [285 550, 400, 15], 'HorizontalAlignment', 'left',...
                      'FontSize', 10, 'FontWeight', 'b' );
handles.plot1 = axes( 'Units', 'Pixels', 'Position', [285 340 400 200] );

uicontrol( guiWindow, 'Style', 'text', 'String', 'Filterbank impulse response (analysis + synthesis)',...
                      'Position', [285 260, 400, 15], 'HorizontalAlignment', 'left',...
                      'FontSize', 10, 'FontWeight', 'b' );
handles.plot2 = axes( 'Units', 'Pixels', 'Position', [285 50 400 200] );


% Draw the default filterbank frequency response
handles = generateFilters( handles, 1 );
subbandFreqz( handles );
filterbankFreqz( handles );


% Embed the global variable structure in the GUI window ojbect
guidata( guiWindow, handles );


% Make the GUI visible.
set( guiWindow, 'Visible', 'on' );

end   % End designfilterbankgui



% =========================================================================
% Main Computational Functions
% =========================================================================

function handles = generateFilters( handles, bothWindows )
% Based on user-provided input (stored in the handles object), this
% function constructs the analysis and synthesis subband filters, as well
% as the appropriate filterbank parameter data structure.
% 
% In the following code, filterbank design is based on the idea of
% collapsing rows in a Short-Time Fourier Transform (STFT) to form new
% subband signals. This is equivalent to convolving each column of the STFT
% with an averaging filter and downsampling (hence "frequency-downsampled
% STFT"). Such a design then requires a "base window" used to compute the
% initial STFT, which is itself multiplied in time by the inverse Fourier
% transform of the averaging filter (ie, a sinc or Dirac function in time).

    switch handles.baseWinType
        case {'Hamming', 'Hann'}

            % Compute the number of half-subbands based on the approximate 
            % -6dB bandwidth resulting from adding together M adjacent
            % subbands from a standard STFT(where M = freqDec). This is the
            % DFT size of the frequency- downsampled STFT
            handles.numHalfBands = round( handles.fs/handles.bandwidth*( 1 + 1 / handles.freqDec ) );
            
            % The analysis window must be an integer multiple of the DFT
            % size (since the frequency downsampling rate is an integer)
            handles.winLen = handles.numHalfBands * handles.freqDec;
            
            % As the cutoff frequency of a discrete sinc function, fc is
            % the -6dB point of a windowed lowpass filter design. It is set
            % to 0 in the case of freqDec = 1, which results in a simple
            % Hamming window lowpass filter (the sinc function degenerates
            % to a constant value of 1)
            handles.fc = ( handles.freqDec > 1 )*handles.bandwidth / 2;
            
            if strcmp( handles.baseWinType, 'Hamming' )
                handles.baseWin = hamming( handles.winLen );
            else
                handles.baseWin = hanning( handles.winLen );
            end

        case 'Rectangular'

            % Same as above, except rectangular windows have half the
            % window length for the same bandwidth compared to Hamming and
            % Hann windows
            handles.numHalfBands = round( handles.fs/handles.bandwidth );

            handles.winLen = handles.numHalfBands * handles.freqDec;
            handles.fc = ( handles.freqDec > 1 )*handles.bandwidth / 2;

            handles.baseWin = rectwin( handles.winLen );
    end

    % Parameters for the design of a sinc function with cutoff frequency fc
    n = -(handles.winLen-1)/2:(handles.winLen-1)/2;
    %x = 2*( handles.fc / handles.fs ) * n;
    x = 2*pi/handles.winLen*n;

    % Lowpass analysis filter via windowed-sinc design
    %handles.aWin = handles.baseWin .* sinc( x' );
    
    % Lowpass analysis filter via windowed-Dirichlet design (better than
    % sinc because subbands intersect more predictably at -6 dB point)
    handles.aWin = handles.baseWin .* diric( x', handles.freqDec );
    handles.aWin = handles.aWin / sum( handles.aWin );
    
    % Compute the complementary near-perfect reconstruction synthesis
    % filter (do this only when specifically requested, since this
    % operation requires a matrix inversion and can take a while for large,
    % very narrowband windows)
    if nargin == 2 && bothWindows
        handles.sWin = STFTwindow( handles.aWin, handles.timeDec, handles.numHalfBands );
    end
    
    % The number of real-valued (Hermitian symmetric) subbands
    handles.numBands = floor( handles.numHalfBands / 2 ) + 1;
    
    % Prevent the time-decimation factor from exceeding the length of the
    % synthesis filter
    if handles.timeDec > handles.numHalfBands
        handles.timeDec = handles.numHalfBands;
    end
    
    % Center frequencies of the equispaced subbands
    centers  = 0:2/handles.numHalfBands:2*(handles.numBands-1)/handles.numHalfBands;

    % Update the STFT filterbank parameter structure
    handles.filtbankparams.numbands = handles.numBands;             % number of subbands
    handles.filtbankparams.numhalfbands = handles.numHalfBands;     % number of half-subbands (DFT size for an STFT filterbank)
    handles.filtbankparams.dfactor = handles.timeDec;               % subband down-sampling factors
    handles.filtbankparams.centers = centers;                       % subband center frequencies
    handles.filtbankparams.bandwidths = handles.bandwidth;          % subband bandwidths (everything outside the stopband)
    handles.filtbankparams.afilters{1} = handles.aWin;              % array of lowpass analysis filters
    handles.filtbankparams.afilterorders = handles.winLen-1;        % array of analysis filter orders
    handles.filtbankparams.sfilters{1} = handles.sWin;              % array of lowpass synthesis filters
    handles.filtbankparams.sfilterorders = handles.numHalfBands-1;  % array of synthesis filter orders
    handles.filtbankparams.fshift = 1;                              % boolean: 1 = center-shifted subbands
    handles.filtbankparams.stft = 1;                                % boolean: 1 = this is an STFT filterbank
    handles.filtbankparams.keeptransients = 1;                      % boolean: 1 = do not cut off filter transients
    
end   % End generateWindow


function subbandFreqz( handles )
% Displays the individual frequency responses of several neighboring
% subbands in order to give an idea of how the filterbank sections up the
% frequency domain. Note, this is only the analysis filterbank, which
% precedes the synthesis filterbank during signal reconstruction

    axes( handles.plot1 );

    DFTsize = 4*2^ceil( log2( handles.winLen ) );
    faxis = -handles.fs/2:handles.fs/DFTsize:handles.fs/2-handles.fs/DFTsize;
    waxis = 2*pi*( faxis / handles.fs );
    n = [0:handles.winLen-1]';

    % Constrain the plot to within a few bandwidths of the central subband
    % position
    bandwidth = handles.bandwidth/handles.fs*DFTsize;
    f1 = max( 1, round( DFTsize/2 - 2*bandwidth ) );
    f2 = min( DFTsize, round( DFTsize/2 + 2*bandwidth ) );

    kmax = 5;
    
    % A sequence of RGB values corresponding to a strong blue in the middle
    % and monotonically lighter blues before and after
    g = [ [kmax/(kmax+1):-1/(kmax+1):0]' ; [1/(kmax+1):1/(kmax+1):kmax/(kmax+1)]' ];
    RGBvec = [zeros( 2*kmax+1, 1 ), g, ones( 2*kmax+1, 1 )];

    % Display several neighboring subbands, with the central one depicted
    % with a heavy blue line
    for k = -kmax:kmax
        if k == 0 
            lineWidth = 2.5;
        else
            lineWidth = 1;
        end

        % Evaluate the spectrum at just the frequencies visible between f1
        % and f2
        F = freqz( handles.aWin.*exp( j*2*pi*n*k*handles.freqDec/handles.winLen ), 1, waxis( f1:f2 ) );
        plot( faxis( f1:f2 ), 20*log10( abs( F ) ), 'Color', RGBvec( k+6, : ), 'LineWidth', lineWidth );
        hold on
    end

    % Draw the -6dB line
    line( [faxis( f1 ) faxis( f2 )], [-6 -6], 'LineStyle', ':', 'Color', 'k' )
    
    % Draw vertical lines showing the new Nyquist rate after
    % time-decimation
    newNyq = 1 / handles.timeDec;
    line( [-newNyq -newNyq], [5 -60], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2 )
    line( [newNyq newNyq], [5 -60], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2 )

    axis( [faxis( f1 ) faxis( f2 ) -60 6] )
    xlabel( 'Normalized rads/s (1 = Nyquist)' )
    ylabel( 'dB Magnitude' )

    hold off
    
end   % End subbandFreqz


function filterbankFreqz( handles )
% This function displays the "impulse response" of the current filterbank,
% including both the analysis and synthesis stages. In other words, an
% impulse signal is broken into subbands and reconstituted, with the goal
% of obtaining a perfect replica at the output. Note that for multirate
% filterbanks, this process is not really LTI (specifically, it's not
% time-invariant), so the "impulse response" is not as generally-applicable
% a term as it is in LTI filter theory.
    
    axes( handles.plot2 );
    
    % Decompose an impulse signal into subbands and recombine them to
    % form the "impulse response" of the analysis/synthesis filterbank
    impulse = [1; zeros( 1024, 1 )];
    impSubbands = filtersubbands( impulse, handles.filtbankparams );
    impResponse = filterbanksynth( impSubbands, handles.filtbankparams );
    
    error = impResponse;
    error( 1 ) = error( 1 ) - 1;
    
    % The SNR measures the ratio of error energy to original signal energy
    SNR = 20*log10( 1/norm( error, 2 ) );
    
    % Display the spectral estimate of the impulse response
    IR = 20*log10( abs( fft( impResponse ) ) );
    IR = IR( 1:floor(length(impResponse)/2)+1 );
    minMag = min( IR );
    maxMag = max( IR );

    plot( [1:floor(length(impResponse)/2)+1]/length(impResponse)*2, IR )
    
    if maxMag - minMag < 1
        minMag = minMag - 0.5;
        maxMag = maxMag + 0.5;
    end

    axis( [0 1 minMag maxMag] )
    
    % Superimpose a text box with the SNR measurement
    text( 0.65, minMag+0.9*(maxMag-minMag), ['SNR = ' num2str( SNR ) ' dB'],...
          'FontWeight', 'b', 'BackgroundColor', [1 1 1], 'EdgeColor', [0 0 0] );

    xlabel( 'Normalized frequency (1 = Nyquist)' )
    ylabel( 'dB magnitude' )

end   % End filterbankFreqz



% =========================================================================
% GUI Event Callback Functions
% =========================================================================

function dataTaperPopup_callBack( hObject, event )
% Facilitates a change of base window shape (Hamming, Hann, rectangular) in
% the design of the subband magnitude frequency response.

    handles = guidata( gcbo );

    str = get( hObject, 'String' );
    val = get( hObject, 'Value' );
    handles.baseWinType = str{ val };

    handles = generateFilters( handles, 0 );
    subbandFreqz( handles );
    handles = updateGUIcontrols( handles );

    guidata( gcbo, handles );

end   % End popup_callBack


function editBandwidth_callBack( hObject, event )
% Sets the subband filter bandwidth (measured between -6dB points), which
% is limited to the Nyquist rate

    handles = guidata( gcbo );

    num = str2double( get( hObject, 'String' ) );

    if ~isnan( num ) && num <= handles.fs/2
        handles.bandwidth = num;
    else
        handles.bandwidth = handles.fs/2;
        set( hObject, 'String', num2str( handles.fs / 2 ) );
    end

    handles = generateFilters( handles, 0 );
    subbandFreqz( handles );
    handles = updateGUIcontrols( handles );

    guidata( gcbo, handles );

end   % End editBandwidth_callBack


function freqDecSlider_callBack( hObject, event )
% Allows incremental adjustment of the frequency decimation factor, which
% directly controls the subband cutoff sharpness and subband spacing (both
% increase with larger decimation factors)

    handles = guidata( gcbo );
    
    handles.freqDec = nearestOdd( get( hObject, 'Value' ) );
    set( hObject, 'Value', handles.freqDec );

    handles = generateFilters( handles, 0 );
    subbandFreqz( handles );
    handles = updateGUIcontrols( handles );
    
    guidata( gcbo, handles );

end   % End freqDecSlider_callBack


function timeDecSlider_callBack( hObject, event )
% Allows incremental adjustment of the time decimation factor

    handles = guidata( gcbo );
    
    handles.timeDec = round( get( hObject, 'Value' ) );
    set( hObject, 'Value', handles.timeDec );

    handles = generateFilters( handles, 0 );
    subbandFreqz( handles );
    handles = updateGUIcontrols( handles );

    guidata( gcbo, handles );

end   % End timeDecSlider


function handles = updateGUIcontrols( handles )
% Based on current filterbank parameters, this function updates displays
% and the bounds on the time-decimation slider control (which depend on
% the frequency-decimationg rate)

    if get( handles.TDslider, 'Value' ) > handles.numHalfBands
        set( handles.TDslider, 'Value', handles.numHalfBands );
    end
    set( handles.TDslider, 'Max', handles.numHalfBands );
    set( handles.TDslider, 'SliderStep', [1 1] / (handles.numHalfBands-1) );
    
    set( handles.NBtext, 'String', num2str( handles.numBands ) );
    set( handles.AOtext, 'String', num2str( handles.winLen-1 ) );
    set( handles.SOtext, 'String', num2str( handles.numHalfBands-1 ) );
    set( handles.TDtext, 'String', num2str( handles.timeDec ) );
    set( handles.FDtext, 'String', num2str( handles.freqDec ) );

    % Now erase the impulse response plot, and inform the user on how to
    % generate a new one with the current filterbank parameters
    axes( handles.plot2 );
    cla
    axis( [0 1 0 1] )
    text( 1/5, 1/2, sprintf( ['Click the button on the left to evaluate the \n'...
                              '            filterbank impulse response.'] ) )
    
end   % End updateGUIcontrols


function impResponse_callBack( hObject, event )
% This callback responds to a button click by evaluating the filterbank
% "impulse response" (somewhat of a misnomer for non-LTI multirate
% filterbanks) based on the current filterbank settings. Computing the
% impulse response can be an intensive operation depending on the
% filterbank, so this function is delegated to an explicit user command
% rather than an automatic update for every parameter modification.

    handles = guidata( gcbo );

    axes( handles.plot2 );
    
    % Give the user a 'busy' message
    cla
    axis( [0 1 0 1] )
    text( 2/5, 1/2, 'Please wait...' )

    % The '1' tells the function to design the STFT synthesis filter
    handles = generateFilters( handles, 1 );
    filterbankFreqz( handles );

end   % End impResponse_callBack


function export_callBack( hObject, event )
% Exports the filterbank parameter structure embedded within the GUI to a
% struct in the Matlab console workspace, where it can be used by other
% scripts.

    handles = guidata( gcbo );

    % The '1' tells the function to design the STFT synthesis filter
    handles = generateFilters( handles, 1 );
    
    assignin( 'base', 'filtbankparams_from_gui', handles.filtbankparams );
    
    disp( sprintf( ['\nThe filterbank design parameters have been saved to your'...
                    '\nworkspace as a struct named filtbankparams_from_gui.\n'] ) )

    guidata( gcbo, handles );
    
end   % End export_callBack



% =========================================================================
% Utility Functions
% =========================================================================

function compWin = STFTwindow( window, hopDistance, DFTsize )
% Designs a reconstruction window for a Short-Time Fourier Transform
% that is downsampled in time (with rate equal to hopDistance) and also
% possibly downsampled in frequency (with rate equal to length(window)/DFTsize).
% Perfect reconstruction is possible when hopDistance <= length(window) and
% DFTsize = length(window). Near-perfect reconstruction is possible with
% careful use of frequency and time downsampling.

    L1 = length( window );
    L2 = DFTsize;

    M  = L1 / L2;       % frequency downsampling rate, must be odd
    M2 = (M-1) / 2;
    R  = hopDistance;

    if mod( M, 1 ) ~= 0
        error( 'Window length must be divisible by DFTsize' );
    end
    
    % The downsampling rate must be odd due to the symmetry of shifts in p
    % in Portnoff's equations (below)
    if mod( M, 2 ) == 0
        error( 'The window length divided by the DFTsize must be odd (this is the frequency dowmsampling rate).' )
    end

    % The C matrix contains downsampled subsets of the analysis window that
    % weight the corresponding coefficients of the reversed synthesis window
    C = zeros( M*min( R, L2 ), L2 );

    % The D vector contains the constraints imposed on each inner product,
    % either 0 or 1
    D = zeros( M*min( R, L2 ), 1 );

    % Using Portnoff's equation for perfect reconstruction, the product of 
    % each downsamled sub-set of the reversed analysis window and synthesis
    % window must sum to 1. That is,
    %
    %   f( n-sR ) dotprod h( sR-n+p*L2 ) = 1, p  = 0, for all n
    %                                    = 0, p ~= 0, for all n
    %
    %   where s indexes f and h, R is the downsample rate, and n is the
    %   downsample offset.
    % 
    % (M.R. Portnoff, "Time-frequency representations of digital signals and
    % systems based on short-time Fourier analysis," Eq. 64, 1980.)
    for p = 0:M-1
        for n = 1:min( R, L2 )
            temp = upsample( downsample( window( 1+p*L2:(p+1)*L2 ), R, n-1 ), R, n-1 );

            if length( temp ) < L2
                temp = [temp; zeros( L2-length(temp), 1 )];
            elseif length( temp ) > L2
                temp = temp( 1:L2 );
            end

            C( p*min(R,L2)+n, : ) = temp;   % p ~= 0 in Portnoff's eqn
            D( p*min(R,L2)+n, 1 ) = p==M2;  % p  = 0 in Portnoff's eqn
        end
    end

    % C * compWin = D, which might be over- or under-determined depending on
    % parameters. A pseudo-inverse based on SVD achieves a least-squares
    % solution to Portnoff's equations.
    compWin = pinv( C )*D;
    compWin = compWin( end:-1:1 );

end % End STFTwindow


function y = nearestOdd( x )
% Converts the floating-point value x to the nearest odd integer.

    if mod( x, 2 ) == 0
        y = x + 1;
    elseif mod( x, 2 ) <= 1
        y = ceil( x );
    elseif mod( x, 2 ) > 1
        y = floor( x );
    end

end   % End nearestOdd

