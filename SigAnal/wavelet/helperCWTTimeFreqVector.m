function scales = helperCWTTimeFreqVector(minfreq,maxfreq,f0,dt,NumVoices)
%   scales = helperCWTTimeFreqVector(minfreq,maxfreq,f0,dt,NumVoices)
%   minfreq = minimum frequency in cycles/unit time. minfreq must be
%   positive.
%   maxfreq = maximum frequency in cycles/unit time
%   f0 - center frequency of the wavelet in cycles/unit time
%   dt - sampling interval
%   NumVoices - number of voices per octave
%
%   This function helperCWTTimeFreqPlot is only in support of
%   CWTTimeFrequencyExample and PhysiologicSignalAnalysisExample. 
%   It may change in a future release.

a0 = 2^(1/NumVoices);
minscale = f0/(maxfreq*dt);
maxscale = f0/(minfreq*dt);
minscale = floor(NumVoices*log2(minscale));
maxscale = ceil(NumVoices*log2(maxscale));
scales = a0.^(minscale:maxscale).*dt;


