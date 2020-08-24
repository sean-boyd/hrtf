%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ELEC 484 - Final Project - HRTF Model
%%  Name: Sean Boyd
%%  Date: July 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hrtfmodel.m - Model-Based HRTF
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear Command Window and Variables
clc;
clear;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANTS TO BE SET BY USER

%% SPEAKER PLACEMENT
Theta1 = -30; % Azimuth for RIGHT signal (0* to -89*) (degrees)
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
FileName = 'davematthewsband'; % Name of the WAV file (do not include ".wav")
Playback = 0; % If '1' then file will be played back by MATLAB

%% WAV must be 5:45 maximum. (~58MB) due to the limitations of the wavwrite
%% command. Max RAM usage by MATLAB process is 1,024,000 K during wavwrite.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read input audio file
clc; StatusMessage = 'Reading Input File' % Status message for Command Window
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
clc; StatusMessage = 'Processing Left Channel' % Status message for Command Window

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
clc; StatusMessage = 'Processing Right Channel' % Status message for Command Window

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
clc; StatusMessage = 'Creating Output' % Status message for Command Window
Out_L = Pinna_L1 + Pinna_L2;
Out_R = Pinna_R1 + Pinna_R2;
clear Pinna_L1;
clear Pinna_L2;
clear Pinna_R1;
clear Pinna_R2;

% Ensure both Output signals are equal length
[Out_L, Out_R] = matchlength(Out_L, Out_R);

% Normalize signals to avoid output clipping
clc; StatusMessage = 'Normalizing Output' % Status message for Command Window

MaxVal = 1.0001*max(max(abs(Out_L)), max(abs(Out_R)))
Out_R = Out_R/MaxVal;
Out_L = Out_L/MaxVal;

% Write output audio file
clc; StatusMessage = 'Writing Output File' % Status message for Command Window
wavwrite([Out_L' Out_R'], Fs, bits, [FileName FileOutSuffix]);

% Play audio file
if Playback == 1
    clc; StatusMessage = 'Playing Output' % Status message for Command Window
    sound([Out_L' Out_R'], Fs, bits);
end;

clc; StatusMessage = 'Finished!' % Status message for Command Window
clear;