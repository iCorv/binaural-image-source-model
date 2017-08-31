function [ resynthesized_impulseL, resynthesized_impulseR ] = stochasticReverb(fBins, A, V, fs, c, plotFlag )

% max reverberation time (frequency dependant)
T = max(0.161 .* V./A);
% get analyzer and synthesizer object and center frequencies
[ analyzer, synthesizer, fc ] = reconstructingFilterbank( fs );
% make white noise
whiteNoiseL = noise(round(T*fs),1);
whiteNoiseR = noise(round(T*fs),1);
% Filter signal
[analyzed_impulseL, analyzer] = gfb_analyzer_process(analyzer, whiteNoiseL);
[analyzed_impulseR, analyzer] = gfb_analyzer_process(analyzer, whiteNoiseR);

for i = 1:length(fc)
    % linear interpolate A. If outside of intervall, extrapolate linear
    A_interp = interp1(fBins, A, fc(i),'linear','extrap');
    % the time, speed of sound, and room properties that are contained in
    delta = c*A_interp/(8*V);
    % time vector
    t = linspace(0,T,length(whiteNoiseL));
    % decay of the RIR
    decay = exp(-delta.*t);
    analyzed_impulseL(i,:) =  analyzed_impulseL(i,:) .* decay;
    analyzed_impulseR(i,:) =  analyzed_impulseR(i,:) .* decay;
end

% ---- coherence of binaural signals in a diffuse sound field ----
% ear distance of 31.2cm
w0 = 2*pi*550;
% model the decreasing coherence for higher frequency due to the scattering
w1 = 2*pi*2700;
w = (2*pi).*fc;
% coherence of two signals in the case of a head that is introduced as a 
% scattering object to the diffuse sound field
gamma = sin(pi .* w ./ w0)./(pi.*w./w0) .* max(0,1-w./w1);
H_beta = zeros(size(gamma));
for i = 1:length(gamma)
    if gamma(i) >= 0
        H_beta(i) = sqrt(0.5*(1-sqrt(1-gamma(i)^2)));
    else
        H_beta(i) = -sqrt(0.5*(1-sqrt(1-gamma(i)^2)));
    end
end
H_alpha = sqrt(1-H_beta.^2);

% apply binaural coherence to the two independent noise processes
analyzed_impulseL_gamma = H_alpha' .* analyzed_impulseL + H_beta' .* analyzed_impulseR;
analyzed_impulseR_gamma = H_alpha' .* analyzed_impulseR + H_beta' .* analyzed_impulseL;

% Resynthesize filtered impulse response from above.
[resynthesized_impulseL, synthesizer] = gfb_synthesizer_process(synthesizer, analyzed_impulseL_gamma);
[resynthesized_impulseR, synthesizer] = gfb_synthesizer_process(synthesizer, analyzed_impulseR_gamma);



 
if(plotFlag)
    AKf
    subplot(2,1,1)
     AKp(real(analyzed_impulseL)', 'm2d', 'c', 'cyc', 'fs', fs)
     title('AMT filterbank (magnitude response)')
    subplot(2,1,2)
     AKp(resynthesized_impulse', 'm2d', 'c', 'cyc', 'fs', fs, 'dr', 20)
     title('AMT filterbank after summation (magnitude response)')
end
end

