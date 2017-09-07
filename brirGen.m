function [ brirL, brirR, rir, beta ] = brirGen( c, fs, receiverPos, sourcePos, roomDim, beta, nSamples )
%%
% This function calculates the RIR of a room using a time (sample)-domain 
% image expansion method.
% The room model assumed is a rectangular enclosure with a 
% source-to-receiver impulse response, or transfer function.
% 
% INPUT:
%       c               -       acoustic velocity (m/s)
%       fs              -       sampling-rate (Hz)
%       receiverPos     -       position of the receiver in the room [x y z] (m)
%       sourcePos       -       position of the source in the room [x y z] (m)
%       roomDim         -       room dimensions [x y z] (m) 
%       beta            -       reverberation time (s) or reflection
%                               IR's for each wall [N 6], N = length of IR
%       nSamples        -       length of the RIR in samples
%
% OUTPUT:
%       rir             -       RIR of length nSamples
%       beta            -       reflection coefficients for each wall 
%                               [x1 x2 y1 y2 z1 z2]
%%

if length(beta) == 1
    beta = reverbTime2reflectionCoeff(roomDim, beta, c);
%else
%    beta = beta(:);
end

% transform input from time to sample domain
cSamples = c/fs;
receiverPos = receiverPos(:)./cSamples;
sourcePos = sourcePos(:)./cSamples;
roomDim = roomDim(:)./cSamples;
% pre-allocate output vectors
rir = zeros(nSamples,1);
brirL = zeros(nSamples + round(fs/44100 * 256) - 1,1);
brirR = zeros(nSamples + round(fs/44100 * 256) - 1,1);
% determine calculation depth
n1 = ceil(nSamples/(2*roomDim(1)));
n2 = ceil(nSamples/(2*roomDim(2)));
n3 = ceil(nSamples/(2*roomDim(3)));
% holds relative distance from source to receiver
ismPosRel = zeros(3,1);
% holds reflector coefficients
refl = zeros(length(beta),3);

for l = -n1:n1
    rX = 2*l*roomDim(1);
    for m = -n2:n2
        rY = 2*m*roomDim(2);
        for n = -n3:n3
            rZ = 2*n*roomDim(3);
            for u = 0:1
                ismPosRel(1) = (1-2*u)*sourcePos(1) + rX - receiverPos(1);
                refl(:,1) = (-beta(:,1)).^abs(u-l) .* (-beta(:,2)).^abs(l);
                for v = 0:1
                    ismPosRel(2) = (1-2*v)*sourcePos(2) + rY - receiverPos(2);
                    refl(:,2) = (-beta(:,3)).^abs(v-m) .* (-beta(:,4)).^abs(m);
                    for w = 0:1
                        ismPosRel(3) = (1-2*w)*sourcePos(3) + rZ - receiverPos(3);
                        refl(:,3) = (-beta(:,5)).^abs(w-n) .* (-beta(:,6)).^abs(n);
                        % relative source-receiver distance
                        d = norm(ismPosRel);
                        % determine gain (d*cSamples -> back to time
                        % domain)
                        a = refl(:,1) .* refl(:,2) .* refl(:,3) ./ (4*pi*d*cSamples);
                        a = ifft(a,'symmetric');
                        if(floor(d) < nSamples-128)
                            % determine azimut and elevation of source
                            [az, el, ~] = cart2sph(ismPosRel(1),...
                                                   ismPosRel(2),...
                                                   ismPosRel(3));
                            deltaPulse = zeros(nSamples,1);
                            deltaPulse(floor(d):floor(d)+127) = a;
                            % interpolate and load HRIR which matches the direction of the source
                            [hrirL, hrirR] = AKhrirInterpolation(rad2deg(az),...
                                                                rad2deg(el),...
                                                                0, 'modeled_sh');
                            % add HRIR pulse to BRIR's
                            brirL = brirL + conv(deltaPulse, hrirL);
                            brirR = brirR + conv(deltaPulse, hrirR);
                            % add pulse to RIR
                            rir(floor(d):floor(d)+127) = rir(floor(d):floor(d)+127) + a;
                        end
                    end
                end
            end
        end
    end
end

% high pass filter as proposed by Allen and Berkley to avoid non-physical
% behavior of the model at zero frequency.
% They suggest 1% of sampling freq -> 100Hz
hpFilt = designfilt('highpassiir', 'FilterOrder', 2, ...
             'PassbandFrequency', 100, 'PassbandRipple', 0.2,...
             'SampleRate', fs);
%fvtool(hpFilt) % visualize filter response
 
rir = filter(hpFilt,rir); % apply filter to rir

% normalize
rir = rir./max(abs(rir));
brirL = brirL./max(abs(brirL));
brirR = brirR./max(abs(brirR));


end

