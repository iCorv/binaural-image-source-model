function [ Tmp ] = mixingTime( V, S )
% Calculate mixing time from room volume and room surface
Tmp = 20*V/S + 12;
end

