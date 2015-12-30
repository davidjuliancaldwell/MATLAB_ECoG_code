function varargout = modspecgramgui(varargin)
% MODSPECGRAMGUI Run graphical user interface for analysis/synthesis of
% the modulation spectrogram of a signal.
%
% See also modspectrum, modlisting

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                    %
%    Copyright (c) ISDL, University of Washington, 2003-2010.        %
%                                                                    %
%    This software is distributed for evaluation purposes only,      %
%    and may not be used for any commercial activity. It remains     %
%    the property of ISDL, University of Washington.                 %
%    Modification of this software for personal use is allowed.      %
%    Redistribution of this software is prohibited.                  %
%                                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Based in part on original specgram code by 
%                       L. Shure, 1-1-91
%                       T. Krauss, 4-2-93, updated
% Copyright 1988-2000 The MathWorks, Inc.
% $Revision: 1.1.1.1 $  $Date: 2003/04/03 20:35:11 $
%
% MODSPECGRAMGUI:       Chad Heinemann (UW EE Undergraduate)
%                       Steven Schimmel (UW EE Graduate, 2005)
%                       Pascal Clark (UW EE Graduate, 2010)
% Transforms:           Jeff Thompson (UW EE Graduate)
% Supervision:          Prof. Les Atlas
%
% Revision History:
%
%       08/20/2010 P. Clark
%       - updated for compatibility with version 2.1 of the toolbox
%       - added an "update filterbank" button to the demodulation options
%         dialog.
%
%       11/20/2009 P. Clark
%       - changed the 'modfilter' and 'modutil' folders to 'filter' and
%         'util'.
%
%       04/17/2009 P. Clark
%       - major revisions for coherent demodulation. replaced the HLT
%       option with two discrete wavelet transforms, plus made a few other
%       small changes to the interface.
%
%       02/07/2005 S. Schimmel
%       - several small bug-fixes. added colormapping options.
%
%       07/07/2003 S. Schimmel
%       - cleaned up version for distribution
%
%       12/16/2002 S. Schimmel
%       - merged FFT and HLT
%       - updated documentation
    

