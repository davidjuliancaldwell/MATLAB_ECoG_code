
files = filesForSubjid('4568f4');

[sig, sta, par] = load_bcidat(files{1});
Montage = loadCorrespondingMontage(files{1});
sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, double(sig));

sig = sig(:,1:4);
bb = extractBroadband(sig, par.SamplingRate.NumericValue);

beta = extractBeta(sig, par.SamplingRate.NumericValue);