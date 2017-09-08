function [ alphas ] = roomAbsorption( )

% octave band frequencies: 225, 250, 500, 1k, 2k, 4k, 8k

% Smooth brickwork, 10 mm deep pointing, pit sand mortar
walls = [0.28 0.19 0.22 0.26 0.22 0.24 0.24];
% 6 mm pile carpet bonded to open-cell foam underlay
floor = [0.13 0.19 0.2 0.54 0.7 0.72 0.72];
alphas = [repmat(walls,5,1);floor];
alphas = alphas';

end

