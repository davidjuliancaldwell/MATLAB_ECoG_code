function [a,b] = makeFIR(centerFrequency, plusMinus, Fs)
% All frequency values are in Hz.

Fpass1 = centerFrequency-plusMinus;              % First Passband Frequency
Fpass2 = centerFrequency+plusMinus;             % Second Passband Frequency

Fstop1 = Fpass1-6;              % First Stopband Frequency
Fstop2 = Fpass2+6;             % Second Stopband Frequency

Dstop1 = 0.001;           % First Stopband Attenuation
Dpass  = 0.057501127785;  % Passband Ripple
Dstop2 = 0.0001;          % Second Stopband Attenuation
dens   = 20;              % Density Factor

% Calculate the order from the parameters using FIRPMORD.
[N, Fo, Ao, W] = firpmord([Fstop1 Fpass1 Fpass2 Fstop2]/(Fs/2), [0 1 ...
                          0], [Dstop1 Dpass Dstop2]);

% Calculate the coefficients using the FIRPM function.
b  = firpm(N, Fo, Ao, W, {dens});
Hd = dfilt.dffir(b);

b = 1;
a = Hd.Numerator;

% [EOF]
