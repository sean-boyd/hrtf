function varargout = hrtfgui(varargin)
% HRTFGUI M-file for hrtfgui.fig
%      HRTFGUI, by itself, creates a new HRTFGUI or raises the existing
%      singleton*.
%
%      H = HRTFGUI returns the handle to a new HRTFGUI or the handle to
%      the existing singleton*.
%
%      HRTFGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HRTFGUI.M with the given input arguments.
%
%      HRTFGUI('Property','Value',...) creates a new HRTFGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hrtfgui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hrtfgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hrtfgui_OpeningFcn, ...
                   'gui_OutputFcn',  @hrtfgui_OutputFcn, ...
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


% --- Executes just before hrtfgui is made visible.
function hrtfgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hrtfgui (see VARARGIN)

% Choose default command line output for hrtfgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hrtfgui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hrtfgui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in radiobutton3.
function radiobutton3_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of radiobutton3



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear Command Window and Variables
clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANTS TO BE SET BY USER

%% SPEAKER PLACEMENT
Theta1 = handles.edit4;
%edit4_Callback
%-30; % Azimuth for RIGHT signal (0* to -89*) (degrees)
Theta2 = 30; % Azimuth for LEFT channel (0* to 89*) (degrees)
% 0* is directly in front of the listener; 
Phi = 0; % Elevation of both speakers(degrees)

%% USER HRTF PARAMETERS
HeadSize = 15; % Diameter of listener's head (cm)
PinnaSet = 1; % Pinna parameters (choose '1' or '2')

%% ROOM PARAMETERS
RoomDelay = 12; % Room delay (ms)
RoomGain = -9; % Room gain (dB)

%% FILE AND PLAYBACK OPTION
FileName = 'lp'; % Name of the WAV file (do not include ".wav")
Playback = 0; % If '1' then file will be played back by MATLAB

%% WAV must be 5:45 maximum. (~58MB) due to the limitations of the wavwrite
%% command. Max RAM usage by MATLAB process is 1,024,000 K during wavwrite.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read input audio file
clc; OutputMessage = 'Reading Input File' % Status message for Command Window
%set(handles.text11, 'String', OutputMessage);
FileInSuffix = '.wav';
FileOutSuffix = '_out.wav';

[In_Stereo, Fs, bits] = wavread([FileName FileInSuffix]);
In_L = In_Stereo(:,2);    % Extract input channel LEFT
In_R = In_Stereo(:,1);    % Extract input channel RIGHT
clear In_Stereo;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Condition Theta to avoid divide-by-zero errors
if (abs(Theta1) == 180)
    Theta1 = sign(Theta1) * 179;
end
if (abs(Theta2) == 180)
    Theta2 =  sign(Theta2) * 179;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Apply room effects
In_L = room(In_L, Fs, RoomDelay, RoomGain);    % Apply room response
In_R = room(In_R, Fs, RoomDelay, RoomGain);    % Apply room response 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculations - for the LEFT output channel
clc; OutputMessage = 'Processing_Left_Channel' % Status message for Command Window

% Process Head shadowing on the original signal
Head_R1 = head(In_L, Fs, Theta1, HeadSize);
% Process Shoulder reflection on the original signal
Shoulder_R1 = shoulder(In_L, Fs, Theta1, Phi);
% Combine Head and Shoulder signals
PrePinna_R1 = zeros(1, max(length(Head_R1),length(Shoulder_R1)));
PrePinna_R1(1:length(Head_R1)) = PrePinna_R1(1:length(Head_R1)) + Head_R1';
PrePinna_R1(1:length(Shoulder_R1)) = PrePinna_R1(1:length(Shoulder_R1)) + Shoulder_R1;
clear Head_R1;
clear Shoulder_R1;
% Process Pinna reflections on the PrePinna signal
Pinna_R1 = pinna(PrePinna_R1, Fs, Theta1, Phi, PinnaSet);
clear PrePinna_R1;

