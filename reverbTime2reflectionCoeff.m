function [ beta ] = reverbTime2reflectionCoeff( roomDim, reverbTime, c )
%%
% This function calculates the reflection coefficients of a "shoebox" room 
% with given dimensions and reverberation time.
%
% INPUT:
%       c               -       acoustic velocity (m/s)
%       roomDim         -       room dimensions [x y z] (m) 
%       reverbTime      -       reverberation time (s)
%
% OUTPUT:
%       beta            -       reflection coefficients for each wall 
%                               [x1 x2 y1 y2 z1 z2]
%%

V = roomDim(1) * roomDim(2) * roomDim(3);
S = 2*(roomDim(1)*roomDim(3)+roomDim(2)*roomDim(3)+roomDim(1)*roomDim(2));
beta = ones(6,1);
if reverbTime ~= 0
	alpha = 24*V*log(10.0)/(c*S*reverbTime);
    if (alpha > 1)
        print('Error: The reflection coefficients cannot be calculated using the current room parameters, please change room size and/or reverberation time.');
    end
    beta = beta .* sqrt(1-alpha);
else 
    for i = 1:7
        beta(i) = 0;
    end
end
end

