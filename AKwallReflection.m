% tWall = AKwallReflection(alpha, f, N, extrapMode, fs, phaseType, doPlot)
% generates minimum or linear phase impulse responses from according to
% frequency dependent absorption coefficients
%
% I N P U T
% alpha       - absorption coefficients of size [F x W] where F is the
%               number of frequencies and W the number of walls
% f           - frequencies in Hz corresponding to values in alpha
% N           - desired impulse response length (default = 128)
% extrapMode  - Method for inter- and extrapolating the absorption
%               coefficients below, inside and above tha range given by f.
%               E.g. {'linear' 'linear', 'linear'} which is the default
%               performs linear interpolation in all ranges.
%               Interpolation is done on a log(f) scale.
% fs          - sampling frequency in Hz (default = 44100)
% phaseType   - 'min' or 'lin' to obtain minimum or linear phase impuse
%               repsonses (default = 'min')
% doPlot      - plot result (default = false)
%
% O U T P U T
% tWall       - impulse response of size [N x W]
%
% 2017/05 - fabian.brinkmann@tu-berlin.de

function tWall = AKwallReflection(alpha, f, N, extrapMode, fs, phaseType, doPlot)

% default values
if ~exist('N', 'var')
    N = 128;
end
if ~exist('extrap_mode', 'var')
    extrapMode = {'lin' 'lin' 'lin'};
end
if ~exist('fs', 'var')
    fs = 44100;
end
if ~exist('phaseType', 'var')
    phaseType = 'min';
end
if ~exist('doPlot', 'var')
    doPlot = false;
end

% number of channels
C = size(alpha, 2);

% design impulse responses with a minimum length of 1024 samples
if mod(N, 2)
    M = max(N, 1025);
else
    M = max(N, 1024);
end

% get bin of lowest and highest specified T values
f_lim = [ceil(f(1)/fs*M+1) floor(f(end)/fs*M+1)];

% target frequencies
f_interp = (0:fs/M:fs/2)';

% allocate space for output
tWall = zeros(numel(f_interp), C);

% get beta values
beta = sqrt(1-alpha);

for cc = 1:C
    % interpolate beta values
    tWall(f_lim(1):f_lim(2), cc) = interp1(log(f), beta(:,cc), log(f_interp(f_lim(1):f_lim(2))), extrapMode{2});
    
    % extrapolate reverberation times
    tWall(1:f_lim(1)-1, cc) = interp1(log(f), beta(:,cc), log(f_interp(1:f_lim(1)-1)), extrapMode{1}, 'extrap');
    tWall(f_lim(2)+1:end, cc) = interp1(log(f), beta(:,cc), log(f_interp(f_lim(2)+1:end)), extrapMode{3}, 'extrap');  
end

% 0 Hz will be 1 (o dB)
tWall(1,:) = 1;

% clip values
tWall = min(tWall, 1);
tWall = max(tWall, 0);

% get single sided spectra
tWall = AKsingle2bothSidedSpectrum(tWall, 1-mod(M,2));

% get zero phase IRs
tWall = ifft(tWall, 'symmetric');

% get minimum/linear phase IRs
NFFTdouble = 1;
[tWall, dev] = AKphaseManipulation(tWall, fs, phaseType, NFFTdouble, false);
while dev(1)>1 && 2^NFFTdouble * M < 2^18
    NFFTdouble = NFFTdouble + 1;
    [tWall, dev] = AKphaseManipulation(tWall, fs, phaseType, NFFTdouble, false);
end

if N < M
    if strcmpi(phaseType, 'min')
        tWall = AKfade(tWall, N, 0, 10);
    else
        if mod(N, 2)
            tWall = tWall(ceil(M/2)-floor(N/2):ceil(M/2)+floor(N/2),:);
        else
            tWall = tWall(M/2-N/2:M/2+N/2-1,:);
        end
        
        tWall = AKfade(tWall, [], 5, 5);
    end
end

% plot
if doPlot
    AKf
    for cc = 1:C
        subplot(2, C, cc)
            AKp(tWall(:,cc), 'etc2d', 'xu', 'n', 'x', [-10 N])
            title(['Wall ' num2str(cc) ': IR'])
        subplot(2, C, cc+C)
            AKp(tWall(:,cc), 'm2d', 'du', 'lin', 'dr', [0 1], 'N', fs/5)
            ylabel Magnitude
            hold on
            plot(f, beta(:,cc), 'xr')
            title(['Wall ' num2str(cc) ': Spectrum'])
    end
end