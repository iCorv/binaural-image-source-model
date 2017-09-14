%% load amtoolbox
% AKtoolbox has to be loaded manually if not permanently on matlab path!
% change path accordingly
amt = genpath('../../[1] amtoolbox');
addpath(amt);
clear(amt);
amtstart;

%% initialise model parameters
clc; clear;
c = 340;                                            % sound velocity (m/s)
% !always set 44.1kHz when working with FABIAN HRIR's!
fs = 44100;                                         % sample frequency (samples/s) 
% small room [5 3 3], medium room [6 5 3], big room [10 6 3]
roomDim = [5 3 3];                                  % room dimensions [x y z] (m)
receiverPos = [roomDim(1)/4, roomDim(2)/3, 1.8];    % receiver position [x y z] (m)
sourcePos = [receiverPos(1)+2 receiverPos(2) 1.8];  % source position [x y z] (m)

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

%% calculate stochastic reverb IR
rng(1); % gives same random numbers per matlab-start since we want to compare different fade-ins
[stochasticIR_L, stochasticIR_R] = stochasticReverb(f,A,V,fs,c,false);

%% calculate IR till mixing time (+security samples) with ISM
mixingTime = mixingTime(V, S) / 1000; % mixing time in s for stochastic reverb
nSamples = round(fs*mixingTime);   % Number of samples depending on mixing time 
[brirL,brirR,rir,beta] = brirGen(c, fs, receiverPos, sourcePos, roomDim, beta, nSamples+200);
brirL = brirL(1:nSamples);
brirR = brirR(1:nSamples);
rir = rir(1:nSamples);
% plot ISM output
figure;
rir(numel(brirL)) = 0;
AKp([brirL brirR rir],'t2d','fs',fs);
legend('BRIR left', 'BRIR right', 'RIR');

%% mix modells together
mode = 'var6';
[brirL_stochastic, brirR_stochastic] = mixModels(brirL, brirR, ...
                      stochasticIR_L,stochasticIR_R, fs, mixingTime, mode);

%% conv signal with BRIR and play
load('HpTFgenFilter.mat'); % generic headphone filter
[speech,speech_fs] = audioread('dry_audio/Sprache.wav');
speech_room(:,1) = conv(speech(:,1),  brirL_stochastic);
speech_room(:,2) = conv(speech(:,1), brirR_stochastic);
speech_room = speech_room ./ max(abs(speech_room));
speech_room_HpFilter(:,1) = conv(speech_room(:,1), HpTFgenFilter);
speech_room_HpFilter(:,2) = conv(speech_room(:,2), HpTFgenFilter);
p1 = audioplayer(speech, speech_fs);
     playblocking(p1);
p2 = audioplayer(speech_room_HpFilter, speech_fs);
     playblocking(p2);

%% save to workspace
audiowrite(['stimuli/smallRoom_' mode '.wav'],speech_room,fs); 
% audiowrite(['stimuli/mediumRoom_' mode '.wav'],speech_room,fs); 
% audiowrite(['stimuli/bigRoom_' mode '.wav'],speech_room,fs); 

%% conv signal with RIR and play
[speech,speech_fs] = audioread('Sprache.wav');
speech_rir(:,1) = conv(speech(:,1),  rir ./ max(abs(rir)));
%p1 = audioplayer(speech, speech_fs);
%   playblocking(p1);
p2 = audioplayer(speech_rir, speech_fs);
     playblocking(p2);

    