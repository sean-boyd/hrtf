%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ELEC 484 - Final Project - HRTF Model
%%  Name: Sean Boyd
%%  Date: July 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% shoulder.m - Delay based on a single shoulder reflection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In       Input
%% Fs       Sample rate (samples/sec)
%% Theta    Azimuth (deg)
%% Phi      Elevation (deg) 
%% Out      Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Out] = shoulder(In, Fs, Theta, Phi)

% Delay in ms (eqn 6.17 of DAFX p.157)
Tau = 1.2*(180 - Theta)/180 * (1 - 0.00004*((Phi - 80)*180/(180 + Theta))^2);

% Determine length of delay in samples
DelaySamples = abs(round(Tau/1000*Fs));

% Create an zeroed ouput vector
Out = zeros(1, length(In) + DelaySamples);

% Write the delayed signal to the output vector
Out(DelaySamples + 1 : length(Out)) = In;