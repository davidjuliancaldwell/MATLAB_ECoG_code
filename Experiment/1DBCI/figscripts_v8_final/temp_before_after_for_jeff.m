PlotGaussDirect('fc9643', trodeLocsFromMontage('fc9643', Montage, false), mean(preZs, 2), 'r', [-2 2], 'recon_colormap');
title('HG Activity - Pre-Learning');
colorbarLabel(colorbar, 'Normalized Activity');
SaveFig(pwd, 'bci_ex_pre', 'png', '-r600');
clf
PlotGaussDirect('fc9643', trodeLocsFromMontage('fc9643', Montage, false), mean(postZs, 2), 'r', [-2 2], 'recon_colormap');
title('HG Activity - Post-learning');
colorbarLabel(colorbar, 'Normalized Activity');
SaveFig(pwd, 'bci_ex_post', 'png', '-r600');

%% this has to be run after running fig_4_...
% at least until the point that allprezs and allpostzs are populated, this
% should be the first for loop

locs = projectToHemisphere(allrsas_locs, 'r');
figure
PlotGaussDirect('tail',locs, allprezs, 'r', [-2 2], 'recon_colormap');
colorbarLabel(colorbar, 'Normalized Activity');
title('HG Activity - Pre-learning');
SaveFig(pwd, 'bci_all_pre', 'png', '-r600');

figure
PlotGaussDirect('tail',locs, allpostzs, 'r', [-2 2], 'recon_colormap');
colorbarLabel(colorbar, 'Normalized Activity');
title('HG Activity - Post-learning');
SaveFig(pwd, 'bci_all_post', 'png', '-r600');