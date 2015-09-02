addpath ./scripts
Z_Constants;

%% do the brain plot
sid = '4568f4';

[~,hemi,~,montage,cchan] = filesForSubjid(sid);
tlocs = trodeLocsFromMontage(sid, montage, true);
tlocs(65:end,:) = [];

figure

PlotDotsDirect('tail', tlocs, ones(length(tlocs), 1),hemi, [-1 1], 10, 'recon_colormap', [], false, false);
SaveFig(OUTPUT_DIR, 'infographic_brain', 'png', '-r600');