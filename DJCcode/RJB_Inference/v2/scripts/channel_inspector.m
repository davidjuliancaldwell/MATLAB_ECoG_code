function varargout = channel_inspector(varargin)
% varargout = channel_inspector(varargin)
% inputs are:
% segment, time vector, sampling rate
% needs at minimum (segment,time)
% e.g. channel_inspector(segment,time)
% or channel_inspector(segment,time,fs)
% segment is the 3D data array, which is [time]x[channels]x[trials]


% CHANNEL_INSPECTOR MATLAB code for channel_inspector.fig
%      CHANNEL_INSPECTOR, by itself, creates a new CHANNEL_INSPECTOR or raises the existing
%      singleton*.
%
%      H = CHANNEL_INSPECTOR returns the handle to a new CHANNEL_INSPECTOR or the handle to
%      the existing singleton*.
%
%      CHANNEL_INSPECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNEL_INSPECTOR.M with the given input arguments.
%
%      CHANNEL_INSPECTOR('Property','Value',...) creates a new CHANNEL_INSPECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channel_inspector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channel_inspector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channel_inspector

% Last Modified by GUIDE v2.5 19-Dec-2013 12:06:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @channel_inspector_OpeningFcn, ...
    'gui_OutputFcn',  @channel_inspector_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before channel_inspector is made visible.
function channel_inspector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channel_inspector (see VARARGIN)

