function MakeParams

    close all;

    handles.Figure = figure('Position',[100 100 500 800],'resize','off');

    %Create the individual panels... header, experiment list, settings, and
    %all the individual experimental parameters.
    handles.Header = CreateHeaderPanel(handles.Figure);
    handles.ExptList = CreateExptListPanel(handles.Figure);
    handles.FileInfo = CreateFileInfoPanel(handles.Figure);
    handles.AmpSettings = CreateAmpSettingsPanel(handles.Figure);
    
    handles.WriteButton = uicontrol('style','pushbutton','string','Write','parent',handles.Figure,'position',[0 0 500 25]);
    
    %Experimental panels
    handles.Expt.StimulusPresentation = CreateStimulusPresentationPanel(handles.Figure);
    handles.Expt.FingerTwister = CreateFingerTwisterPanel(handles.Figure);
    
    set(handles.Header.ClearEnvVar, 'callback', {@ClearEnvSecurityCode,handles});
    set(handles.Header.PatientCode,'callback',{@UpdateEncodedPatientCode,handles});
    set(handles.FileInfo.Directory,'callback',{@UpdateFileName, handles});
    set(handles.AmpSettings.Amplifier,'callback',{@PopulateAmpSettings,handles});
    set(handles.ExptList.Experiments,'callback',{@ChangedExperiment,handles});
    set(handles.AmpSettings.SamplingRate,'callback',{@UpdateSampleBlockSize,handles});
    set(handles.AmpSettings.SampleBlockSize,'callback',{@UpdateBlockTiming,handles});
    set(handles.WriteButton,'callback',{@WriteParamFile, handles});
end

% GUI Callbacks

function UpdateEncodedPatientCode(object, eventData, handles)
    patientCode = get(handles.Header.PatientCode,'string');
    encString = genPID(patientCode);
    set(handles.Header.PatientCodeEncoded,'string',encString);
    set(handles.Header.PatientEnvVar, 'string', getenv('bci_encode_pass'));
    UpdateFileName(object, eventData, handles);
end

function UpdateFileName(object, eventData, handles)
    encString = get(handles.Header.PatientCodeEncoded,'string');
    dirString = get(handles.FileInfo.Directory,'string');
    if dirString(end) ~= '\'
        dirString(end+1) = '\';
    end
    exptName = get(handles.ExptList.Experiments,'value');
    exptName = handles.ExptList.ExperimentString{exptName};
    fileName = [encString '_' exptName '.prm'];
    set(handles.FileInfo.FileName,'string',fileName);
end

function ClearEnvSecurityCode(object, eventdata, handles)
    setenv('bci_encode_pass','');
    set(handles.Header.PatientCodeEncoded,'string','');
    set(handles.Header.PatientEnvVar,'string','');
end

function ChangedExperiment(object, eventdata, handles)
    expts = fields(handles.Expt);
    for field = expts'
        set(handles.Expt.(field{:}).Panel, 'visible','off');
    end
    selected = get(handles.ExptList.Experiments,'Value');
    activeExpt = eval(sprintf('handles.Expt.%s;',handles.ExptList.PanelRefs{selected}));
    set(activeExpt.Panel,'Visible','on');
    
    UpdateFileName(object, eventdata, handles);

    ConfigFunc = handles.ExptList.ExptConfigFunc{selected};% should be done after 'write' is pressed'
    ConfigFunc(activeExpt);
end

function PopulateAmpSettings(object,eventData, handles)
	whichAmp = get(handles.AmpSettings.Amplifier,'value');
    switch whichAmp
        case 2 %guger
            set(handles.AmpSettings.SamplingRate,'string',{'1200','2400'});
        case 3 %neuroscan
            set(handles.AmpSettings.SamplingRate,'string',{'1000','2000'});
    end
    set(handles.AmpSettings.SamplingRate,'value',1);
    UpdateSampleBlockSize(object,eventData,handles);
end

function UpdateSampleBlockSize(object, eventData, handles) 
    whichAmp = get(handles.AmpSettings.Amplifier,'value');
    switch whichAmp
        case 2 %guger
            set(handles.AmpSettings.SampleBlockSize,'string',{'2','4','8','16','24','32','48', '96'});
            set(handles.AmpSettings.SampleBlockSize,'value',7);
        case 3 %neuroscan
            sr = get(handles.AmpSettings.SamplingRate,'value');
            switch sr
                case 1
                    set(handles.AmpSettings.SampleBlockSize,'string',{'40'});
                case 2
                    set(handles.AmpSettings.SampleBlockSize,'string',{'80'});
            end
            set(handles.AmpSettings.SampleBlockSize,'value',1);
    end
    UpdateBlockTiming(object,eventData,handles);
