function out = NotchFilter(signal, freq, fs) 
%NotchFilter - Tim's notch filter
%   outSignal = NotchFilter(freqs, fs, signal, width)
%   VAR                                         EX
%   freqs = vector of frequencies to notch      [60 120 180]
%   fs = sampling rate                          1000
%   signal = input signal                       [1 2 3 4 5 ....]

for freqToNotch=freq;
%     fprintf('Notching %i Hz\n', freqToNotch);
    wo = freqToNotch/(fs/2);  bw = wo/45;
    [b,a] = iirnotch(wo,bw);  
    signal = filtfilt(b, a, signal);
end

out = signal;