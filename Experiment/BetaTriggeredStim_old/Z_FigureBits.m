Z_Constants;

%% make the raw / beta figures
[sig, sta, par] = load_bcidat('D:\research\subjects\0dd118\data\d5\0dd118_mot_t_h001\0dd118_mot_t_hS001R01.dat');

figure
plot(highpass(double(sig(:,55)),1,1200,4),'linew',2,'color',[0 0 .5])
% ylim([-17.7575   17.8845]);
xlim(1e4*[3.2784    3.6030]);
set(gcf,'pos',[35         474        1856         504]);
axis off;
SaveFig(OUTPUT_DIR, 'ex_fs','eps','-r600');

figure;
plot(bandpass(double(sig(:,55)), 20, 26, 1200, 4),'linew',2,'color',[0 0 .5]);
ylim([-17.7575   17.8845]);
xlim(1e4*[3.2784    3.6030]);
set(gcf,'pos',[35         474        1856         504]);
axis off;
SaveFig(OUTPUT_DIR, 'ex_beta','eps','-r600');

%% plot the brain
load(fullfile(getSubjDir('d5cd55'), 'trodes.mat'));
PlotDotsDirect('d5cd55', Grid([62 54 61 60], :), NaN*ones(4,1), 'l', [0 1], 10, 'recon_colormap', [], false);

view(270,0);
SaveFig(OUTPUT_DIR, 'ex_brain','png','-r600');