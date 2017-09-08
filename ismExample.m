%%
amt = genpath('../../[1] amtoolbox');
addpath(amt);
clear(amt);
amtstart;

%%
clc;clear;
c = 340;                        % sound velocity (m/s)
% !always set 44.1kHz when working with FABIAN HRIR's!
fs = 44100;                     % sample frequency (samples/s) 
receiverPos = [1 2 2];          % receiver position [x y z] (m)
sourcePos = [3 3.6 2];          % source position [x y z] (m)
roomDim = [3.5 4 2];              % room dimensions [x y z] (m)
% beta = 0.2;                   % reverberation time (s)

% load a set of frequency dependant reflection coefficients
alpha = roomAbsorption();
% octave bins
f = [125 250 500 1000 2000 4000 8000];
N = 128;
% construct minimum phase wall reflection spectra
tWall = AKwallReflection(alpha, f, N, {'linear' 'linear', 'linear'}, 44100, 'min', false);
beta = fft(tWall);
% room surface
S = 2*(roomDim(1)*roomDim(3)+roomDim(2)*roomDim(3)+roomDim(1)*roomDim(2));
% room volume
V = roomDim(1)*roomDim(2)*roomDim(3);
% frequency wise equivalent absorption area
A = alpha * [roomDim(2)*roomDim(3); roomDim(2)*roomDim(3); ...
    roomDim(1)*roomDim(3); roomDim(1)*roomDim(3); ...
    roomDim(1)*roomDim(2); roomDim(1)*roomDim(2)];
% calculate stochastic reverb IR
rng(1);
[stochasticIR_L, stochasticIR_R] = stochasticReverb(f,A,V,fs,c,false);
Tmp = mixingTime(V, S) / 1000; % mixing time in s for stochastic reverb
nSamples = round(fs*Tmp);   % Number of samples depending on mixing time 
% calculate IR till mixing time (+security samples) with ISM
[brirL,brirR,rir,beta] = brirGen(c, fs, receiverPos, sourcePos, roomDim, beta, nSamples+200);
brirL = brirL(1:nSamples);
brirR = brirR(1:nSamples);
rir = rir(1:nSamples);

%  figure;
%  rir(numel(brirL)) = 0;
%  AKp([brirL brirR rir],'t2d','fs',fs);
%  legend('BRIR left', 'BRIR right', 'RIR');

% mix with stochastic reverb
% onset
onsL = AKonsetDetect(brirL);
onsR = AKonsetDetect(brirR);
% add zeros to adjust to initial time gap
stochasticIR_L = [zeros(1,round(onsL-AKonsetDetect(stochasticIR_L'))) stochasticIR_L];
stochasticIR_R = [zeros(1,round(onsR-AKonsetDetect(stochasticIR_R'))) stochasticIR_R];
% make same length
if length(stochasticIR_L) > length(stochasticIR_R)
    stochasticIR_R(numel(stochasticIR_L)) = 0;
else
    stochasticIR_L(numel(stochasticIR_R)) = 0;
end
brirL(numel(stochasticIR_L)) = 0;
brirR(numel(stochasticIR_R)) = 0;
% mix 
mixMode = 'var1';
brirL_stochastic = brirL' + stochasticIR_L.* ...
    fadeInFunction(Tmp, fs, onsL, stochasticIR_L, mixMode);
brirR_stochastic = brirR' + stochasticIR_R.* ...
    fadeInFunction(Tmp, fs, onsR, stochasticIR_R, mixMode);

figure;
AKp([brirL (stochasticIR_L.*fadeInFunction(Tmp, fs, onsL, stochasticIR_L, mixMode))'],'t2d','fs',fs);
legend('BRIR left ISM', 'BRIR left stochastic');

% conv signal with BRIR and play
load('HpTFgenFilter.mat');
[speech,speech_fs] = audioread('Sprache.wav');
speech_room(:,1) = conv(speech(:,1),  brirL_stochastic);
speech_room(:,2) = conv(speech(:,1), brirR_stochastic);
speech_room = speech_room ./ max(abs(speech_room));
speech_room_HpFilter(:,1) = conv(speech_room(:,1), HpTFgenFilter);
speech_room_HpFilter(:,2) = conv(speech_room(:,2), HpTFgenFilter);
% p1 = audioplayer(speech, speech_fs);
%    playblocking(p1);
% p2 = audioplayer(speech_room_HpFilter, speech_fs);
%     playblocking(p2);

% save to workspace
audiowrite('speech_var1_smallRoom.wav',speech_room,fs); 



%% conv signal with RIR and play

[speech,speech_fs] = audioread('Sprache.wav');
speech_rir(:,1) = conv(speech(:,1),  rir ./ max(abs(rir)));

%p1 = audioplayer(speech, speech_fs);
%   playblocking(p1);
p2 = audioplayer(speech_rir, speech_fs);
    playblocking(p2);

    