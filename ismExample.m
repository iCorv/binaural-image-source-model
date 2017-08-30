%%
amt = genpath('../../[1] amtoolbox');
addpath(amt);
clear(amt);
amtstart;

%%
clc;clear;
c = 340;                    % sound velocity (m/s)
% !always set 44.1kHz when working with FABIAN HRIR's!
fs = 44100;                 % sample frequency (samples/s) 
receiverPos = [1 2 2];      % receiver position [x y z] (m)
sourcePos = [3 3.6 2];        % source position [x y z] (m)
roomDim = [5 4 3];          % room dimensions [x y z] (m)
%beta = ones(6,1)*0.8;      % reflection coefficients
%beta = 0.2;                 % reverberation time (s)


alpha = roomAbsorption();
f = [125 250 500 1000 2000 4000 8000];
N = 128;
tWall = AKwallReflection(alpha, f, N, {'linear' 'linear', 'linear'}, 44100, 'min', true);
beta = fft(tWall);

S = 2*(roomDim(1)*roomDim(3)+roomDim(2)*roomDim(3)+roomDim(1)*roomDim(2));
V = roomDim(1)*roomDim(2)*roomDim(3);
% frequency wise equivalent absorption area
A = alpha * [roomDim(2)*roomDim(3); roomDim(2)*roomDim(3); ...
    roomDim(1)*roomDim(3); roomDim(1)*roomDim(3); ...
    roomDim(1)*roomDim(2); roomDim(1)*roomDim(2)];
[stochasticIR_L stochasticIR_R] = stochasticReverb(f,A,V,fs,c,false);
Tmp = mixingTime(V, S) / 1000; % mixing time in s for stochastic reverb
%%
nSamples = round(fs*Tmp);   % Number of samples depending on mixing time

%nSamples = 2000;

[brirL,brirR,rir,beta] = brirGen(c, fs, receiverPos, sourcePos, roomDim, beta, nSamples);

figure;
rir = [rir; zeros(255,1)];
AKp([brirL brirR rir],'t2d','fs',44100);

%% mix with stochastic reverb
brirL(numel(stochasticIR_L)) = 0;
brirR(numel(stochasticIR_R)) = 0;
brirL_stochastic = brirL' + stochasticIR_L.*fadeInFunction(Tmp, fs, length(stochasticIR_L));
brirR_stochastic = brirR' + stochasticIR_R.*fadeInFunction(Tmp, fs, length(stochasticIR_R));

%% conv signal with BRIR and play

[speech,speech_fs] = audioread('Sprache.wav');
speech_room(:,1) = conv(speech(:,1),  brirL_stochastic);% ./ max(abs(brirL)));
speech_room(:,2) = conv(speech(:,1), brirR_stochastic);% ./ max(abs(brirR)));
speech_room = speech_room ./ max(abs(speech_room));
p1 = audioplayer(speech, speech_fs);
   playblocking(p1);
p2 = audioplayer(speech_room, speech_fs);
    playblocking(p2);
    
    
%% conv signal with RIR and play

[speech,speech_fs] = audioread('Sprache.wav');
speech_rir(:,1) = conv(speech(:,1),  rir ./ max(abs(rir)));

%p1 = audioplayer(speech, speech_fs);
%   playblocking(p1);
p2 = audioplayer(speech_rir, speech_fs);
    playblocking(p2);

    
%%


alpha = [ones(1,6)*0.10531 ; ones(1,6)*0.16379 ; ones(1,6)*0.17137 ; ones(1,6)*0.18087];
f = [125 250 500 1000];
N = 128;
tWall = AKwallReflection(alpha, f, N, {'linear' 'linear', 'linear'}, 44100, 'min', true);