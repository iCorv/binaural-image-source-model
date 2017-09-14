function [ brirL_stochastic, brirR_stochastic ] = mixModels( brirL, brirR, stochasticIR_L, stochasticIR_R, fs, mixingTime, mixMode )
%
%   mix ISM with diffuse reverberation using differen fade-in variations.
%

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
% calculate factor to adjust the amplitude of stochastic reverb 
edcIsmL = AKedc(brirL,0);
edcStochL = AKedc(stochasticIR_L',0);
% use first value of edc since stochastic reverb already has natural room decay applied
energyFactorL = edcIsmL(1)/edcStochL(1);
edcIsmR = AKedc(brirR,0);
edcStochR = AKedc(stochasticIR_R',0);
energyFactorR = edcIsmR(1)/edcStochR(1);

% mix with fade in function
brirL_stochastic = brirL' + stochasticIR_L.* ...
    (fadeInFunction(mixingTime, fs, onsL, stochasticIR_L, mixMode).*energyFactorL);
brirR_stochastic = brirR' + stochasticIR_R.* ...
    (fadeInFunction(mixingTime, fs, onsR, stochasticIR_R, mixMode).*energyFactorR);

%AKf(8.89,7);
figure;
AKp([brirL (stochasticIR_L.*(fadeInFunction(mixingTime, fs, onsL, stochasticIR_L, mixMode).*energyFactorL))'],'t2d','fs',fs,'x',[0 100],'labeling','on');
%hold on;
%ylabel('amplitude','FontSize',9,'Interpreter','latex');
%xlabel('time in ms','FontSize',9,'Interpreter','latex');
%ax = gca;
%ax.FontSize = 9;
%ax.TickLabelInterpreter = 'latex';
legend({'image source model', 'stochastic reverberation'},'FontSize',12,'Interpreter','none');

end