end

function UpdateBlockTiming(object, eventData, handles)
    sr = get(handles.AmpSettings.SamplingRate,'string');
    sr = sr{get(handles.AmpSettings.SamplingRate,'value')};
    sb = get(handles.AmpSettings.SampleBlockSize,'string');
    sb = sb{get(handles.AmpSettings.SampleBlockSize,'value')};
    
    interBlockTime = eval(sprintf('%s * 1000 / %s', sb, sr));
    
    set(handles.AmpSettings.InterBlockTime,'string', sprintf('%.3f ms', interBlockTime));
end

% Create____ Helper Functions

function handle = CreateHeaderPanel(fig)

    panelYPos = get(fig,'position');
    panelYPos = panelYPos(4) - 100;
    handle.Panel = uipanel('Parent',fig,'Title','Header','FontSize',10,'BackgroundColor','white','units','pixels','position',[5 panelYPos 160 100]);

    handle.PatientCodeLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 68 70 15], 'string', 'Patient Code:','BackgroundColor','white');
    handle.PatientCode = uicontrol('Parent',handle.Panel,'style','edit','position',[80 68 70 15], 'string', '');

    handle.PatientCodeEncodedLbl =  uicontrol('Parent',handle.Panel,'style','text','position', [5 48 70 15], 'string', 'Encoded:','BackgroundColor','white');
    handle.PatientCodeEncoded = uicontrol('Parent',handle.Panel,'style','text','position',[80 48 70 15], 'string', '','BackgroundColor','white');

    encPass = getenv('bci_encode_pass');
    handle.PatientEnvVarLbl =  uicontrol('Parent',handle.Panel,'style','text','position', [5 28 70 15], 'string', 'Security code:','BackgroundColor','white');
    handle.PatientEnvVar = uicontrol('Parent',handle.Panel,'style','text','position',[80 28 70 15], 'string', encPass,'BackgroundColor','white');

    handle.ClearEnvVar = uicontrol('Parent',handle.Panel,'style','pushbutton','position', [5 8 145 15], 'string', 'Clear Security Code');
end

function handle = CreateFileInfoPanel(fig)

    panelYPos = get(fig,'position');
    panelYPos = panelYPos(4) - 100;
    handle.Panel = uipanel('Parent',fig,'Title','File Info','FontSize',10,'BackgroundColor','white','units','pixels','position',[170 panelYPos 325 100]);
    
    handle.FileNameLbl =  uicontrol('Parent',handle.Panel,'style','text','position', [5 5 70 15], 'string', 'File name:','BackgroundColor','white');
    handle.FileName = uicontrol('Parent',handle.Panel,'style','text','position',[80 5 237 15], 'string', '','BackgroundColor','white');
    
    handle.DayLbl =  uicontrol('Parent',handle.Panel,'style','text','position', [5 68 70 15], 'string', 'Day:','BackgroundColor','white');
    handle.Day = uicontrol('Parent',handle.Panel,'style','edit','position',[80 68 237 15], 'string', '1');
    
    handle.SessionLbl =  uicontrol('Parent',handle.Panel,'style','text','position', [5 48 70 15], 'string', 'Session:','BackgroundColor','white');
    handle.Session = uicontrol('Parent',handle.Panel,'style','edit','position',[80 48 237 15], 'string', '1');
    
    handle.DirectoryLbl =  uicontrol('Parent',handle.Panel,'style','text','position', [5 28 70 15], 'string', 'Directory:','BackgroundColor','white');
    handle.Directory = uicontrol('Parent',handle.Panel,'style','edit','position',[80 28 237 15], 'string', 'c:\Data\Patients\');
end

function handle = CreateAmpSettingsPanel(fig)
    panelYPos = get(fig,'position');
    panelYPos = panelYPos(4) - 205;
    handle.Panel = uipanel('Parent',fig,'Title','Amplifier Settings','Fontsize',10,'BackgroundColor','white','units','pixels','position',[5 panelYPos 490 100]);
    
    %Which amp?
    handle.Amplifier = uicontrol('Parent',handle.Panel,'style','popupmenu','position',[5 62 80 20],'string',{'','Guger','NeuroScan'});
    
    %Sampling Rate
    handle.SamplingRateLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 36 80 15], 'string', 'Sampling Rate:','BackgroundColor','white');
    handle.SamplingRate = uicontrol('Parent',handle.Panel,'style','popupmenu','position',[85 40 80 15], 'string', {''});
    
    %NumChannels
    handle.NumChansLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 10 80 15], 'string', 'Num Chans:','BackgroundColor','white');
    handle.NumChans = uicontrol('Parent',handle.Panel,'style','edit','position',[85 10 80 15], 'string', '64');
    
     %SampleBlockSize
    handle.SampleBlockSizeLbl = uicontrol('Parent',handle.Panel,'style','text','position', [170 36 80 15], 'string', 'Block Size:','BackgroundColor','white');
    handle.SampleBlockSize = uicontrol('Parent',handle.Panel,'style','popupmenu','position',[255 40 80 15], 'string', {''});
    
    %InterBlockTime
    handle.InterBlockTimeLbl = uicontrol('Parent',handle.Panel,'style','text','position', [170 68 80 15], 'string', 'Block Timing:','BackgroundColor','white');
    handle.InterBlockTime = uicontrol('Parent',handle.Panel,'style','text','position',[255 68 80 15], 'string', '','BackgroundColor','white');
    
    %TransmitCh List
    
    handle.TransmitChLbl = uicontrol('Parent',handle.Panel,'style','text','position', [170 10 80 15], 'string', 'Transmit Chans:','BackgroundColor','white');
    handle.TransmitCh = uicontrol('Parent',handle.Panel,'style','edit','position',[255 10 80 15], 'string', '1');
    
