% %% collect data
% subjid = 'fc9643';
subjid = '4568f4';
% subjid = '30052b';
% subjid = '9ad250';
% subjid = '38e116';

[~, odir, hemi] = filesForSubjid(subjid);

%%

[trodes, types] = manuallyIdentifiedElectrodes(subjid);

PlotCortex(subjid, hemi);
for c = 1:length(trodes)
    tempMontage.MontageTokenized = trodes(c);
    locs = trodeLocsFromMontage(subjid, tempMontage, false);
    PlotDotsDirect(subjid, locs, types{c}, hemi, [0 7], 10, 'recon_colormap');
end

load('recon_colormap');
colormap(cm);
h = colorbar;

set(gca, 'clim', [1 7]);
set(h,'YTickLabel', {'g','b','gb','a','ag','ab','abg'});

