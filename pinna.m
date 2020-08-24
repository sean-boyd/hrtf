%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ELEC 484 - Final Project - HRTF Model
%%  Name: Sean Boyd
%%  Date: July 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% pinna.m - Generates multiple delays from pinna model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In       Input
%% Fs       Sample rate (samples/sec)
%% Theta    Azimuth (deg)
%% Phi      Elevation (deg) 
%% PinnaSet Set of Pinna parameters (choose '1' or '2')
%% Out      Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Out] = pinna(In, Fs, Theta, Phi, PinnaSet)

% Convert angles to rad/s
Theta = Theta*pi/180;
Phi = Phi*pi/180;

% Constants (Table 6.1 DAFX p158)
Rho = [ 1 0.5 -1 0.5 -0.25 0.25];
A = [1 5 5 5 5];
B = [2 4 7 11 13];

if (PinnaSet == 2)
    D = [0.85 0.35 0.35 0.35 0.35];
else
    D = [1 0.5 0.5 0.5 0.5];
end;

Tau = [0 0 0 0 0 0];
Delay = [0 0 0 0 0 0];

% Generate delays
for i = 1:5
    Tau(i+1) = A(i) * cos(Theta/2) * sin(D(i)*(pi/2-Phi)) + B(i);
    Delay(i+1) = round(Tau(i+1)*Fs/1000);
end

% Generate output and temp output vectors
Out = zeros(1, length(In) + max(Delay));
Out_temp = zeros(1, length(In) + max(Delay));

% Combine original signal with five delays
for j = 1:6
    Out_temp(1, (Delay(j) + 1):(Delay(j) + length(In))) = In*Rho(j);
    Out = Out + Out_temp(1,:);
end