% Process Head shadowing on the original signal
Head_L1 = head(In_L, Fs, -Theta1, HeadSize);
% Process Shoulder reflection on the original signal
Shoulder_L1 = shoulder(In_L, Fs, -Theta1, Phi);
clear In_L;
% Combine Head and Shoulder signals
PrePinna_L1 = zeros(1, max(length(Head_L1),length(Shoulder_L1)));
PrePinna_L1(1:length(Head_L1)) = PrePinna_L1(1:length(Head_L1)) + Head_L1';
PrePinna_L1(1:length(Shoulder_L1)) = PrePinna_L1(1:length(Shoulder_L1)) + Shoulder_L1;
clear Head_L1;
clear Shoulder_L1;
% Process Pinna reflections on the PrePinna signal
Pinna_L1 = pinna(PrePinna_L1, Fs, -Theta1, Phi, PinnaSet);
clear PrePinna_L1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calculations - for the RIGHT output channel
clc; OutputMessage = 'Processing_Right_Channel' % Status message for Command Window

% Process Head shadowing on the original signal
Head_R2 = head(In_R, Fs, Theta2, HeadSize);
% Process Shoulder reflection on the original signal
Shoulder_R2 = shoulder(In_R, Fs, Theta2, Phi);
% Combine Head and Shoulder signals
PrePinna_R2 = zeros(1, max(length(Head_R2),length(Shoulder_R2)));
PrePinna_R2(1:length(Head_R2)) = PrePinna_R2(1:length(Head_R2)) + Head_R2';
PrePinna_R2(1:length(Shoulder_R2)) = PrePinna_R2(1:length(Shoulder_R2)) + Shoulder_R2;
clear Head_R2;
clear Shoulder_R2;
% Process Pinna reflections on the PrePinna signal
Pinna_R2 = pinna(PrePinna_R2, Fs, Theta2, Phi, PinnaSet);
clear PrePinna_R2;

% Process Head shadowing on the original signal
Head_L2 = head(In_R, Fs, -Theta2, HeadSize);
% Process Shoulder reflection on the original signal
Shoulder_L2 = shoulder(In_R, Fs, -Theta2, Phi);
clear In_R;
% Combine Head and Shoulder signals
PrePinna_L2 = zeros(1, max(length(Head_L2),length(Shoulder_L2)));
PrePinna_L2(1:length(Head_L2)) = PrePinna_L2(1:length(Head_L2)) + Head_L2';
PrePinna_L2(1:length(Shoulder_L2)) = PrePinna_L2(1:length(Shoulder_L2)) + Shoulder_L2;
clear Head_L2;
clear Shoulder_L2;
% Process Pinna reflections on the PrePinna signal
Pinna_L2 = pinna(PrePinna_L2, Fs, -Theta2, Phi, PinnaSet);
clear PrePinna_L2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ensure both right Pinna signals are equal length
[Pinna_R1, Pinna_R2] = matchlength(Pinna_R1, Pinna_R2);

% Ensure both left Pinna signals are equal length
[Pinna_L1, Pinna_L2] = matchlength(Pinna_L1, Pinna_L2);

% Create output signals
clc; OutputMessage = 'Creating_Output' % Status message for Command Window
Out_L = Pinna_L1 + Pinna_L2;
Out_R = Pinna_R1 + Pinna_R2;
clear Pinna_L1;
clear Pinna_L2;
clear Pinna_R1;
clear Pinna_R2;

% Ensure both Output signals are equal length
[Out_L, Out_R] = matchlength(Out_L, Out_R);

% Normalize signals to avoid output clipping
clc; OutputMessage = 'Normalizing_Output' % Status message for Command Window
MaxVal = max(max(Out_L, Out_R));
Out_R = Out_R/MaxVal;
Out_L = Out_L/MaxVal;

% Write output audio file
clc; OutputMessage = 'Writing_Output_File' % Status message for Command Window
wavwrite([Out_L' Out_R'], Fs, bits, [FileName FileOutSuffix]);

% Play audio file
if Playback == 1
    clc; OutputMessage = 'Playing_Output' % Status message for Command Window
    sound([Out_L' Out_R'], Fs, bits);
end;

clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton2



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double
Value = str2double(get(hObject,'string'));

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


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



function text1_Callback(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of text1 as text
%        str2double(get(hObject,'String')) returns contents of text1 as a double


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


