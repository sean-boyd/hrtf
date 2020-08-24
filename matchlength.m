%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  ELEC 484 - Final Project - HRTF Model
%%  Name: Sean Boyd
%%  Date: July 2007
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% matchlength.m - Ensures two vectors are the same length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% In1		Input 1
%% Out1		Output 1
%% In2		Input 2
%% Out2		Output 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Out1, Out2] = matchlength(In1, In2)

if (length(In1) < length(In2))
    Out1 = [In1 zeros(1,length(In2)-length(In1))];
    Out2 = In2;
else
    Out1 = In1;
    Out2 = [In2 zeros(1,length(In1)-length(In2))];
end;