end

function handle = CreateExptListPanel(fig)
    panelYPos = get(fig,'position');
    panelYPos = panelYPos(4) - 255;
    handle.Panel = uipanel('Parent',fig,'Title','Experiments','Fontsize',10,'BackgroundColor','white','units','pixels','position',[5 panelYPos 490 45]);
   
    handle.Experiments = uicontrol('Parent',handle.Panel,'style','popupmenu','position',[5 7 475 20]);
    
    %Set up experimental list here - Needs to stay in this order
    experimentStringList = {...
        'Motor Screening - Tongue';...
        'Motor Screening - Hand';...
        'Motor Screening - Tongue & Hand';...
        'Motor Screening - Tongue & L/R Hand';...
        'Finger Twister - Left';...
        'Finger Twister - Right';...
    };

    handle.ExperimentString = {...
        'mot_t';...
        'mot_h';...
        'mot_t_h';...
        'mot_t_lr_h';...
        'fingertwister';...
        'fingertwister';...
    };

    handle.PanelRefs = {...
        'StimulusPresentation',...
        'StimulusPresentation',...
        'StimulusPresentation',...
        'StimulusPresentation',...
        'StimulusPresentation',...
        'StimulusPresentation',...
    };

    handle.ExptWriteFunc = {...
        @WriteMST,...
        @WriteMSH,...
        @WriteMSTH,...
        @WriteMSTLRH,...
        @WriteFTL,...
        @WriteFTR,...
    };

    handle.ExptConfigFunc = {...
        @ConfigMST,...
        @ConfigMSH,...
        @ConfigMSTH,...
        @ConfigMSTLRH,...
        @ConfigFTL,...
        @ConfigFTR,...
    };

    set(handle.Experiments,'string',experimentStringList);
        
end

%                   Experimental panels

%motor screening

function handle = CreateStimulusPresentationPanel(fig)
    panelYPos = get(fig,'position');
    panelYHeight = panelYPos(4) - 300;
    handle.Panel = uipanel('Parent',fig,'Title','StimulusPresentation','FontSize',10,'BackgroundColor','white','units','pixels','position',[5 40 490 panelYHeight],'visible','off');
    
    handle.StimDurationLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 5 130 20], 'string', 'StimDuration (sec):','BackgroundColor','white');
    handle.StimDuration = uicontrol('Parent',handle.Panel,'style','edit','position',[135 5 70 20], 'string', '');
    
    handle.ISIDurationLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 30 130 20], 'string', 'ISI (sec):','BackgroundColor','white');
    handle.ISIDuration = uicontrol('Parent',handle.Panel,'style','edit','position',[135 30 70 20], 'string', '');
    
    handle.CybergloveLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 55 130 20], 'string', 'Cyberglove:','BackgroundColor','white');
    handle.Cyberglove = uicontrol('Parent',handle.Panel,'style','popupmenu','position',[135 55 70 20],'string',{'Left','Right'});
    
    handle.RecordCybergloveLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 80 130 20], 'string', 'Record Cyberglove:','BackgroundColor','white');
    handle.RecordCyberglove = uicontrol('Parent',handle.Panel,'style','checkbox','position',[135 80 70 20],'BackgroundColor','white');
    
    handle.StimuliLbl = uicontrol('Parent',handle.Panel,'style','text','position', [5 105 130 20], 'string', 'Stimuli:','BackgroundColor','white');
    handle.Stimuli = uicontrol('Parent',handle.Panel,'style','edit','position',[135 105 70 20],'string','','BackgroundColor','white');
