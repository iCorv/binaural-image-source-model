function [ fadeIn ] = fadeInFunction( mixingTime, fs, onset, ir, mode )
onset = round(onset);
if strcmp(mode,'linear')
    nSamples = round(fs*mixingTime);

    fadeIn = linspace(0,1,nSamples-onset);

    fadeIn = [zeros(1,onset) fadeIn ones(1,length(ir)-nSamples)];
end
if strcmp(mode,'EDC')
    %fadeIn = EDC(ir);
    %fadeIn = [zeros(1,onset) edc(onset:end)];
    fadeIn = ones(1,length(ir));
end
end

