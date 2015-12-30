function varargout = modspecgramgui_demodoptions2(varargin)
% MODSPECGRAMGUI_DEMODOPTIONS2 M-file for modspecgramgui_demodoptions2.fig
%      MODSPECGRAMGUI_DEMODOPTIONS2, by itself, creates a new MODSPECGRAMGUI_DEMODOPTIONS2 or raises the existing
%      singleton*.
%
%      H = MODSPECGRAMGUI_DEMODOPTIONS2 returns the handle to a new MODSPECGRAMGUI_DEMODOPTIONS2 or the handle to
%      the existing singleton*.
%
%      MODSPECGRAMGUI_DEMODOPTIONS2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MODSPECGRAMGUI_DEMODOPTIONS2.M with the given input arguments.
%
%      MODSPECGRAMGUI_DEMODOPTIONS2('Property','Value',...) creates a new MODSPECGRAMGUI_DEMODOPTIONS2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before modspecgramgui_demodoptions2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to modspecgramgui_demodoptions2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help modspecgramgui_demodoptions2

% Last Modified by GUIDE v2.5 06-Aug-2010 10:45:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @modspecgramgui_demodoptions2_OpeningFcn, ...
                   'gui_OutputFcn',  @modspecgramgui_demodoptions2_OutputFcn, ...
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


% --- Executes just before modspecgramgui_demodoptions2 is made visible.
function modspecgramgui_demodoptions2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to modspecgramgui_demodoptions2 (see VARARGIN)

% Choose default command line output for modspecgramgui_demodoptions2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes modspecgramgui_demodoptions2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = modspecgramgui_demodoptions2_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popup_numbands.
function popup_numbands_Callback(hObject, eventdata, handles)
% hObject    handle to popup_numbands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_numbands contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_numbands


% --- Executes during object creation, after setting all properties.
function popup_numbands_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_numbands (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_downsample18.
function radio_downsample18_Callback(hObject, eventdata, handles)
% hObject    handle to radio_downsample18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_downsample18


% --- Executes on button press in radio_downsample14.
function radio_downsample14_Callback(hObject, eventdata, handles)
% hObject    handle to radio_downsample14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_downsample14


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in radio_standard.
function radio_standard_Callback(hObject, eventdata, handles)
% hObject    handle to radio_standard (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_standard


% --- Executes on button press in radio_minimal.
function radio_minimal_Callback(hObject, eventdata, handles)
% hObject    handle to radio_minimal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_minimal


% --- Executes on selection change in popup_modsizes.
function popup_modsizes_Callback(hObject, eventdata, handles)
% hObject    handle to popup_modsizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_modsizes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_modsizes


% --- Executes during object creation, after setting all properties.
function popup_modsizes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_modsizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radio_modwindow50.
function radio_modwindow50_Callback(hObject, eventdata, handles)
% hObject    handle to radio_modwindow50 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_modwindow50


% --- Executes on button press in radio_modwindow75.
function radio_modwindow75_Callback(hObject, eventdata, handles)
% hObject    handle to radio_modwindow75 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_modwindow75


% --- Executes on selection change in popup_carrwinsizes.
function popup_carrwinsizes_Callback(hObject, eventdata, handles)
% hObject    handle to popup_carrwinsizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popup_carrwinsizes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popup_carrwinsizes


% --- Executes during object creation, after setting all properties.
function popup_carrwinsizes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popup_carrwinsizes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_numharmonics_Callback(hObject, eventdata, handles)
% hObject    handle to edit_numharmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_numharmonics as text
%        str2double(get(hObject,'String')) returns contents of edit_numharmonics as a double


% --- Executes during object creation, after setting all properties.
function edit_numharmonics_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_numharmonics (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_voicingsensitivity_Callback(hObject, eventdata, handles)
% hObject    handle to edit_voicingsensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_voicingsensitivity as text
%        str2double(get(hObject,'String')) returns contents of edit_voicingsensitivity as a double


% --- Executes during object creation, after setting all properties.
function edit_voicingsensitivity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_voicingsensitivity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_f0smoothness_Callback(hObject, eventdata, handles)
% hObject    handle to edit_f0smoothness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_f0smoothness as text
%        str2double(get(hObject,'String')) returns contents of edit_f0smoothness as a double


% --- Executes during object creation, after setting all properties.
function edit_f0smoothness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_f0smoothness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_updateFilterbank.
function pushbutton_updateFilterbank_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_updateFilterbank (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