end

function ConfigMST(panel)
    fprintf('ConfigMST\n');
    set(panel.StimDuration,'string','2');
    set(panel.ISIDuration,'string','2');
    set(panel.RecordCyberglove,'value',0);
end

function WriteMST(file, handles)
    fprintf('WriteMST\n');
    WriteBasicStimulusPresentationParams(file, handles);
    WriteAmpParams(file, handles);
end

function ConfigMSH(panel)
    fprintf('ConfigMSH\n');
    set(panel.StimDuration,'string','2');
    set(panel.ISIDuration,'string','2');
    set(panel.RecordCyberglove,'value',1);
end

function WriteMSH(file, handles)
    fprintf('WriteMSH\n');
end

function ConfigMSTH(panel)
    fprintf('ConfigMSTH\n');
    set(panel.StimDuration,'string','2');
    set(panel.ISIDuration,'string','2');
    set(panel.RecordCyberglove,'value',1);
end

function WriteMSTH(file, handles)
    fprintf('WriteMSTH\n');

end

function ConfigMSTLRH(panel)
    fprintf('ConfigMSTLRH\n');
    set(panel.StimDuration,'string','2');
    set(panel.ISIDuration,'string','2');
    set(panel.RecordCyberglove,'value',1);
end

function WriteMSTLRH(file, handles)
    fprintf('WriteMSTLRH\n');

end


%finger twister 
function handle = CreateFingerTwisterPanel(fig)
    panelYPos = get(fig,'position');
    panelYHeight = panelYPos(4) - 300;
    handle.Panel = uipanel('Parent',fig,'Title','FingerTwister','FontSize',10,'BackgroundColor','white','units','pixels','position',[5 40 490 panelYHeight],'visible','off');
end

function ConfigFTL(panel)
    fprintf('ConfigFTL\n');
end

function WriteFTL(file, handles)
    fprintf('WriteFTL\n');
    set(panel.StimDuration,'string','2');
    set(panel.ISIDuration,'string','0');
    set(panel.RecordCyberglove,'value',1);
end

function ConfigFTR(panel)
    fprintf('ConfigFTR\n');
end

function WriteFTR(fiel)
    fprintf('WriteFTR\n');
    set(panel.StimDuration,'string','2');
    set(panel.ISIDuration,'string','0');
    set(panel.RecordCyberglove,'value',1);
end

% Write the parameter file