% Choose default command line output for channel_inspector
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
nargin
% UIWAIT makes channel_inspector wait for user response (see UIRESUME)
% uiwait(handles.channel_inspector);
if nargin>3
    segment=varargin{1};
    t=varargin{2};
    if nargin<3
    fs=1./diff(t(1:2));
    else
        fs=varargin{3};
    end
    ymax=max(segment(:));
    ymin=min(segment(:));
    set(handles.ymax_edit,'String',sprintf('%1.2e',ymax));
    set(handles.ymin_edit,'String',sprintf('%1.2e',ymin));
    set(handles.channel_selector,'String', num2str((1:size(segment,2))'));
    set(handles.trial_selector,'String', num2str((1:size(segment,3))'));
    setappdata(handles.channel_inspector,'segment',segment);
    setappdata(handles.channel_inspector,'t',t);
    setappdata(handles.channel_inspector,'fs',fs);
    setappdata(handles.channel_inspector,'f1',3);
    setappdata(handles.channel_inspector,'f2',40);
    setappdata(handles.channel_inspector,'f2_1',70);
    setappdata(handles.channel_inspector,'f2_2',100);
    setappdata(handles.channel_inspector,'ymax',ymax);
    setappdata(handles.channel_inspector,'ymin',ymin);
    setappdata(handles.channel_inspector,'xmax',max(t));
    setappdata(handles.channel_inspector,'xmin',min(t));
    
    bad_marker=zeros(size(segment,2),size(segment,3));
    setappdata(handles.channel_inspector,'bad_marker',bad_marker);
    
    update_plot(handles);
    update_marker(handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = channel_inspector_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function file_Callback(hObject, eventdata, handles)
% hObject    handle to file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





% --------------------------------------------------------------------
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fig = handles.channel_inspector;
close(fig)


function out=prep_filter_data(data,f1,f2,fo,fs,amp)

out=data;
if(ndims(data)<3)
    out=butter_filter(data,f1,f2,fs,fo);
    if amp
        out=abs(hilbert(out));
    end
else
    for i=1:size(data,3)
        out(:,:,i)=butter_filter(data(:,:,i),f2_1,f2_2,fs,fo);
        if amp
            out(:,:,i)=abs(hilbert(out(:,:,i)));
        end
    end
end
        
function update_plot(handles)

fig=handles.channel_inspector;
di=handles.display;
ymax=getappdata(fig,'ymax');
ymin=getappdata(fig,'ymin');
xmax=getappdata(fig,'xmax');

xmin=getappdata(fig,'xmin');

f1=getappdata(fig,'f1');
f2=getappdata(fig,'f2');


f2_1=getappdata(fig,'f2_1');
f2_2=getappdata(fig,'f2_2');

flt=get(handles.use_filter,'Value');
amp=get(handles.use_amp,'Value');


flt2=get(handles.filter2_use,'Value');
amp2=get(handles.filter2_amp,'Value');

csc=get(handles.use_cascade,'Value');
if isempty(f1) | isempty(f2)
    flt=0;
end
if isempty(f2_1) | isempty(f2_2)
    flt2=0;
end

segment=getappdata(fig,'segment');
t=getappdata(fig,'t');
fs=getappdata(fig,'fs');
channel=get(handles.channel_selector,'Value');

fo=3;
if fs<4800
    fo=4;
end
mrk=cellstr(get(handles.channel_selector,'String'));
ix=strfind(mrk,'X');
bc=zeros(length(ix),1);
for i=1:length(bc)
    bc(i)=~isempty(ix{i});
end
bc=bc(channel);
bad_channels=find(bc);
if get(handles.hide_bad_channels,'Value')
    channel(bad_channels)=[];
end
data2=[];

if(length(channel)>0)
    trial=get(handles.trial_selector,'Value');
    data=squeeze(segment(:,channel,trial));
    if flt % prepare data for plotting
        data=prep_filter_data(data,f1,f2,fo,fs,amp);
    end
     if flt2 % show 2nd filter along with 1st
        sc=((f2_1+f2_2)/(f1+f2))^2;
        data2=sc*squeeze(segment(:,channel,trial));
        data2=prep_filter_data(data2,f2_1,f2_2,fo,fs,amp2);
    end
    if ndims(data)<3
        if ~csc
            plot(di,t,data,'LineWidth',1);
            if ~isempty(data2)
               hold on
               plot(di,t,data2,'r','LineWidth',1)
            end
            ylim(di,[ymin ymax]);        
            xlim(di,[xmin xmax]);
            
        else
            n=size(data,2);
            ds=ymax-ymin;
            
            % plot average across channels and 1st principal component
            component_figure=getappdata(fig,'component_figure');
            mm=mean(data,2);
            [U,S,V]=svd(cov(data));
            if isempty(component_figure) || ~ishandle(component_figure)
              component_figure=figure;
              setappdata(fig,'component_figure',component_figure);
              pm=plot(t,mm);
              hold on
              pcm1=plot(t,data*U(:,1),'r');
              hold off;
              setappdata(fig,'pm',pm);
              setappdata(fig,'pcm1',pcm1);
              legend({'channel mean','1st PC'});
              set(gca,'YLimMode','auto')
            else
                pm=getappdata(fig,'pm');
                pcm1=getappdata(fig,'pcm1');
                set(pm,'YData',mm);
                set(pcm1,'YData',data*U(:,1));
                set(get(pm,'Parent'),'YLimMode','auto');
            end
            
            offs=zeros(1,size(data,2));
            for i=1:length(offs)
                offs(i)=ymin+i*ds;
            end
            data=data+repmat(offs,size(data,1),1);
            
            plot(di,t,data,'b');
            if ~isempty(data2)
              data2=data2+repmat(offs,size(data,1),1);
              hold on
              plot(di,t,data2,'r');
              hold off
            end
            
            ylim([2*ymin offs(end)+ds]);xlim([xmin xmax]);
             xlim([xmin xmax]);

            axes(di);
            hold(di,'on');
            tm=(t(end)-t(1))/2+t(1);
            for i=1:length(offs)
                if(length(offs)==length(channel))
                    text(tm,offs(i),sprintf('%i',channel(i)),'FontSize',14)
                end
                if(length(offs)==length(trial))
                    text(tm,offs(i),sprintf('%i',trial(i)),'FontSize',14)
                end
            end
            hold(di,'off');
        end
        
    else
        cla(di);
        nn=size(data,3);
        offs=ymin;
        for i=1:nn
            if(i==1)
                hold(di,'on');
            end
            plot(di,t,data(:,:,i)+offs);
            if ~isempty(data2)
              plot(di,t,data2(:,:,i)+offs,'r');
            end
            offs=offs+(ymax-ymin);
        end
        hold(di,'off');
        ylim(di,[2*ymin ymin+nn*(ymax-ymin)]);
        xlim(di,[xmin xmax]);
    end
    if length(channel)==1
        if length(trial)==1
            title(di,sprintf('Channel %i trial %i',channel,trial));
        else
            title(di,sprintf('Channel %i trial %i - %i',channel,min(trial),max(trial)));
            
        end
    else
        if length(trial)==1
            title(di,sprintf('Channels %i - %i trial %i',min(channel),max(channel),trial));
        else
            title(di,sprintf('Channels %i - %i trial %i-%i',min(channel),max(channel),min(trial),max(trial)));
            
        end
    end
end


function update_marker(handles)
axes(handles.bad_marker);
bad_marker=getappdata(handles.channel_inspector,'bad_marker');
imagesc(bad_marker);
axis off
ylabel(handles.bad_marker,'channel');
xlabel(handles.bad_marker,'trial');

% --------------------------------------------------------------------
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load the time x channel x trial data structure

[filename, pathname] = uigetfile('*.mat', 'select data file');
if ischar(filename)
    set(handles.status_txt,'String','loading ...');
    data=load(fullfile(pathname,filename));
    fs=data.fs;
    ff=fieldnames(data);
    segment=[];
    
    for i=1:length(ff)
        fi=ff{i};
        if(ndims(getfield(data,fi))>2 && size(getfield(data,fi),2)>2)
            segment=getfield(data,fi);
            break
        end
        
    end
    t=data.t;
    if ~isempty(segment)
        set(handles.status_txt,'String',sprintf('File: %s Samplingrate: %i channels: %i trials:%i',filename,fs,size(segment,2),size(segment,3)));
        ymax=max(segment(:));
        ymin=min(segment(:));
        set(handles.ymax_edit,'String',sprintf('%1.2e',ymax));
        set(handles.ymin_edit,'String',sprintf('%1.2e',ymin));
        set(handles.channel_selector,'String', num2str((1:size(segment,2))'));
        set(handles.trial_selector,'String', num2str((1:size(segment,3))'));
        setappdata(handles.channel_inspector,'segment',segment);
        setappdata(handles.channel_inspector,'t',t);
        setappdata(handles.channel_inspector,'fs',fs);
        setappdata(handles.channel_inspector,'f1',3);
        setappdata(handles.channel_inspector,'f2',40);
        
        setappdata(handles.channel_inspector,'ymax',ymax);
        setappdata(handles.channel_inspector,'ymin',ymin);
        setappdata(handles.channel_inspector,'xmax',max(t));
        setappdata(handles.channel_inspector,'xmin',min(t));
        
        bad_marker=zeros(size(segment,2),size(segment,3));
        setappdata(handles.channel_inspector,'bad_marker',bad_marker);
        
        update_plot(handles);
        update_marker(handles);
    else
        set(handles.status_txt,'String','no data found');
    end
end




function ymax_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ymax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymax_edit as text
%        str2double(get(hObject,'String')) returns contents of ymax_edit as a double
if ~isnan(str2double(get(hObject,'String')))
    setappdata(handles.channel_inspector,'ymax',str2double(get(hObject,'String')));
    update_plot(handles);
    
end

% --- Executes during object creation, after setting all properties.
function ymax_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymax_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ymin_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ymin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ymin_edit as text
%        str2double(get(hObject,'String')) returns contents of ymin_edit as a double
if ~isnan(str2double(get(hObject,'String')))
    setappdata(handles.channel_inspector,'ymin',str2double(get(hObject,'String')));
    update_plot(handles);
    
end

% --- Executes during object creation, after setting all properties.
function ymin_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ymin_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_selector.
function channel_selector_Callback(hObject, eventdata, handles)
% hObject    handle to channel_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_selector

update_plot(handles);

% --- Executes during object creation, after setting all properties.
function channel_selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in trial_selector.
function trial_selector_Callback(hObject, eventdata, handles)
% hObject    handle to trial_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns trial_selector contents as cell array
%        contents{get(hObject,'Value')} returns selected item from trial_selector
update_plot(handles);


% --- Executes during object creation, after setting all properties.
function trial_selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trial_selector (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function filter_f1_Callback(hObject, eventdata, handles)
% hObject    handle to filter_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_f1 as text
%        str2double(get(hObject,'String')) returns contents of filter_f1 as a double
if ~isnan(str2double(get(hObject,'String')))
    f1=str2double(get(hObject,'String'));
    f2=str2double(get(handles.filter_f2,'String'));
    if(f2>f1)
        setappdata(handles.channel_inspector,'f1',f1);
        update_plot(handles);
    end
end





function filter_f2_Callback(hObject, eventdata, handles)
% hObject    handle to filter_f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter_f2 as text
%        str2double(get(hObject,'String')) returns contents of filter_f2 as a double
if ~isnan(str2double(get(hObject,'String')))
    f2=str2double(get(hObject,'String'));
    f1=str2double(get(handles.filter_f1,'String'));
    if(f2>f1)
        setappdata(handles.channel_inspector,'f2',f2);
    end
    update_plot(handles);
end


% --- Executes during object creation, after setting all properties.
function filter_f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_filter.
function use_filter_Callback(hObject, eventdata, handles)
% hObject    handle to use_filter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_filter
update_plot(handles);


% --- Executes on button press in use_amp.
function use_amp_Callback(hObject, eventdata, handles)
% hObject    handle to use_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_amp
update_plot(handles);


% --- Executes on button press in mark_channel.
function mark_channel_Callback(hObject, eventdata, handles)
% hObject    handle to mark_channel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

channel=get(handles.channel_selector,'Value');
trial=get(handles.trial_selector,'Value');
mrk=cellstr(get(handles.channel_selector,'String'));

bad_marker=getappdata(handles.channel_inspector,'bad_marker');
if bad_marker(channel,trial)<1
    bad_marker(channel,trial)=1;
    for k=1:length(channel)
        mrk{channel(k)}=[num2str(channel(k)) ' X'];
    end
else
    bad_marker(channel,trial)=0;
    for k=1:length(channel)
        mrk{channel(k)}=num2str(channel(k));
    end
end
set(handles.channel_selector,'String',mrk);
setappdata(handles.channel_inspector,'bad_marker',bad_marker);
update_marker(handles);


% --- Executes on button press in mark_trial.
function mark_trial_Callback(hObject, eventdata, handles)
% hObject    handle to mark_trial (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
channel=get(handles.channel_selector,'Value');
mrk=cellstr(get(handles.trial_selector,'String'));
trial=get(handles.trial_selector,'Value');
bad_marker=getappdata(handles.channel_inspector,'bad_marker');
if bad_marker(channel,trial)<1
    bad_marker(channel,trial)=1;
    for k=1:length(trial)
        mrk{trial(k)}=[num2str(trial(k)) ' X'];
    end
else
    bad_marker(channel,trial)=0;
    for k=1:length(trial)
        mrk{trial(k)}=num2str(trial(k));
    end
end
set(handles.trial_selector,'String',mrk);
setappdata(handles.channel_inspector,'bad_marker',bad_marker);
update_marker(handles);

% --- Executes on button press in use_cascade.
function use_cascade_Callback(hObject, eventdata, handles)
% hObject    handle to use_cascade (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of use_cascade
update_plot(handles);


% --------------------------------------------------------------------
function export_bad_trials_Callback(hObject, eventdata, handles)
% hObject    handle to export_bad_trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mrk=(get(handles.channel_selector,'String'));
if(~ischar(mrk))
ix=strfind(mrk,'X');
else
    ix=[];
end
bc=zeros(length(ix),1);
for i=1:length(bc)
    bc(i)=~isempty(ix{i});
end
bad_channels=find(bc);
bad_marker=getappdata(handles.channel_inspector,'bad_marker');
[fname,path]=uiputfile('bad_trials.mat','save bad trials');
if(fname>0)
    save(fullfile(path,fname),'bad_marker','bad_channels');
end

% --- Executes on button press in hide_bad_channels.
function hide_bad_channels_Callback(hObject, eventdata, handles)
% hObject    handle to hide_bad_channels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide_bad_channels
update_plot(handles);


% --------------------------------------------------------------------
function import_bad_trials_Callback(hObject, eventdata, handles)
% hObject    handle to import_bad_trials (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[fname,path]=uigetfile('*.mat','load bad trials');
if(fname>0)
    load(fullfile(path,fname));
    setappdata(handles.channel_inspector,'bad_marker',bad_marker);
    mrk=cellstr(get(handles.trial_selector,'String'));
    for i=1:size(bad_marker,1)
        for k=1:size(bad_marker,2)
            if bad_marker(i,k)>0;
                mrk{k}=[num2str(k) ' X'];
            end
        end
    end
    
    set(handles.trial_selector,'String',mrk);
    
    mrk=cellstr(get(handles.channel_selector,'String'));
    
    for k=1:length(bad_channels)
        mrk{bad_channels(k)}=[num2str(bad_channels(k)) ' X'];
        
    end
    
    set(handles.channel_selector,'String',mrk);
    
end
update_marker(handles);



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

if ~isnan(str2double(get(hObject,'String')))
    setappdata(handles.channel_inspector,'xmin',str2double(get(hObject,'String')));
    update_plot(handles);
    
end


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
if ~isnan(str2double(get(hObject,'String')))
    setappdata(handles.channel_inspector,'xmax',str2double(get(hObject,'String')));
    update_plot(handles);
    
end

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on trial_selector and none of its controls.
function trial_selector_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to trial_selector (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch(eventdata.Key)
    case 'b'
        channel=get(handles.channel_selector,'Value');
        mrk=cellstr(get(handles.trial_selector,'String'));
        trial=get(handles.trial_selector,'Value');
        bad_marker=getappdata(handles.channel_inspector,'bad_marker');
        if bad_marker(channel,trial)<1
            bad_marker(channel,trial)=1;
            for k=1:length(trial)
                mrk{trial(k)}=[num2str(trial(k)) ' X'];
            end
        else
            bad_marker(channel,trial)=0;
            for k=1:length(trial)
                mrk{trial(k)}=num2str(trial(k));
            end
        end
        set(handles.trial_selector,'String',mrk);
        setappdata(handles.channel_inspector,'bad_marker',bad_marker);
        trial=trial+1;
        if(trial>length(mrk))
            trial=1;
        end
        set(handles.trial_selector,'Value',trial);
        update_marker(handles);
        update_plot(handles);
    otherwise
end



function filter2_f1_Callback(hObject, eventdata, handles)
% hObject    handle to filter2_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter2_f1 as text
%        str2double(get(hObject,'String')) returns contents of filter2_f1 as a double
if ~isnan(str2double(get(hObject,'String')))
    f1=str2double(get(hObject,'String'));
    f2=str2double(get(handles.filter2_f2,'String'));
    if(f2>f1)
        setappdata(handles.channel_inspector,'f2_1',f1);
        update_plot(handles);
    end
end


function filter2_f2_Callback(hObject, eventdata, handles)
% hObject    handle to filter2_f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filter2_f2 as text
%        str2double(get(hObject,'String')) returns contents of filter2_f2 as a double

if ~isnan(str2double(get(hObject,'String')))
    f2=str2double(get(hObject,'String'));
    f1=str2double(get(handles.filter2_f1,'String'));
    if(f2>f1)
        setappdata(handles.channel_inspector,'f2_2',f2);
        update_plot(handles);
    end
end

% --- Executes on button press in filter2_use.
function filter2_use_Callback(hObject, eventdata, handles)
% hObject    handle to filter2_use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filter2_use
update_plot(handles);


% --- Executes on button press in filter2_amp.
function filter2_amp_Callback(hObject, eventdata, handles)
% hObject    handle to filter2_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filter2_amp
update_plot(handles);


% --- Executes during object creation, after setting all properties.
function filter2_f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter2_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function filter2_f2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter2_f2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function filter2_use_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter2_use (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function filter2_amp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter2_amp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function filter_f1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_f1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
