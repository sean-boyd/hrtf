%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ELEC 484 - Final Project - HRTF Model
%%  Name: Sean Boyd
%%  Date: July 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% room.m - Delay based on a room reflection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In       Input
%% Fs       Sample rate (samples/second)
%% Delay    Delay (ms)
%% Gain     Gain (dB)
%% Out      Output (delayed input)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Out] = room(In, Fs, Delay, Gain)

T = ceil((Delay/1000) * Fs);

K = 10^(Gain/10);
N = length(In);
 
% Generate echo
Echo = [zeros(T, 1); In(1:N-T)];
Echo = Echo * K;

Out = In + Echo;