function WriteParamFile(object, eventData, handles) 

    % DO ERROR TESTING HERE
    
    encString = get(handles.Header.PatientCodeEncoded,'string');
    dirString = get(handles.FileInfo.Directory,'string');
    if dirString(end) ~= '\'
        dirString(end+1) = '\';
    end
    
    fileName = get(handles.FileInfo.FileName,'string');
    destFile = [dirString encString '\' fileName];

    slashies = find(destFile=='/' | destFile=='\');

    for i=slashies
        destDir = destFile(1:i);
        [a b c] = mkdir(destDir);
    end

    file = fopen(destFile,'w');
    
    selected = get(handles.ExptList.Experiments,'Value');
    WriteFunc = handles.ExptList.ExptWriteFunc{selected};% should be done after 'write' is pressed'
    WriteFunc(file, handles);
    
    fclose(file);
end

function WriteBasicStimulusPresentationParams(file, handles)
    baseFile = fopen('base_stimuluspresentation.prm');
    baseContents = char(fread(baseFile, inf, 'char'));
    fclose(baseFile);
    fprintf(file, '%s\r\n', baseContents);
end

function WriteAmpParams(file, handles)
    whichAmp = get(handles.AmpSettings.Amplifier,'value');
    
    numChans = str2double(get(handles.AmpSettings.NumChans,'string'));
    
    sampleBlockSize = get(handles.AmpSettings.SampleBlockSize,'string');
    sampleBlockSize = str2double(sampleBlockSize{get(handles.AmpSettings.SampleBlockSize,'value')});
    
    fs = get(handles.AmpSettings.SamplingRate,'string');
    fs = str2double(fs{get(handles.AmpSettings.SamplingRate,'value')});
    
    
    fprintf(file,'Source:Signal%%20Properties:DataIOFilter int SourceCh= %i 16 1 %% // number of digitized and stored channels\r\n', numChans);
    fprintf(file,'Source:Signal%%20Properties:DataIOFilter int SampleBlockSize= %i 32 1 %% // number of samples transmitted at a time\r\n', sampleBlockSize);
    fprintf(file,'Source:Signal%%20Properties:DataIOFilter int SamplingRate= %i 256Hz 1 %% // sample rate\r\n', fs);
    fprintf(file,'Source:Signal%%20Properties:DataIOFilter list ChannelNames= 0 // list of channel names\r\n');
    
    switch whichAmp
        case 2 %guger
            %offsets are 1, gains are 1
            fprintf(file,'Source:Signal%%20Properties:DataIOFilter floatlist SourceChOffset= %i ', numChans);
            for i=1:numChans
                fprintf(file,'0 ');
            end
            fprintf(file,'0 %% %% // Offset for channels in A/D units\r\n');
            
            fprintf(file,'Source:Signal%%20Properties:DataIOFilter floatlist SourceChGain= %i ', numChans);
            for i=1:numChans
                fprintf(file,'1 ');
            end
            fprintf(file,'1 %% %% // gain for each channel (A/D units -> muV)\r\n');
            
            %Channel List
            fprintf(file,'Source:gUSBampADC intlist SourceChList= %i ', numChans);
            for i=1:numChans
                fprintf(file,'%i ', i);
            end
            fprintf(file,'0 1 128 // list of channels to digitize\r\n');
            
%             fprintf(file,'Source:gUSBampADC intlist SourceChList= 0 0 1 128 // list of channels to digitize\r\n');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC intlist SourceChDevices= 1 16 16 1 17 // number of digitized channels per device');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int NumBuffers= 5 1 2 32 // number of software buffers to use');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC string DeviceIDMaster= auto // deviceID for the device whose SYNC goes to the slaves');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int FilterEnabled= 1 1 0 1 // Enable pass band filter (0=no, 1=yes)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC float FilterHighPass= 0.1 0.1 0 50 // high pass filter for pass band');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC float FilterLowPass= 60 60 0 4000 // low pass filter for pass band');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int FilterModelOrder= 8 8 1 12 // filter model order for pass band');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int FilterType= 1 1 1 2 // filter type for pass band (1=BUTTERWORTH, 2=CHEBYSHEV)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int NotchEnabled= 1 1 0 1 // Enable notch (0=no, 1=yes)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC float NotchHighPass= 58 58 0 70 // high pass filter for notch filter');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC float NotchLowPass= 62 62 0 4000 // low pass filter for notch filter');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int NotchModelOrder= 4 4 1 10 // filter model order for notch filter');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int NotchType= 1 1 1 2 // filter type for pass band (1=CHEBYSHEV, 2=BUTTERWORTH)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC list DeviceIDs= 1 auto // list of USBamps to be used (or auto)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int DigitalInput= 0 0 0 1 // enable digital input:  0: false, 1: true (enumeration)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int DigitalOutput= 0 0 0 1 // enable digital output on block acquisition (boolean)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC string DigitalOutputEx= % // expression for output on digital output 2 (expression)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int SignalType= 1 0 0 1 // numeric type of output signal:  0: int16, 1: float32 (enumeration)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int AcquisitionMode= 0 0 0 2 // data acquisition mode:  0: analog signal acquisition, 1: calibration, 2: impedance (enumeration)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int CommonGround= 1 0 0 1 // internally connect GNDs from all blocks:  0: false, 1: true (enumeration)');
%             fprintf(file,'%s\r\n', 'Source:gUSBampADC int CommonReference= 1 0 0 1 // internally connect Refs from all blocks:  0: false, 1: true (enumeration)');
        case 3 %neuroscan
            fprintf(file,'%s\r\n', 'Source:Signal%20Properties:DataIOFilter floatlist SourceChOffset= 16 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 % % // Offset for channels in A/D units');
            fprintf(file,'%s\r\n', 'Source:Signal%20Properties:DataIOFilter floatlist SourceChGain= 16 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 0.003 % % // gain for each channel (A/D units -> muV)');
            fprintf(file,'%s\r\n', 'Source:NeuroscanADC string ServerAddress= localhost:3998 // address and port of the Neuroscan Acquire server');
    end
end