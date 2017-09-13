function [ analyzer, synthesizer, fc ] = reconstructingFilterbank( fs )


flow = 100;                   % Lowest center frequency in Hz;
basef = 1000;               % Base center frequency in Hz;
fhigh = fs/2;               % Highest center frequency in Hz;
filters_per_ERBaud = 2;     % Filterband density on ERB scale;
filter_order = 4;           % Filter order;
bw_factor = 1.0;            % Bandwidth factor;
desired_delay = 0.004;      % Desired delay in seconds;
 

% Construct new analyzer object;
analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,filter_order,bw_factor);
% Build synthesizer for an analysis-synthesis delay of desired_delay in seconds.
synthesizer = gfb_synthesizer_new(analyzer, desired_delay);
% get the center frequencies
fc = analyzer.center_frequencies_hz;


end

