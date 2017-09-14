function [ alphas ] = roomAbsorption()

% values taken from "Auralization - Michael Vorlaender" 
% octave band frequencies: 125, 250, 500, 1k, 2k, 4k, 8k

% Perforated veneered chipboard, 50 mm, 1 mm holes, 3 mm spacing, 9% hole surface ratio, 150 mm cavity filled with 30 mm mineral wool
walls = [0.41 0.67 0.58 0.59 0.68 0.35 0.35];
% 6 mm pile carpet bonded to open-cell foam underlay
floor = [0.13 0.19 0.2 0.54 0.7 0.72 0.72];
% Wedge-shaped, melamine foam, ceiling tile
ceiling = [0.12 0.33 0.83 0.97 0.98 0.95 0.95];
alphas = [repmat(walls,4,1);ceiling;floor];
alphas = alphas';

end

