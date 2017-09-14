function [ fadeIn ] = fadeInFunction( mixingTime, fs, onset, ir, mode )
% mode:
% 'var1' - direct at mixing time
% 'var2' - halfway between onset and mixing time
% 'var3' - from onset
% 'var4' - onset + 1/3 amplitude
% 'var5' - onset + 2/3 amplitude
% 'var6' - full 
%

onset = round(onset);

if strcmp(mode,'var1')
    nSamples = round(fs*mixingTime);
    fadeIn = [zeros(1,nSamples) ones(1,length(ir)-nSamples)];
end

if strcmp(mode,'var2')
    nSamples = round(fs*mixingTime);

    fadeIn = linspace(0,1,round((nSamples-onset)/2));

    fadeIn = [zeros(1,onset+round((nSamples-onset)/2)) fadeIn ones(1,length(ir)-nSamples)];
end

if strcmp(mode,'var3')
    nSamples = round(fs*mixingTime);

    fadeIn = linspace(0,1,nSamples-onset);

    fadeIn = [zeros(1,onset) fadeIn ones(1,length(ir)-nSamples)];
end

if strcmp(mode,'var4')
    nSamples = round(fs*mixingTime);

    fadeIn = linspace(1/3,1,nSamples-onset);

    fadeIn = [zeros(1,onset) fadeIn ones(1,length(ir)-nSamples)];
end

if strcmp(mode,'var5')
    nSamples = round(fs*mixingTime);

    fadeIn = linspace(2/3,1,nSamples-onset);

    fadeIn = [zeros(1,onset) fadeIn ones(1,length(ir)-nSamples)];
end


if strcmp(mode,'var6')
    fadeIn = [zeros(1,onset) ones(1,length(ir)-onset)];
end

fadeIn = fadeIn(1:length(ir));
end

