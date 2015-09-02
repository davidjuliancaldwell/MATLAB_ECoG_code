%% carr (common-average re-reference)

function [sig] = carr (par, sig, Montage)

fs = par.SamplingRate.NumericValue;
% common average re-reference.  Make sure to split up the gugers by
% amplifier bank using the function GugerizeMontage
if (mod(fs, 1200) == 0)
    sig = ReferenceCAR(GugerizeMontage(Montage.Montage), Montage.BadChannels, sig);
else
    sig = ReferenceCAR(Montage.Montage, Montage.BadChannels, sig);
end
