%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ELEC 484 - Final Project - HRTF Model
%%  Name: Sean Boyd
%%  Date: July 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% head.m - Head shadowing and ITD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In       Input
%% Fs       Sample rate (samples/sec)
%% Theta    Azimuth (deg)
%% HeadSize Diameter of the listener's head (cm)
%% Out      Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Out] = head(In, Fs, Theta, HeadSize)

% Constants
C = 340.29;  % speed of sound in m/s												

w0 = C/(HeadSize/200);
Theta = Theta + 90;
AlphaMin = 0.1;
ThetaMin = 150;

% Eqn 5 of Brown & Duda p.2)
Alpha = (1 + AlphaMin/2) + (1 - AlphaMin/2)*cos((Theta/ThetaMin*180)*pi/180) ;	

% Numerator of transfer function
B = [(w0 + Alpha*Fs), (w0 - Alpha*Fs)] ;	

% Denominator of transfer function                      
A = [(w0 + Fs), (w0 - Fs)] ;	
    
Mag = filter(B, A, In);

if (abs(Theta) < 90)
 GroupDelay = - Fs/w0 * (cos(Theta*pi/180) - 1);
else
 GroupDelay = Fs/w0 * ((abs(Theta) - 90)*pi/180 + 1); 
end;

% allpass filter coefficient
X = (1 - GroupDelay)/(1 + GroupDelay);

Out = filter([X, 1],[1, X], Mag);