if nargin == 0  % LAUNCH GUI

    % Look for the necessary directories in the search path
    checksubfolders( 'demod', 'filterbank', 'util', 'filter' );
    
    fig = openfig(mfilename,'reuse');
    
	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));
    set(fig,'DefaultAxesFontName','Arial');

	% initialize data to contain figure handles
	data = guihandles(fig);
    data.fig = fig;         % store handle to fig to enable exit from menu

    % filename parameters of input file
    data.wavname  = 0;
    data.filename = 0;
    data.prefdir  = 0;
    
    % pcm data variables
    data.pcm = [];
    data.fs  = 8000;
    
    data.basesizes    = [32 64 128 256 512 1024];
    data.modsizes     = [0.125 0.25 0.5 1 2 4 8];       % seconds
    data.carrwinsizes = [32 62 125 250 500];      % milliseconds
    
    % Filterbank parameters
    data.numbands    = 256;
    data.basehop     = data.numbands / 4;
    data.freqdec     = 1;
    data.basesize    = data.numbands * data.freqdec;
    data.baseoverlap = data.basesize - data.basehop;

    % Data structure for use with filtersubbands() and filterbanksynth(),
    % which are external functions also included in the Coherent Modulation
    % Toolbox.
    data.filterbankparams = designfilterbankstft( data.numbands, data.freqdec, data.basehop );

    % Modulation segmentation parameters
    data.moddur      = 1;   % (seconds) this is a nominal value, where the
                            % actual modulation window length will be a power
                            % of 2 and will therefore depend on the signal
                            % sampling rate
    data.modsize     = 256;
    data.modoverlap  = 0.75*data.modsize;
    data.modhop      = data.modsize-data.modoverlap;
    data.blocksize   = data.basehop*data.modhop;
    
    % number of frames and current frame number
    data.index       = 1;
    data.length      = 0;
    
    data.isoriginal = 1;
    data.start      = 0;
    data.stop       = 0;
    data.isaltered  = 0;
    data.maskidx    = 1;

    data.selection  = 0;     % handle to current selection rectangle
    data.region     = [];    % region in mask corresponding to selection
    data.mask       = ones(data.basesize/2+1,data.modsize/2+1);
    data.prevmask   = data.mask;
    data.showmask   = 1;
    
    data.zoomed     = 0;
    data.axisNormal = [];
    data.axisZoomed = [];

    data.colormap     = 'Jet';
    data.colorscaling = 0; % 0=auto frame, 1=auto signal, 2=fixed
    data.colorsc      = [0 0];
    data.colorbar     = 0; % 0=off, 1=on
    
    data.recon      = [];

    % set the default demodulation method
    data.demodmethod   = 'COG';     % other options are 'Hilbert' and 'harmonic'
    data.cogwindur     = 125;       % milliseconds
    
    % function handle for the default demodulation method
    data.fundemodmethod = @demodcog;   % other options are @demodcog and @demodharmonic
    
    % function handles for modulation transform
    data.modtransform = 'fourier';
    data.funinitmodxform = @fftinitmodtransform;
    data.funforwmodxform = @fftmodtransform;
    data.funinvmodxform  = @fftinvmodtransform;
    
    % demodulation parameters (default values)
    data.instfreqcutoff = 4/8000*2;
    data.cogwindur = 1000/8;    % milliseconds
    data.cogwin = 16;
    data.coghop = 4;
    
    % pitch detection default parameters (Hz)
    data.minf0 = 80;    % sets the modulation bandwidth
    data.voicingsensitivity = 0.5;
    data.f0smoothness = 2;  % this value translates to median filt len = 3 and freq cutoff = 2000
    data.f0medfiltlen = 3;
    data.f0freqcutoff = 2000;
    data.numharmonics = 20;
    
    data = redraw(data);
    updatedisplay(data);
    
    guidata(fig,data);
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

    [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
    
%   The following is commented out so that the locations of errors are
%   printed in the Matlab console window
%	try
% 		[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
%	catch
%		disp(lasterr);
%	end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function data = LoadSignal(data)
% If stereo wave, average right and left channels
if size(data.pcm,2) == 2
    data.pcm = (data.pcm(:,1)+data.pcm(:,2))/2;
end

% Remove silence from beginning of file if it exists
% FIXME: this assumes zero-mean signal. we need that for playback, but not for
% analysis. Maybe don't do silence removal in the future
% data.pcm(1:min(find(data.pcm~=0)))=[];
data.recon = [];

data.isoriginal = 1;
data.isaltered = 0;

if data.maskidx>1
    name = sprintf('%s (%d)', data.filename, data.maskidx);
else
    name = data.filename;
end;
t = sprintf('Modulation Spectrogram - %s - %.2f seconds at %dHz', name, length(data.pcm)/data.fs, data.fs); 
set(data.figure1,'name', t);

% make axesSignal current
axes(data.axesSignal);

% draw time signal
plot((0:length(data.pcm)-1)/data.fs,data.pcm);
xlim([0 (length(data.pcm)-1)/data.fs]);
ylim( [min(data.pcm) max(data.pcm)] )

% set up marker frames, where timeframe has been commented because we no
% longer display the smaller box in the time-domain plot indicating the
% modulation window overlap
%data.timeframe = rectangle('position', [-1 -1 0.5 2]);
%set(data.timeframe,'edgecolor', 'k', 'linestyle', ':', 'linewidth', 2);
data.bigtimeframe = rectangle('position', [-1 -1 0.5 2]);
set(data.bigtimeframe,'edgecolor', 'k', 'linestyle', ':', 'linewidth', 2);
drawnow;

% draw spectrogram
hwb = waitbar(0, 'Computing Spectrogram...');
movefig(hwb, 0.5, 0.75, data);
drawnow;

% make axesSpecGram current
axes(data.axesSpecGram);

% This line is commented because I think it's better to make the
% spectrogram viewing parameters consistent rather than tied to the current
% filterbank settings (PC, 4-14-09)
%specgram(data.pcm,data.basesize,data.fs,sinewindow(data.basesize),data.baseoverlap);
specgram(data.pcm,round(data.fs/8),data.fs,sinewindow(round(data.fs/8)),round(0.95*data.fs/8));

close(hwb);
xlim([0 (length(data.pcm)-1)/data.fs]);
xlabel('Time (s)');
ylabel([]);
%set(gca,'YTickLabel', [0:10:data.fs/2000]);

% set up marker frames, where specgramframe has been commented because we
% no longer display the smaller box in the spectrogram indicating the
% modulation window overlap
%data.specgramframe = rectangle('position', [-1 0 0.5 data.fs/2]);
%set(data.specgramframe,'edgecolor', 'k', 'linestyle', ':', 'linewidth', 2);
data.bigspecgramframe = rectangle('position', [-1 0 0.5 data.fs/2]);
set(data.bigspecgramframe,'edgecolor', 'k', 'linestyle', ':', 'linewidth', 2);
drawnow;

% Set the segmentation window length as a power of 2 in the downsampled
% timeline
ms = 2^round( log2( data.moddur*data.fs/data.basehop ) );
data.modoverlap = data.modoverlap/data.modsize * ms;
data.modsize = ms;
data.modhop = data.modsize - data.modoverlap;

% Set the spectral COG window length (dependent on signal fs)
data.cogwin = 2^ceil( log2( ceil( data.cogwindur/1000*data.fs/data.basehop ) ) );
data.coghop = max( 1, data.cogwin / 4 );

% Set the modulator matrix dimensions
data.modmatrixdim = [data.numbands, data.modsize];

% Set the pitch-synchronous settings (dependent on signal fs). This takes
% place in DemodOptions_pbOK_Callback(), but must also occur here in the
% event that the user changes the Demod options BEFORE loading a signal and
% determining fs.
if strcmp( data.demodmethod, 'harmonic' )
    hwb = waitbar(0, 'Detecting Pitch...');
    movefig(hwb, 0.5, 0.75, data);
    drawnow;

    data.F0 = detectpitch( data.pcm, data.fs, data.voicingsensitivity, data.f0medfiltlen, data.f0freqcutoff );
    data.numharmonics = max( 1, min( 40, floor( 1 / max( data.F0 ) ) ) );
    
    data.basehop    = floor( data.fs/(2*data.minf0) );
    oafactor        = data.modoverlap/data.modsize;
    data.modsize    = 2^round( log2( data.moddur*data.fs/data.basehop ) );
    data.modoverlap = oafactor*data.modsize;
    data.modhop     = data.modsize - data.modoverlap;

    data.modmatrixdim = [data.numharmonics, data.modsize];
    
    data.modbandwidth = 2/data.fs*data.minf0;
    
    close( hwb );
end

% Set the default playback option
data.playEntireSignal = 1;

% make axesMS current
axes(data.axesMS);
data = compute_ms(data);
data = redraw(data);
updatedisplay(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = pbOpen_Callback(h, eventdata, handles, varargin)

data = guidata(h);
curdir = pwd;
if data.prefdir ~= 0
    cd(data.prefdir);
end;
[filename,pathname] = uigetfile('*.wav','Select input wav file...');
cd(curdir);

if ~isequal(filename,0) || ~isequal(pathname,0)

    % Update the file and path names
    data.wavname  = [pathname,filename];
    data.filename = filename;
    data.prefdir  = pathname;
    data.fs       = 0;
    try
        [data.pcm data.fs] = wavread(data.wavname);
    catch
        data.pcm = [];
        data.fs  = -1;
    end;
    if (data.fs == -1) || (data.fs == 0),
        uiwait(warndlg(sprintf('An error occurred trying to open ''%s''', data.wavname),'Error opening wav-file','modal'));
        return;
    end;
    data.maskidx  = 1;
    
    data = LoadSignal(data);
    
    guidata(h,data);
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbSave_Callback(h, eventdata, data)
    
if length(data.recon)~=0
    curdir = pwd;
    if data.prefdir ~= 0
        cd(data.prefdir);
    end;
    [filename,pathname] = uiputfile('*.wav','Save masked file...');
    cd(curdir);

    if ~isequal(filename,0) | ~isequal(pathname,0)
        data = guidata(h);
        writedata = data.recon*max(abs(data.pcm))/max(abs(data.recon));
        savedest = [pathname filename];
        wavwrite(writedata,data.fs,savedest);
        data.prefdir = pathname;
    end

    guidata(h, data);
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbImport_Callback(h, eventdata, data)

data.mainhandle = h;

fig = openfig('modspecgramgui_import.fig','reuse');
set(fig, 'Color', get(0, 'defaultUicontrolBackgroundColor'));
movefig(fig, 0.5, 0.5, data);
handles = guihandles(fig);
mainhandles = guihandles(h);

% determine vectors and scalars in workspace
w = evalin('base','whos');
wvectors = [];
wscalars = [];
for v = 1:length(w),
    c = w(v).class;
    s = w(v).size;
    if strcmp(c,'double') & length(s)==2
        if (min(s)==1 | min(s)==2) & max(s)>1
            wvectors{end+1} = w(v).name;
        elseif min(s)==1 & max(s)==1
            wscalars{end+1} = w(v).name;
        end;
    end;
end;

data.wvectors = wvectors;
if isempty(wvectors)
    wvectors = '<none>';
    set(handles.pbOK, 'enable', 'off');
    set(handles.lbVectors, 'enable', 'off');
end;

data.wscalars = wscalars;
if isempty(wscalars)
    wscalars = '<none>';
    set(handles.rbSampleFrequency, 'value', 0);
    set(handles.rbFixed, 'value', 1);
    set(handles.rbSampleFrequency, 'enable', 'off');
    set(handles.lbScalars, 'enable', 'off');
else
    set(handles.rbSampleFrequency, 'value', 1);
    set(handles.rbFixed, 'value', 0);
end;

set(handles.lbVectors, 'string', wvectors);
set(handles.lbScalars, 'string', wscalars);

% FIXME: save all data in this figure too!?
guidata(fig,data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function Import_rbSampleFrequency_Callback(h, eventdata, data)
handles = guihandles(h);
set(handles.rbSampleFrequency, 'value', 1);
% set(handles.lbScalars,         'enable', 'on');
set(handles.rbFixed,           'value', 0);
% set(handles.editFs,            'enable', 'off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function Import_rbFixed_Callback(h, eventdata, data)
handles = guihandles(h);
set(handles.rbSampleFrequency, 'value', 0);
% set(handles.lbScalars,         'enable', 'off');
set(handles.rbFixed,           'value', 1);
% set(handles.editFs,            'enable', 'on');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function Import_pbOK_Callback(h, eventdata, data)
data = guidata(h);
handles = guihandles(h);
mainhandles = guihandles(data.mainhandle);
   
% copy all settings from the dialog to the gui data
varname = data.wvectors{get(handles.lbVectors, 'value')};
data.filename = ['[workspace] ' varname];
data.pcm = evalin('base', [varname ';']);
switch (get(handles.rbSampleFrequency, 'value'))
    case 0
        data.fs = str2num(get(handles.editFs, 'string'));
    case 1
        data.fs = evalin('base', [data.wscalars{get(handles.lbScalars,'value')} ';']);
end;

if (get(handles.cbNormalize, 'value')==1)
    data.pcm = data.pcm - mean(data.pcm);
    data.pcm = data.pcm / max(abs(data.pcm(:)));
end;

data.maskidx = 1;

% close import dialog
[object, figure] = gcbo;
delete(figure);

h = data.mainhandle;

data = LoadSignal(data);
guidata(h,data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function Import_pbCancel_Callback(h, eventdata, handles)
data = guidata(h);
[object, figure] = gcbo;
delete(figure);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbExport_Callback(h, eventdata, data)
name = inputdlg('Name of variable', 'Export reconstructed signal to workspace...');
if isempty(name)
    return;
else
    name = name{1};
end;

if ~isvarname(name)
    % show error message
    uiwait(errordlg(sprintf('Sorry, "%s" is not a valid variable name!', name), 'Export reconstructed signal to workspace...', 'modal'));
    return;
end;

w = evalin('base', 'whos');
if strmatch(name, {w.name},'exact')>0
    overwrite=1;
else
    overwrite=0;
end;
if overwrite
    switch questdlg({['There already exists a variable with the name ''' ...
                     name ...
                     ''' in the workspace. By exporting the reconstructed signal, ' ...
                     'the existing variable will be replaced.']
                     ' '
                     'Are you sure you want to export?'},...
              'Variable name conflict','Yes','No','No')
    case 'Yes'
       overwriteOK = 1;
    case 'No'
       overwriteOK = 0;
    end
else
    overwriteOK = 1;
end

if overwriteOK
    assignin('base', name, data.recon);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbUseMasked_Callback(h, eventdata, data)

switch questdlg('Are you sure you want to use the masked signal as the input signal?', ...
                'Use masked as input...','Yes','No','No')
case 'Yes'
    data.maskidx = data.maskidx + 1;
    data.pcm     = data.recon - mean(data.recon);
    data.pcm     = data.pcm / max(abs(data.pcm));
    data = LoadSignal(data);
end
guidata(h,data);   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = pbPlayOriginal_Callback(h, eventdata, data)

if isempty(data.pcm)
    beep
    warndlg('No sound has been loaded!','Error','modal');
    return
end

% Either play the original signal from beginning to end, or play the
% selected frame
if data.playEntireSignal
    endPoint   = length( data.pcm );
    startPoint = 1;
else
    endPoint   = min( data.modhop*data.index*data.basehop, length( data.pcm ) );
    startPoint = max( endPoint - data.modsize*data.basehop, 1 );
end

% Play the wav clip
data.player = audioplayer( data.pcm, data.fs );
play( data.player, [startPoint endPoint] );

guidata( h, data );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = pbPlayMasked_Callback(h, eventdata, data)

if isempty(data.recon)
    beep
    warndlg('No wav file has been selected!','Error','modal');
    return
end

% Either play the reconstructed signal from beginning to end, or play the
% selected frame
if data.playEntireSignal
    endPoint   = length( data.recon );
    startPoint = 1;
else
    endPoint   = min( data.modhop*data.index*data.basehop, length( data.recon ) );
    startPoint = max( endPoint - data.modsize*data.basehop, 1 );
end

% Play the energy-normalized wav clip
y = data.recon * norm(data.pcm)/norm(data.recon);
data.player = audioplayer( y, data.fs );
play( data.player, [startPoint endPoint] );

guidata( h, data );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = pbStopPlayback_Callback(h, eventdata, data)

stop( data.player );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = radioPlayEntireSignal_Callback(h, eventdata, data)

set( data.radioPlayEntireSignal, 'value', 1 );
set( data.radioPlaySelectedFrame, 'value', 0 );

data.playEntireSignal = 1;

guidata( h, data );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = radioPlaySelectedFrame_Callback(h, eventdata, data)

set( data.radioPlayEntireSignal, 'value', 0 );
set( data.radioPlaySelectedFrame, 'value', 1 );

data.playEntireSignal = 0;

guidata( h, data );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function varargout = Restore_pushbutton_Callback(h, eventdata, handles, varargin)
data = guidata(h);
handles = guihandles(h);
axes_handle = gca;
[data.pcm data.fs] = wavread(data.wavname);

%remove silence if exists
i = 1;
while(data.pcm(i) == 0)
    i = i+1;
end
data.pcm = data.pcm(i:end);
data.recon = [];
data.isoriginal = 1;
data.isaltered = 0;
data.index = 1;
data.zoomed = 0;

data = redraw(data);
updatedisplay(data);
guidata(h,data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbFourierTransform_Callback(h, eventdata, data)

if strcmp(data.modtransform,'fourier')==1, return; end;

% Update menu checkmarks
set([data.pbWaveletD4Transform, data.pbWaveletLA8Transform], 'checked', 'off');
set(data.pbFourierTransform, 'checked', 'on');

data.modtransform = 'fourier';
data.funinitmodxform = @fftinitmodtransform;
data.funforwmodxform = @fftmodtransform;
data.funinvmodxform  = @fftinvmodtransform;

if ~isempty( data.pcm )
    data = compute_ms(data,'same');     % compute mod spectrum using existing carrier estimates
    data = redraw(data);
    updatedisplay(data);
end;
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbWaveletD4Transform_Callback(h, eventdata, data)

if strcmp(data.modtransform,'waveletD4')==1, return; end;

% Update menu checkmarks
set([data.pbFourierTransform, data.pbWaveletLA8Transform], 'checked', 'off');
set(data.pbWaveletD4Transform, 'checked', 'on');

data.modtransform = 'waveletD4';
data.funinitmodxform = @waveletD4initmodtransform;
data.funforwmodxform = @waveletD4modtransform;
data.funinvmodxform  = @waveletD4invmodtransform;

if ~isempty( data.pcm )
    data = compute_ms(data,'same');     % compute mod spectrum using existing carrier estimates
    data = redraw(data);
    updatedisplay(data);
end;
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbWaveletLA8Transform_Callback(h, eventdata, data)

if strcmp(data.modtransform,'waveletLA8')==1, return; end;

% Update menu checkmarks
set([data.pbFourierTransform, data.pbWaveletD4Transform], 'checked', 'off');
set(data.pbWaveletLA8Transform, 'checked', 'on');

data.modtransform = 'waveletLA8';
data.funinitmodxform = @waveletLA8initmodtransform;
data.funforwmodxform = @waveletLA8modtransform;
data.funinvmodxform  = @waveletLA8invmodtransform;

if ~isempty( data.pcm )
    data = compute_ms(data,'same');     % compute mod spectrum using existing carrier estimates
    data = redraw(data);
    updatedisplay(data);
end;
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbOdft_Callback(h, eventdata, data)

% DEPRECATED: we no longer support the HLT in the modulation spectrogram
% GUI
% 
% if strcmp(data.modtransform,'odft')==1, return; end;
% 
% % Update menu checkmarks
% set([data.pbFourier, data.pbOdft, data.pbMdct], 'checked', 'off');
% set(data.pbOdft, 'checked', 'on');
% 
% data.modtransform = 'odft';
% data.funinitmodxform = @odftinitmodtransform;
% data.funforwmodxform = @odftmodtransform;
% data.funinvmodxform  = @odftinvmodtransform;
% data.funexitmodxform = @odftexittransform;
% 
% if ~isempty( data.pcm )
%     data = compute_ms(data);
%     data = redraw(data);
%     updatedisplay(data);
% end;
% guidata(h, data);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbMdct_Callback(h, eventdata, data)

% DEPRECATED: we no longer support the HLT in the modulation spectrogram
% GUI
% 
% if strcmp(data.modtransform,'mdct')==1, return; end;
% 
% % Update menu checkmarks
% set([data.pbFourier, data.pbOdft, data.pbMdct], 'checked', 'off');
% set(data.pbMdct, 'checked', 'on');
% 
% data.modtransform = 'mdct';
% data.funinitmodxform = @mdctinitmodtransform;
% data.funforwmodxform = @mdctmodtransform;
% data.funinvmodxform  = @mdctinvmodtransform;
% data.funexitmodxform = @mdctexittransform;
% 
% if ~isempty( data.pcm )
%     data = compute_ms(data);
%     data = redraw(data);
%     updatedisplay(data);
% end;
% guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbDemodOptions_Callback(h, eventdata, handles)

data = guidata(h);
data.mainhandle = h;

fig = openfig('modspecgramgui_demodoptions2.fig','reuse');
guidata(fig,data);
set(fig, 'Color', get(0, 'defaultUicontrolBackgroundColor'));
movefig(fig, 0.5, 0.25, data);

handles = guihandles(fig);
mainhandles = guihandles(h);

% Load current windowing settings
set(handles.popup_modsizes, 'string', cellstr(num2str(data.modsizes(:))));
v = find(data.modsizes==data.moddur);
if (isempty(v))
    v = 1;
end;
set(handles.popup_modsizes, 'value', v);

overlap50 = (data.modoverlap == round(.5*data.modsize));
set(handles.radio_modwindow50,'value',overlap50);
set(handles.radio_modwindow75,'value',~overlap50);

% Load current demod settings
set(handles.popup_carrwinsizes, 'string', cellstr(num2str(data.carrwinsizes(:))));
v = find(data.carrwinsizes==data.cogwindur);
if (isempty(v))
    v = 1;
end;
set(handles.popup_carrwinsizes, 'value', v);

switch data.demodmethod
    case 'Hilbert'
        set( handles.radio_hilbert, 'value', 1 );
        set( handles.radio_cog, 'value', 0 );
        set( handles.radio_harmonic, 'value', 0 );
    case 'COG'
        set( handles.radio_hilbert, 'value', 0 );
        set( handles.radio_cog, 'value', 1 );
        set( handles.radio_harmonic, 'value', 0 );
    case 'harmonic'
        set( handles.radio_hilbert, 'value', 0 );
        set( handles.radio_cog, 'value', 0 );
        set( handles.radio_harmonic, 'value', 1 );
        
        % highlight the message to the user that pitch-synchronous
        % demodulation does not use a filterbank
        set( handles.filterbank_note, 'FontWeight', 'bold' )
end

% display pitch-detection settings
set( handles.edit_numharmonics, 'string', num2str( data.numharmonics ) );
set( handles.edit_voicingsensitivity, 'string', num2str( data.voicingsensitivity ) );
set( handles.edit_f0smoothness, 'string', num2str( data.f0smoothness ) );

% Load current filterbank settings
set(handles.popup_numbands, 'string', cellstr(num2str(data.basesizes(:),'%1d')));
v = find(data.basesizes==data.numbands);
if (isempty(v))
    v = 1;
end;
set(handles.popup_numbands, 'value', v);

if data.basehop == round(.125*data.numbands)
    set(handles.radio_downsample18,'value',1);
    set(handles.radio_downsample14,'value',0);
    set(handles.radio_downsample12,'value',0);
elseif data.basehop == round(.25*data.numbands)
    set(handles.radio_downsample18,'value',0);
    set(handles.radio_downsample14,'value',1);
    set(handles.radio_downsample12,'value',0);
elseif data.basehop == round(.5*data.numbands)
    set(handles.radio_downsample18,'value',0);
    set(handles.radio_downsample14,'value',0);
    set(handles.radio_downsample12,'value',1);
end

standard = (data.freqdec == 1);
set(handles.radio_standard,'value',standard);
set(handles.radio_minimal,'value',~standard);

% Update the filterbank frequency response plot
data = guidata(h);
%fbaxes = handles.filterbank_axes;
DemodOptions_UpdateFilterbankFreqz( data.filterbankparams, data.fs, handles );
%set( fig, 'Children', [get( fig, 'Children' ), fbaxes] );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbModwindow50_Callback(h, eventdata, data)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_modwindow50, 'value', 1);
set(handles.radio_modwindow75, 'value', 0);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbModwindow75_Callback(h, eventdata, data)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_modwindow50, 'value', 0);
set(handles.radio_modwindow75, 'value', 1);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbHilbert_Callback(h, eventdata, data)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_hilbert, 'value', 1);
set(handles.radio_cog, 'value', 0);
set(handles.radio_harmonic, 'value', 0);

set( handles.filterbank_note, 'FontWeight', 'normal' )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbCOG_Callback(h, eventdata, data)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_hilbert, 'value', 0);
set(handles.radio_cog, 'value', 1);
set(handles.radio_harmonic, 'value', 0);

set( handles.filterbank_note, 'FontWeight', 'normal' )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbHarmonic_Callback(h, eventdata, data)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_hilbert, 'value', 0);
set(handles.radio_cog, 'value', 0);
set(handles.radio_harmonic, 'value', 1);

% highlight the message to the user about how pitch-synchronous
% demodulation does not use filterbank settings
set( handles.filterbank_note, 'FontWeight', 'bold' )


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbDownsample18_Callback(h, eventdata, handles)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_downsample18, 'value', 1);
set(handles.radio_downsample14, 'value', 0);
set(handles.radio_downsample12, 'value', 0);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbDownsample14_Callback(h, eventdata, handles)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_downsample18, 'value', 0);
set(handles.radio_downsample14, 'value', 1);
set(handles.radio_downsample12, 'value', 0);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbDownsample12_Callback(h, eventdata, handles)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_downsample18, 'value', 0);
set(handles.radio_downsample14, 'value', 0);
set(handles.radio_downsample12, 'value', 1);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbStandard_Callback(h, eventdata, handles)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_standard, 'value', 1);
set(handles.radio_minimal,  'value', 0);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_rbMinimal_Callback(h, eventdata, handles)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.radio_standard, 'value', 0);
set(handles.radio_minimal,  'value', 1);

% Update the filterbank frequency response plot
data = guidata(h);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_pbOK_Callback(h, eventdata, handles, varargin)

data = guidata(h);
handles = guihandles(h);
mainhandles = guihandles(data.mainhandle);

% copy all settings from the filterbank settings to the gui data
nb = data.basesizes(get(handles.popup_numbands,'value'));

switch get(handles.radio_standard,'value')
    case 0
        fd = 9;
    case 1
        fd = 1;
end

bs = nb*fd;

if get(handles.radio_downsample18,'value') == 1
    hop = 0.125*nb;
elseif get(handles.radio_downsample14,'value') == 1
    hop = 0.25*nb;
elseif get(handles.radio_downsample12,'value') == 1
    hop = 0.5*nb;
end

bo = bs - hop;

% copy all settings from the window settings to the gui data
md = data.modsizes(get(handles.popup_modsizes,'value'));
ms = 2^round( log2( md*data.fs/hop ) );

% copy all settings from the demod settings to the gui data
cw = data.carrwinsizes(get(handles.popup_carrwinsizes,'value'));
numharmonics = str2double( get( handles.edit_numharmonics, 'string' ) );
voicingsensitivity = str2double( get( handles.edit_voicingsensitivity, 'string' ) );
f0smoothness = str2double( get( handles.edit_f0smoothness, 'string' ) );

if get(handles.radio_hilbert,'value')
    dm = 'Hilbert';
    data.fundemodmethod = @demodhilb;
    
elseif get(handles.radio_cog,'value')
    dm = 'COG';
    data.fundemodmethod = @demodcog;
    
elseif get(handles.radio_harmonic,'value')
    dm = 'harmonic';
    data.fundemodmethod = @demodharmonic;

    % adjust pitch detection settings, provided a signal has been loaded
    % and we know its sampling rate
    if ~isempty( data.pcm )
        %nb  = 2*floor( 1 / max( data.F0 ) );
        hop = floor( data.fs/(2*data.minf0) );
        ms  = 2^round( log2( md*data.fs/hop ) );
        data.modbandwidth = 2/data.fs*data.minf0;
        
        data.modmatrixdim = [numharmonics, ms];
    end
end

% copy modulation window overlap
switch get(handles.radio_modwindow50,'value')
    case 0
        overlap = ceil( 0.75*ms );
    case 1
        overlap = ceil( 0.50*ms );
end

% close options dialog
[object, figure] = gcbo;
delete(figure);

% changes in data segmentation
changedseg = data.modsize~=ms  || data.modoverlap~=overlap;

% changes in filterbank settings
changedfb  = data.numbands~=nb || data.basehop~=hop || data.freqdec~=fd;

% changes in demod method
changedmod = ~strcmp( data.demodmethod, dm );

% changes in COG settings
changedcog = data.cogwindur~=cw;

% changes in pitch settings
changedpitch = data.numharmonics ~= numharmonics || data.voicingsensitivity ~= voicingsensitivity || data.f0smoothness ~= f0smoothness;

% detect whether the current settings differ from the previous settings
changed = changedseg || changedfb || changedmod || changedcog || changedpitch;
     
if changedseg || changedfb || changedmod || changedcog || changedpitch
    % Update gui data fields
    data.numbands    = nb;
    data.basesize    = bs;
    data.basehop     = hop;
    data.baseoverlap = bo;
    data.freqdec     = fd;
    data.moddur      = md;
    data.modsize     = ms;
    data.modhop      = ms - overlap;
    data.modoverlap  = overlap;

    data.demodmethod = dm;
    data.cogwin = 2^ceil( log2( ceil( cw/1000*data.fs/data.basehop ) ) );
    data.coghop = max( 1, data.cogwin / 4 );
    data.cogwindur = cw;
    
    data.numharmonics = numharmonics;
    data.voicingsensitivity = voicingsensitivity;
    data.f0smoothness = f0smoothness;
    [data.f0medfiltlen data.f0freqcutoff] = convertF0smoothness( f0smoothness, data.fs );
    
    updatedisplay(data);
    
    if ~isempty( data.pcm )
        % redraw spectrogram rectangles
        axes(data.axesSpecGram);
        set(data.bigspecgramframe,'position',[-1 0 0.5 data.fs/2]);
        set(data.bigspecgramframe,'edgecolor', [0.5 0.5 0.5], 'linestyle', ':', 'linewidth', 2);
        drawnow;
    end
end

if ( changedfb || changedmod ) && ~strcmp( dm, 'harmonic' )
    % Design the new filterbank whenever settings change or when switching
    % from harmonic demodulation to COG or Hilbert
    hwb = waitbar(0, 'Designing Filterbank...');
%    movefig(hwb, 0.5, 0.75, data);
    drawnow;

    data.filterbankparams = designfilterbankstft( data.numbands, data.freqdec, data.basehop );
    close( hwb );
    
elseif ( changedpitch || changedmod ) && strcmp( dm, 'harmonic' ) && ~isempty( data.pcm )
    % Since pitch-synch settings are dependent on the sampling rate, pitch
    % detection will occur here if data.pcm is not empty. Otherwise,
    % LoadSignal() will execute pitch detection after loading the input
    % signal into data.pcm
    hwb = waitbar(0, 'Detecting Pitch...');
%    movefig(hwb, 0.5, 0.75, data);
    drawnow;

    data.F0 = detectpitch( data.pcm, data.fs, data.voicingsensitivity, data.f0medfiltlen, data.f0freqcutoff );
    data.numharmonics = max( 1, min( data.numharmonics, floor( 1 / max( data.F0 ) ) ) );

    close( hwb );
end

newmodspec = changedmod || ( changedfb && ~strcmp(dm,'harmonic') ) || ...
           ( changedpitch && strcmp(dm,'harmonic') ) || ( changedcog && strcmp(dm,'cog') );

if changedseg && ~newmodspec && ~isempty( data.pcm )
    % compute the new modulation spectrogram using the same carriers
    data.recon = [];
    data = compute_ms(data,'same');
    data = redraw(data);
elseif newmodspec && ~isempty( data.pcm )
    % compute the new modulation spectrogram with newly detected carriers
    data.recon = [];
    data = compute_ms(data);
    data = redraw(data);
end;

updatedisplay(data);
guidata(data.mainhandle, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_pbCancel_Callback(h, eventdata, handles)

% when user presses Cancel in Options dialog, delete dialog and
% return to main window without changing the view
data = guidata(h);
[object, figure] = gcbo;
delete(figure);
mainhandles = guihandles(data.mainhandle);
updatedisplay(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_pbUpdateFilterbank_Callback(h, eventdata, handles, varargin)
% Updates the filterbank frequency response in the demodulation-options
% dialog menu without closing it.

data = guidata(h);
handles = guihandles(h);

% copy all settings from the filterbank settings to the gui data
nb = data.basesizes(get(handles.popup_numbands,'value'));

switch get(handles.radio_standard,'value')
    case 0
        fd = 9;
    case 1
        fd = 1;
end

bs = nb*fd;

if get(handles.radio_downsample18,'value') == 1
    hop = 0.125*nb;
elseif get(handles.radio_downsample14,'value') == 1
    hop = 0.25*nb;
elseif get(handles.radio_downsample12,'value') == 1
    hop = 0.5*nb;
end

bo = bs - hop;

% Update filterbank fields
data.numbands    = nb;
data.basesize    = bs;
data.basehop     = hop;
data.baseoverlap = bo;
data.freqdec     = fd;

hwb = waitbar(0, 'Designing Filterbank...');
drawnow;
data.filterbankparams = designfilterbankstft( data.numbands, data.freqdec, data.basehop );
close( hwb );

DemodOptions_UpdateFilterbankFreqz( data.filterbankparams, data.fs, handles );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function DemodOptions_UpdateFilterbankFreqz( fbparams, fs, handles )
% Displays the individual frequency responses of several neighboring
% subbands in order to give an idea of how the filterbank sections up the
% frequency domain. Note, this is only the analysis filterbank, which
% precedes the synthesis filterbank during signal reconstruction.
% This code was adapted from a similar function in designfilterbankgui.m

DFTsize = 8*2^ceil( log2( fbparams.afilterorders+1 ) );
faxis = -fs/2:fs/DFTsize:fs/2-fs/DFTsize;
waxis = 2*pi*( faxis / fs );
n = [0:fbparams.afilterorders]';

% Constrain the plot to be within the downsampled +/- Nyquist frequencies
%bandwidth = fbparams.bandwidths/2*DFTsize;
%f1 = max( 1, round( DFTsize/2 - 2*bandwidth ) );
%f2 = min( DFTsize, round( DFTsize/2 + 2*bandwidth ) );
f1 = DFTsize/2+1 - round( DFTsize/2/fbparams.dfactor );
f2 = DFTsize/2+1 + round( DFTsize/2/fbparams.dfactor );

kmax = 5;

% A sequence of RGB values corresponding to a strong blue in the middle
% and monotonically lighter blues before and after
g = [ [kmax/(kmax+1):-1/(kmax+1):0]' ; [1/(kmax+1):1/(kmax+1):kmax/(kmax+1)]' ];
RGBvec = [zeros( 2*kmax+1, 1 ), g, ones( 2*kmax+1, 1 )];

% Display several neighboring subbands, with the central one depicted
% by a heavy blue line
for k = -kmax:kmax
    if k == 0 
        lineWidth = 2.5;
    else
        lineWidth = 1;
    end

    % Evaluate the spectrum at just the frequencies visible between f1
    % and f2
    F = freqz( fbparams.afilters{1}.*exp( j*2*pi*n*k/fbparams.numhalfbands ), 1, waxis( f1:f2 ) );
    plot( faxis( f1:f2 ), 20*log10( abs( F ) ), 'Color', RGBvec( k+6, : ), 'LineWidth', lineWidth );
    hold on
end

% Draw the -6dB line
line( [faxis( f1 ) faxis( f2 )], [-6 -6], 'LineStyle', ':', 'Color', 'k' )

% Draw vertical lines showing the new Nyquist rate after
% time-decimation
%newNyq = 1 / fbparams.dfactor;
%line( [-newNyq -newNyq], [5 -60], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2 )
%line( [newNyq newNyq], [5 -60], 'LineStyle', '--', 'Color', 'k', 'LineWidth', 2 )

axis( [faxis( f1 ) faxis( f2 ) -60 5] )
xlabel( 'Frequency (Hz)' )
ylabel( 'dB Magnitude' )

hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbColormapOptions_Callback(h, eventdata, handles)

data = guidata(h);
data.mainhandle = h;

% open colormap options figure
fig = openfig('modspecgramgui_colormapoptions.fig','reuse');
guidata(fig,data);
set(fig, 'Color', get(0, 'defaultUicontrolBackgroundColor'));
movefig(fig, 0.5, 0.25, data);

handles = guihandles(fig);
mainhandles = guihandles(h);

% load current settings into dialog
maps = get(handles.popup_colormap, 'string');
idx = strmatch(data.colormap,maps);
if isempty(idx), idx=10; end;
set(handles.popup_colormap,  'value', idx);
set(handles.rbscaletoframe,  'value', data.colorscaling==0);
set(handles.rbscaletosignal, 'value', data.colorscaling==1);
set(handles.rbscalefixed,    'value', data.colorscaling==2);
if (data.colorscaling==2),
    set(handles.edscalemin, 'string', num2str(data.colorsc(1)));
    set(handles.edscalemax, 'string', num2str(data.colorsc(2)));
else
    set(handles.edscalemin, 'string', '');
    set(handles.edscalemax, 'string', '');
end;
set(handles.cbcolorbar, 'value', data.colorbar);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function ColormapOptions_rb_Callback(h, eventdata, data)
% turn the other radiobutton(s) in this group off
handles = guihandles(h);
set(handles.rbscaletoframe,  'value', eventdata==0);
set(handles.rbscaletosignal, 'value', eventdata==1);
set(handles.rbscalefixed,    'value', eventdata==2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function ColormapOptions_pbOK_Callback(h, eventdata, handles, varargin)

data = guidata(h);
handles = guihandles(h);
mainhandles = guihandles(data.mainhandle);

% copy settings from the dialog to the gui data:

% * colormap
maps = get(handles.popup_colormap, 'string');
idx = get(handles.popup_colormap, 'value');
data.colormap = maps{idx};

% * scaling method
if get(handles.rbscaletoframe,'value'),
    data.colorscaling = 0;
elseif get(handles.rbscaletosignal,'value'),
    data.colorscaling = 1;
    if length(data.pcm),
        data.colorsc = calc_colorsc(data);
    end;
else 
    data.colorscaling = 2;
    % sort the color scale extrema, and remove NaNs and Infs
    data.colorsc = sort([str2num(get(handles.edscalemin,'string')) str2num(get(handles.edscalemax,'string'))]);
    data.colorsc(isnan(data.colorsc))=[];
    data.colorsc(isinf(data.colorsc))=[];
    % revert to no color scaling if fixed scaling not correctly specified
    if length(data.colorsc)~=2,
        data.colorscaling = 0;
    end;
end;

% * colorbar
data.colorbar = get(handles.cbcolorbar,'value');

% update display and store new settings in gui
data = redraw(data);
guidata(data.mainhandle, data); 

% close colormap options dialog
[object, figure] = gcbo;
delete(figure);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function ColormapOptions_pbCancel_Callback(h, eventdata, handles)

% when user presses Cancel in Options dialog, delete dialog and
% return to main window without changing the view
data = guidata(h);
[object, figure] = gcbo;
delete(figure);
mainhandles = guihandles(data.mainhandle);
updatedisplay(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function sc = calc_colorsc(data)

if ~isfield(data,'frames'), sc = [0 0]; return; end;
if size(data.frames,1)==0, sc = [0 0]; return; end;

% suppress log-of-zero warnings
prevwarnstate = warning('off');  

% set mi/ma to min and max of first frame
frame = 20*log10(abs(squeeze(data.frames(1,:,:))));
mi = min(min(frame));
ma = max(max(frame));

% find min/max over entire signal
for i = 2:size(data.frames,1),
	frame = 20*log10(abs(squeeze(data.frames(i,:,:))));
    mi = min([mi min(min(frame))]);
    ma = max([ma max(max(frame))]);
end;

sc = [mi ma];

% restore warning state
warning(prevwarnstate);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function data = compute_ms(data,newcarriers)

% init variables and preallocate arrays to proper size
data = initmodtransform( data );

hWaitBar = waitbar(0, ['Computing Modulation Spectrogram...']);
%movefig(hWaitBar, 0.5, 0.75, data);
drawnow;

if ~strcmp( data.demodmethod, 'harmonic' )
    % Compute the subband signals using the filterbank parameters
    subbands = filtersubbands( data.pcm, data.filterbankparams );
else
    subbands = data.pcm;
end

% Demodulate each subband (data contains the carrier matrix)
if nargin > 1 && strcmp( newcarriers, 'same' ) && ~strcmp( data.demodmethod, 'harmonic' )
    % Use existing carriers
    modoutput = subbands .* conj( data.carrieroutput );
else
    % Detect new carriers
    [modoutput, data] = feval(data.fundemodmethod, subbands, data);
end

L = length( modoutput( 1,: ) );

% Re-define outputsize here because numbands can change in
% feval(data.fundemodmethod) if the harmonic option is used.
data.outputsize = [length( modoutput(:,1) ), data.modsize];

clear subbands

% setup variables
%data.length     = ceil(length(data.pcm)/data.blocksize);
data.length     = ceil( L / data.modhop);
data.index      = 1;

data.frames     = zeros(data.length, data.outputsize(1), data.outputsize(2));
data.mask       = ones(data.outputsize(1), data.outputsize(2));
data.prevmask   = data.mask;
data.zoomed     = 0;
data.recon      = [];

for i=1:data.length
    
    waitbar(i/data.length, hWaitBar, ['Computing Modulation Spectrogram (frame ' num2str(i) ' of ' num2str(data.length) ')...']);
    drawnow;

    local_frame = zeros( data.outputsize );
    
    % select a block from the input
    n1 = (i-1)*data.modhop + 1;
    n2 = n1 + data.modhop - 1;
    
    % obtain the leading segment of the frame
    if n2 <= L
        local_frame( :, data.modoverlap+1:end ) = modoutput( :, n1:n2 );
    else
        local_frame( :, data.modoverlap+1:end-n2+L ) = modoutput( :, n1:end );
    end
    
    % concatenate with the remainder of the frame
    if n1 > data.modoverlap
        local_frame( :, 1:data.modoverlap ) = modoutput( :, n1-data.modoverlap:n1-1 );
    else
        local_frame( :, data.modoverlap-n1+2:data.modoverlap ) = modoutput( :, 1:n1-1 );
    end

    % Transform the modulators
    [modxformoutput, data] = feval(data.funforwmodxform, local_frame, data);

    % add the result to the frame buffer
    data.frames(i,:,:) = modxformoutput;
end

clear modoutput

% compute new colorscale if necessary
if data.colorscaling==1, data.colorsc = calc_colorsc(data); end;

close(hWaitBar);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function data = redraw(data)

% only display something if a WAV-file has been loaded
if isempty(data.pcm)
    % hide image?
    return
end

% grab frame from sequence of frames
if data.index > size(data.frames,1)
    frame = ones(size(data.frames,2),size(data.frames,3));
else
	frame = squeeze(data.frames(data.index,:,:));
end;

% superimpose mask if needed
if data.showmask
    frame = frame .* data.mask;
end;

% draw modulation image
axes(data.axesMS);
hold off;

if strcmp( data.modtransform, 'fourier' )
    %data.xlim = [-data.fs/2/data.basehop, data.fs/2/data.basehop];
    data.xlim = [0 data.modsize-1];
    data.xlim = ( data.xlim - ceil(data.modsize/2) ) /data.modsize*data.fs/data.basehop;
elseif strcmp( data.modtransform, 'waveletD4' ) || strcmp( data.modtransform, 'waveletLA8' )
    data.xlim = [1 data.modsize];
end

if strcmp( data.demodmethod, 'harmonic' )
    data.ylim = [1 size(frame,1)];
else
    data.ylim = [0 data.fs/2];
end

% suppress log of zero warnings inherent in our imagesc use
prevwarnstate = warning('off');
if data.colorscaling==0,
    imagesc(data.xlim, data.ylim, 20*log10(abs(frame)));
else
    imagesc(data.xlim, data.ylim, 20*log10(abs(frame)), data.colorsc);
end;
warning(prevwarnstate);

axis xy;
try colormap(data.colormap), catch, colormap(jet), end;
if data.colorbar, colorbar; end;

title(['Frame ' num2str(data.index) ' of ' num2str(data.length)]);
xlabel('Modulation Frequency (Hz)');

if ~strcmp( data.demodmethod, 'harmonic' )
    ylabel('Acoustic Frequency (Hz)');
else
    ylabel('Harmonic number');
end

% draw modulation scale dividers, if using one of the Hierarchical Lapped
% Transforms
if strcmp( data.modtransform, 'waveletD4' ) || strcmp( data.modtransform, 'waveletLA8' )
    hold on;
    k = 2;
    for n=1:log2( data.modsize )
        plot( (size(frame,2)/k+0.5) * ones(1,2), ylim, 'k' )
        k = k*2;
    end
    hold off;
    
    % update axis
    xlabel('Modulation Time Domain (Divided By Decreasing Scale)');
    
    % FIXME: change modulation ticks to reflect scales
end;

% zoom axis if needed
if (data.zoomed)
    axis(data.axisZoomed);
else
    data.axisNormal = axis;
end;

% mark the parts of the signal/spectrogram that correspond to this frame
% (the commented lines contribute to drawing an additional, smaller
% rectangle indicating frame overlap; this was removed because its
% appearance in the GUI was confusing)
rightedge   = data.blocksize * data.index;
%len         = data.blocksize;
biglen      = (data.modsize-1)*data.basehop;
%leftedge    = rightedge - len;
bigleftedge = rightedge - biglen;
%biglen      = leftedge - bigleftedge - data.fs/500;

%p = get(data.timeframe,        'position');
%set(data.timeframe,            'position', [   leftedge/data.fs  p(2)     len/data.fs  p(4)]);
p = get(data.bigtimeframe,     'position');
set(data.bigtimeframe,         'position', [bigleftedge/data.fs  p(2)  biglen/data.fs  p(4)]);

%p = get(data.specgramframe,    'position');
%set(data.specgramframe,        'position', [   leftedge/data.fs  p(2)     len/data.fs  p(4)]);
p = get(data.bigspecgramframe, 'position');
set(data.bigspecgramframe,     'position', [bigleftedge/data.fs  p(2)  biglen/data.fs  p(4)]);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbNextFrame_Callback(h, eventdata, data)

if (data.index < data.length)
    data.index = data.index + 1;
    % FIXME: remove selection rectangle if any
    data = redraw(data);
    updatedisplay(data);
    guidata(h, data);
end;
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function figure1_KeyPressFcn(h, eventdata, data)

ch = get(h, 'CurrentCharacter');

if ~isempty(ch) && ch==char(28) && data.index>1,
    data.index = data.index - 1;
    data = redraw(data);
    guidata(h, data);
elseif ~isempty(ch) && ch==char(29) && data.index<size(data.frames,1),
    data.index = data.index + 1;
    data = redraw(data);
    guidata(h, data);
end;
% disp(sprintf('%c %d',ch,double(ch)));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function figure1_WindowButtonDownFcn(h, eventdata, data)

point1 = get(gca,'CurrentPoint');    % button down detected
point1 = point1(1,1:2);              % extract x and y

% ignore clicks outside the current axis
ax = axis;
if point1(1)<ax(1) | point1(1)>ax(2) | point1(2)<ax(3) | point1(2)>ax(4)
    return;
end

if gca == data.axesSignal
    i = 1 + floor((point1(1)*data.fs)/data.blocksize);
    if (data.index ~= i) & (i <= size(data.frames,1))
        data.index = i;
        data = redraw(data);
        guidata(h, data);
    end;
    return;
    
elseif gca == data.axesSpecGram
    i = 1 + floor((point1(1)*data.fs)/data.blocksize);
    if (data.index ~= i) && (i <= size(data.frames,1))
        data.index = i;
        data = redraw(data);
        guidata(h, data);
    end;
    return;
    
elseif gca ~= data.axesMS
    return;
end;

% start rubberband box, and retrieve second point
rbbox;
point2 = get(gca,'CurrentPoint');
point2 = point2(1,1:2);

% calculate corners and dimensions of selection rectangle
lowerleft  = min(point1,point2);
upperright = max(point1,point2);

figunity   = (data.ylim(2)-data.ylim(1)) / (data.outputsize(1)-1);
figunitx   = (data.xlim(2)-data.xlim(1)) / (data.outputsize(2)-1);

% convert corners of rectangle into pixel locations
ll(1) = max(  1,                 floor((lowerleft(1)  - data.xlim(1)) / figunitx + 1.5) );
ll(2) = max(  1,                 floor((lowerleft(2)  - data.ylim(1)) / figunity + 1.5) );
ur(1) = min( data.outputsize(2), floor((upperright(1) - data.xlim(1)) / figunitx + 1.5) );
ur(2) = min( data.outputsize(1), floor((upperright(2) - data.ylim(1)) / figunity + 1.5) );

% safely remove old selection rectangle if any
if ishandle(data.selection) && data.selection~=0
    delete(data.selection);
    data.selection = 0;
end;
selw = ur(1)-ll(1)+1;
selh = ur(2)-ll(2)+1;
if selw > 1 && selh > 1
    % selw and selh must be greater than 1 to avoid an error when
    % single-clicking the modulation spectrogram graphic window
    data.region = [ll ur];
    data.selection = rectangle('Position', [lowerleft upperright-lowerleft]);
    set(data.selection, 'edgecolor', 'k', 'linewidth', 1, 'linestyle', ':');
end;
       
guidata(h,data);
updatedisplay(data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbAmplify_Callback(h, eventdata, data)

if ishandle(data.selection) && data.selection~=0

    data.mask(data.region(2):data.region(4),data.region(1):data.region(3)) = ...
        data.mask(data.region(2):data.region(4),data.region(1):data.region(3)) * 2;

end;

pos = get( data.selection, 'Position' );
data = redraw(data);

% Redraw the rectangular selection for further modification
data.selection = rectangle( 'Position', pos );
set(data.selection, 'edgecolor', 'k', 'linewidth', 1, 'linestyle', ':');

updatedisplay(data);
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbAttenuate_Callback(h, eventdata, data)

if ishandle(data.selection) && data.selection~=0

    data.mask(data.region(2):data.region(4),data.region(1):data.region(3)) = ...
        data.mask(data.region(2):data.region(4),data.region(1):data.region(3)) / 2;

end;

pos = get( data.selection, 'Position' );
data = redraw(data);

% Redraw the rectangular selection for further modification
data.selection = rectangle( 'Position', pos );
set(data.selection, 'edgecolor', 'k', 'linewidth', 1, 'linestyle', ':');

updatedisplay(data);
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbReset_Callback(h, eventdata, data)

%data.mask  = ones(data.outputsize(1), data.outputsize(2) );
data.mask = ones( data.modmatrixdim(1), data.modsize );

data = redraw(data);
updatedisplay(data);
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbSetZero_Callback(h, eventdata, data)
% Sets the masking function to zero in the selected region.

if ishandle(data.selection) && data.selection~=0

    data.mask(data.region(2):data.region(4),data.region(1):data.region(3)) = 0;

    delete(data.selection);
    data.selection = 0;

end;

data = redraw(data);
updatedisplay(data);
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbSetOne_Callback(h, eventdata, data)
% Sets the masking function to one in the selected region.

if ishandle(data.selection) && data.selection~=0

    data.mask(data.region(2):data.region(4),data.region(1):data.region(3)) = 1;

    delete(data.selection);
    data.selection = 0;

end;

data = redraw(data);
updatedisplay(data);
guidata(h, data);
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbApply_Callback(h, eventdata, data)
    
% initialize variables and preallocate buffers of proper size
data = initmodtransform( data );

% take transform delay into account
nrframes = length( data.frames(:,1,1) ); %ceil( (length(data.pcm)+data.xformdelay) / data.blocksize );

hWaitBar = waitbar(0, ['Applying mask to frame 0 of ' num2str(nrframes) '...']);
movefig(hWaitBar, 0.5, 0.75, data);
drawnow;

modulators = zeros( data.modmatrixdim );
L = data.modmatrixdim( 2 );

n1 = 1;
n2 = data.modhop;

for i=1:nrframes
    
    waitbar(i/nrframes, hWaitBar, ['Applying mask to frame ' num2str(i) ' of ' num2str(nrframes) '...']);
    drawnow;
    
    modxformoutput = data.frames( i,:,: );
    
    % apply the mask                     
    modxformoutput = squeeze( modxformoutput ) .* data.mask;
    
    % take the inverse transform
    [modoutput, data] = feval( data.funinvmodxform, modxformoutput, data );
    
    % set negative magnitudes to zero (Hilbert envelope only)
    if strcmp( data.demodmethod, 'hilbert' )
        modoutput = real(modoutput);
        modoutput(modoutput<0) = 0;
    end
    
    % overlap-add the leading segment of the modulator frame
    if n2 <= L
        modulators( :, n1:n2 ) = modulators( :, n1:n2 ) + modoutput( :, data.modoverlap+1:end );
    else
        modulators( :, n1:end ) = modulators( :, n1:end ) + modoutput( :, data.modoverlap+1:end-n2+L );
    end
    
    % overlap-add the rest of the modulator frame
    if n1 > data.modoverlap
        modulators( :, n1-data.modoverlap:n1-1 ) = modulators( :, n1-data.modoverlap:n1-1 ) + modoutput( :, 1:data.modoverlap );
    else
        modulators( :, 1:n1-1 ) = modulators( :, 1:n1-1 ) + modoutput( :, data.modoverlap-n1+2:data.modoverlap );
    end
    
    n1 = n1 + data.modhop;
    n2 = n2 + data.modhop;
end

% synthesize the modified time-domain signal from the masked modulators and
% the original carriers
if ~strcmp( data.demodmethod, 'harmonic' )
    subbands   = modulators .* data.carrieroutput;
    data.recon = real( filterbanksynth( subbands, data.filterbankparams ) );
else
    data.recon = modreconharm( modulators, data.carrieroutput );
end

clear modulators subbands

close(hWaitBar);

data.prevmask = data.mask;

updatedisplay(data);
guidata(h,data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbSymmetrize_Callback(h, eventdata, data)
% Replaces the masking function with an even-symmetric version relative to
% zero Hz in modulation frequency.

data.prevmask = data.mask;

% The symmetrized mask is a cascade of the current mask with its
% reflected (over the acoustic frequency axis) version.
if mod( data.modsize, 2 ) == 1  % odd DFT size
    data.mask = data.mask .* data.mask( :, end:-1:1 );
else
    % Preserve the sample at Nyquist
    data.mask( :, 2:end ) = data.mask( :, 2:end ) .* data.mask( :, end:-1:2 );
end

% Replace the center sample (representing 0 Hz) with the original value
center = floor( data.modsize / 2 ) + 1;
data.mask( :, center ) = data.prevmask( :, center );

data = redraw(data);
updatedisplay(data);
guidata(h,data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function updatedisplay(data)

% Update settings display
set(data.Modwindowtext,   'string', num2str(data.moddur));
set(data.Modoverlaptext,  'string', [num2str(data.modoverlap*100/data.modsize) '%']);

if ~strcmp(data.demodmethod, 'harmonic')
    set(data.Numbandstext,   'string', num2str(data.numbands));
    set(data.Basewindowtext, 'string', num2str(data.basesize));
    set(data.Basehoptext,    'string', num2str(data.basehop));
else
    set(data.Numbandstext,   'string', 'n/a');
    set(data.Basewindowtext, 'string', 'n/a');
    set(data.Basehoptext,    'string', num2str(data.basehop));
end

set(data.Demodmethodtext,    'string', num2str(data.demodmethod));

% update the enabling/disabling of each GUI button
onoff = ['off'; 'on '];

set(data.pbPlayOriginal,  'enable', onoff(1+ ~isempty(data.pcm),:));
set(data.pbPlayMasked,    'enable', onoff(1+ ~isempty(data.recon),:));
set(data.pbStopPlayback,  'enable', onoff(1+ (~isempty(data.pcm) || ~isempty(data.recon)),:));
set(data.radioPlayEntireSignal,  'enable', onoff(1+ (~isempty(data.pcm) || ~isempty(data.recon)),:));
set(data.radioPlaySelectedFrame,  'enable', onoff(1+ (~isempty(data.pcm) || ~isempty(data.recon)),:));
set(data.pbSave,          'enable', onoff(1+ ~isempty(data.recon),:));
set(data.pbExport,        'enable', onoff(1+ ~isempty(data.recon),:));
set(data.pbUseMasked,     'enable', onoff(1+ ~isempty(data.recon),:));

% allow modifications only when selection is active
selon = onoff(1+ (ishandle(data.selection) & data.selection ~= 0) ,:);
set(data.pbAmplify,    'enable', selon);
set(data.pbAttenuate,  'enable', selon);
set(data.pbSetZero,    'enable', selon);
set(data.pbSetOne,     'enable', selon);
set(data.pbZoomIn,     'enable', selon);

% allow zoom-out only when zoomed in
set(data.pbZoomOut,    'enable', onoff(1+ data.zoomed,:));

% allow mask application when the current mask differs from previous
set(data.pbApply,      'enable', onoff(1+ (~isequal(data.mask,data.prevmask)), :));

% allow symmetrization whenever a mask is in play and the modulation
% transform is set to Fourier
if strcmp( data.modtransform, 'fourier' )
    trivialmask = ones( size( data.mask ) );
    maskinuse = get( data.cbMask, 'Value' );
    set(data.pbSymmetrize, 'enable', onoff(1+ (~isequal(data.mask,trivialmask) && maskinuse), :));
else
    set(data.pbSymmetrize, 'enable', 'off');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbExit_Callback(h, eventdata, data)
delete(data.fig);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbOnlineHelp_Callback(h, eventdata, data)
system('start http://isdl.ee.washington.edu/projects/modulationtoolbox');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbAbout_Callback(h, eventdata, data)

uiwait(msgbox({ ...
        'MODSPECGRAM GUI version 2.1' ...
        'part of the ISDL Modulation Toolbox' ...
        '' ...
        '(c) 2003-2010 ISDL, University of Washington' ...
        '' ...
        'Developed by:' ...
        '   Chad Heinemann (UW EE Undergraduate)' ...
        '   Steven Schimmel (UW EE Graduate)' ...
        '   Pascal Clark (UW EE Graduate)' ...
        '' ...
        'Transforms: '...
        '   Jeffrey Thompson (UW EE Graduate)' ...
        '' ...
        'Supervision:' ...
        '   Prof. Les Atlas (UW EE Faculty)' ...
        '' ...
        'Homepage:' ...
        '   http://isdl.ee.washington.edu/projects/modulationtoolbox/' ...
    },'About', 'help', 'modal'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbSignalInNew_Callback(h, eventdata, data)

if ~length(data.pcm)
    beep
    warndlg('No wav file has been selected!','Error','modal');
else
    figure;
    plot(data.pcm);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbSpecGramInNew_Callback(h, eventdata, data)

if ~length(data.pcm)
    beep
    warndlg('No wav file has been selected!','Error','modal');
else
    figure;
    specgram(data.pcm,data.basesize,data.fs,sinewindow(data.basesize),data.baseoverlap);
    xlim([0 (length(data.pcm)-1)/data.fs]);
end;        


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbMSInNew_Callback(h, eventdata, data)

if ~length(data.pcm)
    beep
    warndlg('No wav file has been selected!','Error','modal');
else
    figure;
    s = data.showmask;
    a = data.axesMS;
    data.showmask = 0;
    data.axesMS = axes;
    redraw(data);
    data.showmask = s;
    data.axesMS = a;
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbZoomIn_Callback(h, eventdata, data)

if ishandle(data.selection) & data.selection~=0
    p = get(data.selection, 'position');
    axis([ p(1) p(1)+p(3) p(2) p(2)+p(4) ]);
    delete(data.selection);
    data.selection = 0;
    data.zoomed = 1;
    data.axisZoomed = axis;
    updatedisplay(data);
    guidata(h, data);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function pbZoomOut_Callback(h, eventdata, data)

data.zoomed = 0;
axes(data.axesMS);
axis(data.axisNormal);
updatedisplay(data);
guidata(h, data);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function cbMask_Callback(h, eventdata, data)

s = get(h,'Value');
if (s ~= data.showmask)
    data.showmask = s;
    data = redraw(data);
    updatedisplay(data);
    guidata(h,data);
end;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function editFunctionName_CreateFcn(h, eventdata, data)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(h,'BackgroundColor','white');
else
    set(h,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function movefig(fig, xperc, yperc, data)

mainunits = get(data.fig,'units');
figunits  = get(fig,'units');

set([data.fig fig],'units','pixels');

mainpos = get(data.fig, 'position');
figpos  = get(fig, 'position');

figx = round(mainpos(1) + mainpos(3)*xperc - figpos(3)/2);
figy = round(mainpos(2) + mainpos(4)*(1-yperc) - figpos(4)/2);
figpos = [figx figy figpos(3) figpos(4)];

set(fig, 'position', figpos);

set(data.fig,'units', mainunits);
set(fig,'units', figunits);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modoutput, data] = demodhilb( subbands, data )
% DEMODHILB Wrapper function for incoherent Hilbert envelope demodulation

[modoutput data.carrieroutput] = moddecomphilb( subbands );
data.modmatrixdim = size( modoutput );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modoutput, data] = demodcog( subbands, data )
% DEMODCOG Wrapper function for coherent demodulation via the spectral
% center-of-gravity estimate of instantaneous frequency.

warning( 'off', 'moddecompcog:stationaryCOG_1' );
warning( 'off', 'moddecompcog:stationaryCOG_2' );
[modoutput data.carrieroutput] = moddecompcog( subbands, data.cogwin, data.coghop );
data.modmatrixdim = size( modoutput );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modoutput, data] = demodharmonic( x, data )
% DEMODHARMONIC Wrapper function for coherent demodulation via harmonic
% pitch estimate.

[modoutput data.carrieroutput] = moddecompharm( x, data.F0, data.numharmonics, data.modbandwidth, [], data.basehop );
data.modmatrixdim = size( modoutput );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function data = initmodtransform(data)
%INITMODTRANSFORM Prepare data structure for transforming the modulators

% every transform init function should set these variables for the GUI
data.blocksize   = data.basehop*(data.modsize-data.modoverlap);
data.outputsize  = [data.modmatrixdim(1),data.modsize];

% depending on amount of overlap there are differences in the reconstruction:
% 50% overlap -> scalefactor=1, 75% overlap -> scalefactor=1/2
data.modscalefactor  = 2 - (data.modoverlap/data.modsize) * 2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modxformoutput, data] = fftmodtransform(modoutput, data)
%FFTMODTRANSFORM Calculate Fourier-based modulation spectrum from signal.

% prepare a sine window of the proper size
modwindow = diag( sparse( sinewindow(data.modsize) ) );

% apply window to input
modoutput = modoutput * modwindow;

% FFT all of the rows, and perform an fft-shift for display
modxformoutput = fftshift( fft(modoutput,[],2), 2 );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modoutput, data] = fftinvmodtransform(modxformoutput, data)
%FFTINVMODTRANSFORM Reconstruct spectrogram from Fourier-based modulation spectrum.

% IFFT the rows, and undo the fft-shift
modoutput = ifft( fftshift( modxformoutput, 2 ), [], 2 );

% prepare a sine window for synthesis
modwindow = diag( data.modscalefactor*sparse( sinewindow(data.modsize) ) );

% apply window to modulators
modoutput = modoutput * modwindow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modxformoutput, data] = waveletD4modtransform(modoutput, data)
%WAVELETD4MODTRANSFORM Calculate wavelet-based modulation spectrum from
%signal using the Daubechies minimum-phase scaling filter

% prepare a sine window of the proper size
modwindow = diag( sparse( sinewindow(data.modsize) ) );

% apply window to input
modoutput = modoutput * modwindow;

% transform all of the rows
modxformoutput = DWT( modoutput.', 'D4' ).';

% compensate for filter delay at each scale
for i = 1:log2( data.modsize ) + 1
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modoutput, data] = waveletD4invmodtransform(modxformoutput, data)
%WAVELETD4INVMODTRANSFORM Reconstruct spectrogram from wavelet-based
%modulation spectrum

% Inverse transform the rows
modoutput = IDWT( modxformoutput.', 'D4' ).';

% prepare a sine window for synthesis
modwindow = diag( data.modscalefactor*sparse( sinewindow(data.modsize) ) );

% apply window to modulators
modoutput = modoutput * modwindow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modxformoutput, data] = waveletLA8modtransform(modoutput, data)
%WAVELETD4MODTRANSFORM Calculate wavelet-based modulation spectrum from
%signal using the Daubechies minimum-phase scaling filter

% prepare a sine window of the proper size
modwindow = diag( sparse( sinewindow(data.modsize) ) );

% apply window to input
modoutput = modoutput * modwindow;

% transform all of the rows, compensate for filter delay, and reverse the
% coefficient order (we want long-scale to short-scale)
modxformoutput = DWT( modoutput.', 'LA8' ).';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [modoutput, data] = waveletLA8invmodtransform(modxformoutput, data)
%WAVELETD4INVMODTRANSFORM Reconstruct spectrogram from wavelet-based
%modulation spectrum

% Inverse transform the rows
modoutput = IDWT( modxformoutput.', 'LA8' ).';

% prepare a sine window for synthesis
modwindow = diag( data.modscalefactor*sparse( sinewindow(data.modsize) ) );

% apply window to modulators
modoutput = modoutput * modwindow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [W J0 h g] = DWT( x, f, varargin )
% [W J0 h g] = DWT( x, f, <J0> )
%
% Computes the discrete wavelet transform coefficients of the signal x,
% using the wavelet/scaling filter f. This function uses the pyramid
% algorithm.
%
% Inputs:
%   x - a vector with a length that is an integer multiple of a power of 2
%   f - the DWT filter to use; if f is zero mean, it will be taken as the
%       wavelet filter; if f is non-zero mean, it will be taken as the scaling
%       filter. From f, the appropriate quadrature mirror filter will be
%       computed internally. Alternatively, f can be a string such as
%       'Haar', 'D4', 'LA8', etc.
%   J0 - (optional) the level for a partial DWT. The default is for the
%        maximum possible, which is the number of times that N can be
%        evenly divided by 2 (where N is the length of x).
%
% Outputs:
%   W -  the DWT coefficients corresponding to the time series x, with
%        coefficients listed in order of long-scale to short-scale.
%   J0 - the level to which the DWT was computed.
%   h -  the wavelet filter coefficients used.
%   g -  the scaling filter coefficients used.

% Pascal Clark, April 17, 2007
% Adapted from pseudo-code given by D. Percival and A. Walden, "Wavelet
% Methods for Time Series Analysis," Cambridge University Press, 2006.


% This handles inputs that happen to be 2D arrays, and computes the DWT
% along each column
s = size( x );
if s( 1 ) > 1 && s( 2 ) > 1
    if numel( varargin ) > 0
        optional = varargin{ 1 };
    else
        optional = [];
    end

    % Process each column separately
    for i = 1:s( 2 )
        [W( :,i ) J0 h g] = DWT( x( :,i ), f, optional );
    end

    return
end

% The rest of this function computes the DWT for a vector of data

x = x(:);

N = length( x );

W = zeros( N, 1 );

% Parse inputs
if mod( log2( N ), 1 ) == 0
    % N is a power of 2
    Jmax = log2( N );
else
    % test to see if N is an integer multiple of 2, in which case a partial
    % DWT is possible
    Jmax = intMultPow2( N );
    
    if Jmax <= 0
        error( 'Length of x must be an integer multiple of a power of 2.' )
    end
end

% If the given filter is a string, then find the filter coefficients that
% correspond to the filter name
if isa( f, 'numeric' )
    f = f(:);
    L = length( f );
else
    f = getScalingFilter( f );
    L = length( f );
end

% Set the DWT level to be the maximum possible; in the case of N = 2^k,
% this will be log2( N )
J0 = Jmax;

% User-defined partial DWT level, which overrides the maximum default value
if numel( varargin ) == 1 && ~isempty( varargin{ 1 } )
    J0 = varargin{ 1 };
    
    if J0 > Jmax
        error( ['Given the length of x, a maximum of ' num2str( Jmax ) ' DWT levels are allowed.'] );
    end
end

% Wavelet/scaling filter error checks
if mod( L, 2 ) ~= 0
    error( 'The wavelet/scaling filter must have even length.' );
end

if sum( f.^2 ) - 1 > 1e-9
    warning( 'The wavelet/scaling filter does not have unit energy.' )
end

if abs( sum( f ) ) < 1e-9
    % f must be a wavelet filter, so g is the corresponding scaling filter
    h = f;
    g = h( L:-1:1 ).*( -1 ).^( [1:L]' );
else
    % f is given as a scaling filter, so assign it to g and compute the
    % wavelet filter complement
    g = f;
    h = g( L:-1:1 ).*( -1 ).^( [0:L-1]' );
end

% Perform the pyramid DWT algorithm
vOld = x;
n1 = N/2 + 1;
n2 = N;

% Compute short-scale coefficients first, but place them at the end of the
% overall transformed vector
for j = 1:J0
    
    M = N / 2^(j-1);
    w = zeros( M / 2, 1 );
    v = zeros( M / 2, 1 );
    
    for t = 0:M/2-1
        u = 2*t + 1;
        w( t+1 ) = h( 1 )*vOld( u+1 );
        v( t+1 ) = g( 1 )*vOld( u+1 );
        
        for n = 1:L-1
            u = u - 1;
            
            if u < 0
                u = M - 1;
            end
            
            w( t+1 ) = w( t+1 ) + h( n+1 )*vOld( u+1 );
            v( t+1 ) = v( t+1 ) + g( n+1 )*vOld( u+1 );
        end
    end
    
    vOld = v;

    W( n1:n2 ) = w;
    
    n2 = n1 - 1;
    n1 = floor( N / 2^(j+1) + 1 );
end

% The first coefficient comes straight from the final scaling filter output
W( 1 ) = v;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function [x h g] = IDWT( W, f, varargin )
% [x h g] = IDWT( W, f, <J0> )
%
% Computes the inverse discrete wavelet transform from the coefficients w
% using the wavelet/scaling filter f. This function uses the pyramid
% algorithm.
%
% Inputs:
%   W - a vector of DWT coefficients that must have length that is an integer
%       multiple of a power of 2. Coefficients are listed in order of
%       long-scale to short-scale.
%   f - the DWT filter to use; if f is zero mean, it will be taken as the
%       wavelet filter; if f is non-zero mean, it will be taken as the scaling
%       filter. From f, the appropriate quadrature mirror filter will be
%       computed internally. Alternatively, f can be a string such as
%       'Haar', 'D4', 'LA8', etc.
%   J0 - (optional) the partial-DWT level of the coefficients contained in
%        the vector W. The default is the maximum level possible
%        considering the length of W.
%
% Outputs:
%   x - the time series associated with the DWT coefficients W.
%   h - the wavelet filter coefficients used.
%   g - the scaling filter coefficients used.

% Pascal Clark, April 17, 2007
% Adapted from pseudo-code given by D. Percival and A. Walden, "Wavelet
% Methods for Time Series Analysis," Cambridge University Press, 2006.

% This handles inputs that happen to be 2D arrays, and computes the IDWT
% along each column
s = size( W );
if s( 1 ) > 1 && s( 2 ) > 1
    if numel( varargin ) > 0
        optional = varargin{ 1 };
    else
        optional = [];
    end

    % Process each column separately
    for i = 1:s( 2 )
        [x( :,i ) h g] = IDWT( W( :,i ), f, optional );
    end

    return
end

% The rest of this function computes the DWT for a vector of data

W = W(:);

N = length( W );

% Parse inputs
if mod( log2( N ), 1 ) == 0
    % N is a power of 2
    Jmax = log2( N );
else
    % test to see if N is an integer multiple of 2, in which case a partial
    % DWT is possible
    Jmax = intMultPow2( N );
    
    if Jmax <= 0
        error( 'Length of x must be an integer multiple of a power of 2.' )
    end
end

% If the given filter is a string, then find the filter coefficients that
% correspond to the filter name
if isa( f, 'numeric' )
    f = f(:);
    L = length( f );
else
    f = getScalingFilter( f );
    L = length( f );
end

% Set the DWT level to be the maximum possible; in the case of N = 2^k,
% this will be log2( N )
J0 = Jmax;

% User-defined partial DWT level, which overrides the maximum default value
if numel( varargin ) == 1 && ~isempty( varargin{ 1 } )
    J0 = varargin{ 1 };
    
    if J0 > Jmax
        error( ['Given the length of x, a maximum of ' num2str( Jmax ) ' DWT levels are allowed.'] );
    end
end

% Wavelet/scaling filter error checks
if mod( L, 2 ) ~= 0
    error( 'The wavelet/scaling filter must have even length.' );
end

if sum( f.^2 ) - 1 > 1e-9
    warning( 'The wavelet/scaling filter does not have unit energy.' )
end

if sum( f ) < 1e-9
    % h must be a wavelet filter, so g is the corresponding scaling filter
    h = f;
    g = h( L:-1:1 ).*( -1 ).^( [1:L]' );
else
    % h is given as a scaling filter, so assign it to g and compute the
    % wavelet filter complement
    g = f;
    h = g( L:-1:1 ).*( -1 ).^( [0:L-1]' );
end

% Perform the inverse pyramid DWT algorithm, starting with the long-scale
% coefficients
n2 = N - N*( sum( 1 ./ 2.^[1:J0] ) ) + 1;
n1 = n2 - N / 2^J0 + 1;
v  = W( 1:n1-1 );                     % final scaling filter coefficient(s)
%n2 = N*( sum( 1 ./ 2.^[1:J0] ) );
%n1 = n2 - N / 2^J0 + 1;
%v  = W( n2+1:N );

for j = J0:-1:1

    w = W( n1:n2 );
    
    l = -2;
    m = -1;
    M = N / 2^j;
    
    newV = zeros( 2*M, 1 );
    
    for t = 0:M-1
        l = l + 2;
        m = m + 2;
        u = t;
        i = 1;
        k = 0;

        newV( l+1 ) = newV( l+1 ) + h( i+1 )*w( u+1 ) + g( i+1 )*v( u+1 );
        newV( m+1 ) = newV( m+1 ) + h( k+1 )*w( u+1 ) + g( k+1 )*v( u+1 );
        
        if L > 2
            for n = 1:L/2-1
                u = u+1;
                
                if u >= M
                    u = 0;
                end
                
                i = i+2;
                k = k+2;
                
                newV( l+1 ) = newV( l+1 ) + h( i+1 )*w( u+1 ) + g( i+1 )*v( u+1 );
                newV( m+1 ) = newV( m+1 ) + h( k+1 )*w( u+1 ) + g( k+1 )*v( u+1 );
            end
        end
    end
    
    v = newV;
    
    %n2 = n1 - 1;
    %n1 = n2 - N / 2^(j-1) + 1;
    n1 = n2 + 1;
    n2 = n2 + N / 2^(j-1);
end

x = v;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function level = intMultPow2( N )
% level = intMultPow2( N )
%
% Decomposes N into a product of 2's and an integer. If N is not an
% integer multiple of a power of 2, then this function returns 0.
% Otherwise, it returns the number of 2's in the factorization.
d = N / 2;
level = 0;

while mod( d, 1 ) == 0
    d = d / 2;
    level = level + 1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function g = getScalingFilter( name )
% g = getScalingFilter( name )
% 
% Given a scaling filter name, this function returns the filter
% coefficients.

if length( name ) < 2
    error( 'Unsupported scaling filter.' );
end

len = 0;

if strcmp( name, 'Haar' )
    g = [1; 1] / sqrt(2);
    return
elseif length( name ) > 4
    error( 'Unsupported scaling filter.' );
end

if name(1) == 'D'
    if length( name ) == 2
        len = str2num( name( 2 ) );
    else
        len = str2num( name( 2:3 ) );
    end
    
    % Daubechies minimum-phase scaling filter
    switch len
        case 4
            g = [0.4829629131445341; 0.8365163037378077; 0.2241438680420134; ...
                -0.1294095225512603];
        case 6
            g = [0.3326705529500827;  0.8068915093110928; 0.4598775021184915; ...
                -0.1350110200102546; -0.0854412738820267; 0.0352262918857096];
        case 8
            g = [0.2303778133074431;  0.7148465705484058; 0.6308807679358788; ...
                -0.0279837694166834; -0.1870348117179132; 0.0308413818353661; ...
                 0.0328830116666778; -0.0105974017850021];
        case 10
            g = [0.1601023979741930;  0.6038292697971898;  0.7243085284377729; ...
                 0.1384281459013204; -0.2422948870663824; -0.0322448695846381; ...
                 0.0775714938400459; -0.0062414902127983; -0.0125807519990820; ...
                 0.0033357252854738];
        case 12
            g = [0.1115407433501094;  0.4946238903984530;  0.7511339080210954; ...
                 0.3152503517091980; -0.2262646939654399; -0.1297668675672624; ...
                 0.0975016055873224;  0.0275228655303053; -0.0315820393174862; ...
                 0.0005538422011614;  0.0047772575109455; -0.0010773010853085];
        case 14
            g = [ 0.0778520540850081;  0.3965393194819136;  0.7291320908462368; ...
                  0.4697822874052154; -0.1439060039285293; -0.2240361849938538; ...
                  0.0713092192668312;  0.0806126091510820; -0.0380299369350125; ...
                 -0.0165745416306664;  0.0125509985560993;  0.0004295779729214; ...
                 -0.0018016407040474;  0.0003537137999745];
        case 16
            g = [ 0.0544158422431049;  0.3128715909143031;  0.6756307362972904; ...
                  0.5853546836541907; -0.0158291052563816; -0.2840155429615702; ...
                  0.0004724845739124;  0.1287474266204837; -0.0173693010018083; ...
                 -0.0440882539307952;  0.0139810279173995;  0.0087460940474061; ...
                 -0.0048703529934518; -0.0003917403733770;  0.0006754494064506; ...
                 -0.0001174767841248];
        case 18
            g = [ 0.0380779473638791;  0.2438346746125939;  0.6048231236901156; ...
                  0.6572880780512955;  0.1331973858249927; -0.2932737832791761; ...
                 -0.0968407832229524;  0.1485407493381306;  0.0307256814793395; ...
                 -0.0676328290613302;  0.0002509471148340;  0.0223616621236805; ...
                 -0.0047232047577520; -0.0042815036824636;  0.0018476468830564; ...
                  0.0002303857635232; -0.0002519631889427;  0.0000393473203163];
        case 20
            g = [ 0.0266700579005546;  0.1881768000776863;  0.5272011889317202; ...
                  0.6884590394536250;  0.2811723436606485; -0.2498464243272283; ...
                 -0.1959462743773399;  0.1273693403357890;  0.0930573646035802; ...
                 -0.0713941471663697; -0.0294575368218480;  0.0332126740593703; ...
                  0.0036065535669880; -0.0107331754833036;  0.0013953517470692; ...
                  0.0019924052951930; -0.0006858566949566; -0.0001164668551285; ...
                  0.0000935886703202; -0.0000132642028945];
        otherwise
            error( 'This function does not support the specified scaling filter.' );
    end
    
elseif name(1) == 'C'
    if length( name ) == 2
        len = str2num( name( 2 ) );
    else
        len = str2num( name( 2:3 ) );
    end

    % Coiflet scaling filter
    switch( len )
        case 6
            g = [-0.0156557285289848; -0.0727326213410511;  0.3848648565381134; ...
                  0.8525720416423900;  0.3378976709511590; -0.0727322757411889];
        case 12
            g = [-0.0007205494453679; -0.0018232088707116;  0.0056114348194211; ...
                  0.0236801719464464; -0.0594344186467388; -0.0764885990786692; ...
                  0.4170051844236707;  0.8127236354493977;  0.3861100668229939; ...
                 -0.0673725547222826; -0.0414649367819558;  0.0163873364635998];
        case 18
            g = [-0.0000345997728362; -0.0000709833031381;  0.0004662169601129; ...
                  0.0011175187708906; -0.0025745176887502; -0.0090079761366615; ...
                  0.0158805448636158;  0.0345550275730615; -0.0823019271068856; ...
                 -0.0717998216193117;  0.4284834763776168;  0.7937772226256169; ...
                  0.4051769024096150; -0.0611233900026726; -0.0657719112818552; ...
                  0.0234526961418362;  0.0077825964273254; -0.0037935128644910];
        case 24
            g = [-0.0000017849850031; -0.0000032596802369;  0.0000312298758654; ...
                  0.0000623390344610; -0.0002599745524878; -0.0005890207562444; ...
                  0.0012665619292991;  0.0037514361572790; -0.0056582866866115; ...
                 -0.0152117315279485;  0.0250822618448678;  0.0393344271233433; ...
                 -0.0962204420340021; -0.0666274742634348;  0.4343860564915321; ...
                  0.7822389309206135;  0.4153084070304910; -0.0560773133167630; ...
                 -0.0812666996808907;  0.0266823001560570;  0.0160689439647787; ...
                 -0.0073461663276432; -0.0016294920126020;  0.0008923136685824];
        case 30
            g = [-0.0000000951765727; -0.0000001674428858;  0.0000020637618516; ...
                  0.0000037346551755; -0.0000213150268122; -0.0000413404322768; ...
                  0.0001405411497166;  0.0003022595818445; -0.0006381313431115; ...
                 -0.0016628637021860;  0.0024333732129107;  0.0067641854487565; ...
                 -0.0091642311634348; -0.0197617789446276;  0.0326835742705106; ...
                  0.0412892087544753; -0.1055742087143175; -0.0620359639693546; ...
                  0.4379916262173834;  0.7742896037334738;  0.4215662067346898; ...
                 -0.0520431631816557; -0.0919200105692549;  0.0281680289738655; ...
                  0.0234081567882734; -0.0101311175209033; -0.0041593587818186; ...
                  0.0021782363583355;  0.0003585896879330; -0.0002120808398259];
        otherwise
            error( 'This function does not support the specified scaling filter.' );
    end
    
elseif strcmp( name(1:2), 'LA' )
    if length( name ) == 3
        len = str2num( name( 3 ) );
    else
        len = str2num( name( 3:4 ) );
    end

    % Daubechies least-asymmetric scaling filter (minimizes the maximum
    % deviation from linear phase)
    switch( len )
        case 8
            g = [-0.0757657147893407; -0.0296355276459541;  0.4976186676324578; ...
                  0.8037387518052163;  0.2978577956055422; -0.0992195435769354; ...
                 -0.0126039672622612;  0.0322231006040713];
        case 10
            g = [0.0195388827353869; -0.0211018340249298; -0.1753280899081075; ...
                 0.0166021057644243;  0.6339789634569490;  0.7234076904038076; ...
                 0.1993975339769955; -0.0391342493025834;  0.0295194909260734; ...
                 0.0273330683451645];
        case 12
            g = [0.0154041093273377;  0.0034907120843304; -0.1179901111484105; ...
                -0.0483117425859981;  0.4910559419276396;  0.7876411410287941; ...
                 0.3379294217282401; -0.0726375227866000; -0.0210602925126954; ...
                 0.0447249017707482;  0.0017677118643983; -0.0078007083247650];
        case 14
            g = [0.0102681767084968; 0.0040102448717033; -0.1078082377036168; ...
                -0.1400472404427030; 0.2886296317509833;  0.7677643170045710; ...
                 0.5361019170907720; 0.0174412550871099; -0.0495528349370410; ...
                 0.0678926935015971; 0.0305155131659062; -0.0126363034031526;
                -0.0010473848889657; 0.0026818145681164];
        case 16
            g = [-0.0033824159513594; -0.0005421323316355;  0.0316950878103452; ...
                  0.0076074873252848; -0.1432942383510542; -0.0612733590679088; ...
                  0.4813596512592012;  0.7771857516997478;  0.3644418948359564; ...
                 -0.0519458381078751; -0.0272190299168137;  0.0491371796734768; ...
                  0.0038087520140601; -0.0149522583367926; -0.0003029205145516; ...
                  0.0018899503329007];
        case 18
            g = [0.0010694900326538; -0.0004731544985879; -0.0102640640276849; ...
                 0.0088592674935117;  0.0620777893027638; -0.0182337707798257; ...
                -0.1915508312964873;  0.0352724880359345;  0.6173384491413523; ...
                 0.7178970827642257;  0.2387609146074182; -0.0545689584305765; ...
                 0.0005834627463312;  0.0302248788579895; -0.0115282102079848; ...
                -0.0132719677815332;  0.0006197808890549;  0.0014009155255716];
        case 20
            g = [0.0007701598091030;  0.0000956326707837; -0.0086412992759401; ...
                -0.0014653825833465;  0.0459272392237649;  0.0116098939129724; ...
                -0.1594942788575307; -0.0708805358108615;  0.4716906668426588; ...
                 0.7695100370143388;  0.3838267612253823; -0.0355367403054689; ...
                -0.0319900568281631;  0.0499949720791560;  0.0057649120455518; ...
                -0.0203549398039460; -0.0008043589345370;  0.0045931735836703; ...
                 0.0000570360843390; -0.0004593294205481];
        otherwise
            error( 'This function does not support the specified scaling filter.' );
    end
    
elseif strcmp( name(1:2), 'BL' )
    if length( name ) == 3
        len = str2num( name( 3 ) );
    else
        len = str2num( name( 3:4 ) );
    end
    
    % Daubechies best-localized scaling filter (minimizes deviations from
    % linear phase, with extra emphasis on the low-frequency region)
    switch( len )
        case 14
            g = [0.0120154192834842;  0.0172133762994439; -0.0649080035533744; ...
                -0.0641312898189170;  0.3602184608985549;  0.7819215932965554; ...
                 0.4836109156937821; -0.0568044768822707; -0.1010109208664125; ...
                 0.0447423494687405;  0.0204642075778225; -0.0181266051311065; ...
                -0.0032832978473081;  0.0022918339541009];
        case 18
            g= [0.0002594576266544; -0.0006273974067728; -0.0019161070047557; ...
                0.0059845525181721;  0.0040676562965785; -0.0295361433733604; ...
               -0.0002189514157348;  0.0856124017265279; -0.0211480310688774; ...
               -0.1432929759396520;  0.2337782900224977;  0.7374707619933686; ...
                0.5926551374433956;  0.0805670008868546; -0.1143343069619310; ...
               -0.0348460237698368;  0.0139636362487191;  0.0057746045512475];
        case 20
            g = [0.0008625782242896;  0.0007154205305517; -0.0070567640909701; ...
                 0.0005956827305406;  0.0496861265075979;  0.0262403647054251; ...
                -0.1215521061578162; -0.0150192395413644;  0.5137098728334054; ...
                 0.7669548365010849;  0.3402160135110789; -0.0878787107378667; ...
                -0.0670899071680668;  0.0338423550064691; -0.0008687519578684; ...
                -0.0230054612862905; -0.0011404297773324;  0.0050716491945793; ...
                 0.0003401492622332; -0.0004101159165852];
        otherwise
            error( 'This function does not support the specified scaling filter.' );
    end
else
    error( 'This function does not support the specified scaling filter.' );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function window=sinewindow(N)
%SINEWINDOW
%   SINEWINDOW returns a sine window of length N.

window = sin(pi*[0.5:N-0.5]/N);


function [medfiltlen F0freqrange] = convertF0smoothness( F0smoothness, fs )
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
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% SUBFUNCTION %%%%%%%%%%%%%%%%%
function checksubfolders( varargin )
% This function is designed to automatically add the toolbox subfolders
% needed for modspecgramgui()

% Get the toolbox directory
toolboxDir = which( 'modspecgramgui' );
toolboxDir = toolboxDir( 1:end-17 );

% Get the toolbox directory listing
d = dir( toolboxDir );

% Get Matlab's search path
p = path;

check = ones( 1, length( varargin ) );
warnStr = [];

% Look for the subfolder names in the presumed toolbox directory, and add
% them to Matlab's search path if they are present. This allows
% modspecgramgui to be run easily without manually adding paths to the
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
    msgid = 'MODSPECGRAMGUI:subfolders';
    msg   = ['It appears that modspecgramgui is not in the same directory '...
              'as the required subfolder(s):' warnStr '. '...
              'Refer to filepath.m within the Modulation Toolbox for help.'];
          
    warning( msgid, msg );
end

