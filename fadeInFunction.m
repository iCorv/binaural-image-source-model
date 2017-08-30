function [ fadeIn ] = fadeInFunction( mixingTime, fs, irLength )

nSamples = round(fs*mixingTime);

fadeIn = linspace(0,1,nSamples);

fadeIn = [fadeIn ones(1,irLength-nSamples)];

end

