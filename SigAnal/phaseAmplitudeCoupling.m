% function [blah...] = phaseAmplitudeCoupling(blah...)

fname = 'd:\research\subjects\fc9643\data\d1\fc9643_mot_t_h001\fc9643_mot_t_hS001R01.dat';
mname = strrep(fname, '.dat', '_montage.mat');
[sig, sta, par] = load_bcidat(fname);
load(mname);

sig = double(sig);
sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);

%%
phaseChans = [20 21 28 29];
ampChans = [15 16 24];
chans = union(phaseChans, ampChans);

[eStarts, eEnds] = getEpochs(sta.StimulusCode, 1, true);
epochs = getEpochSignal(sig, eStarts, eEnds);

for c = 1:length(chans)    
    [~, ~, coeffs] = time_frequency_wavelet(epochs(:, chans(c), :), 1:200, 1000, 1, 1, 'CPUtest');
    
end
    %%
temp = exp(lowpass(log(hilbAmp(sig(:, 24), [70 110], 1000).^2), 1, fs, 4));
figure, plot(temp);
hold on;
plot(double(sta.StimulusCode)*1e10, 'r');