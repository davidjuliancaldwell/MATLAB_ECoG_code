ctmr_gauss_plot(cortex, trodeLocsFromMontage('fc9643', Montage, false), mean(preZs, 2), 'r', [-2 2], 1, 'recon_colormap');
title('HG Activation - Pre-Learning');
SaveFig(pwd, 'bci_ex_pre', 'png');
ctmr_gauss_plot(cortex, trodeLocsFromMontage('fc9643', Montage, false), mean(postZs, 2), 'r', [-2 2], 1, 'recon_colormap');
title('HG Activation - Post-Learning');
SaveFig(pwd, 'bci_ex_post', 'png');