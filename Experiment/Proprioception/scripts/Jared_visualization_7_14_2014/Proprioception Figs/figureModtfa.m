%% Formatting TFA plots

set(gcf, 'units', 'inches', 'pos', [0 0 9 6.5]) %sets to size of ppt slide
% turn on color bar manually on plot first
set (gca, 'CLim', [-6,6])
% gca stands for "get current axis' and gcf stands for "get current figure"

%set_colormap_threshold(gcf, [-3.5 3.5], [-5 5], [1 1 1]) % this doesn't
%seem to set the color axis on the brain plots properly

vline(0, 'b', 'Movement Detected')
vline(-0.4, 'r:', 'Earliest Movement')
hline (70, 'b', 'High-Gamma Cutoff')

ylabel (colorbar, 'Wavelet Coefficient', 'FontSize', 20)
ylabel('Frequency (Hz)', 'FontSize', 20)
xlabel('Time (sec)', 'FontSize', 20)
set (gca, 'FontSize', 18)
set(gcf, 'Color',[1 1 1])



%% cortical plots
% consider running cortical plots as high resolution for presentations and
% posters

% TODO- set background to white (or clear?)
set(gcf, 'units', 'inches', 'pos', [0 0 9 6.5]) %sets to size of ppt slide
ylabel(colorbar, 'RSA', 'FontSize', 20)
title('Subject 1- High gamma response for self-paced movement', 'FontSize',24);
set(gcf, 'Color',[1 1 1])
%set(colorbar, 'FontSize', 14) %this seems to delete the colorbar title
%when used.

% modify view: to update this, go to the image and make it look the way you
% want, then generate code and pull settings from there.
set(gca,...
    'CameraViewAngle',6.3132544146009,...
    'CameraUpVector',[0 0 1],...
    'CameraTarget',[-28.8446817542035 -1.16590633980141 40.9199405424052],...
    'CameraPosition',[-1108.24963887626 -94.2991453772259 129.954418071827]);
    %'PlotBoxAspectRatio',[1 2.39377009957425 1.54259675967232],...


%% Bar chart mods for powerpoint

set(gcf, 'units', 'inches', 'pos', [0 0 9 6.5]) %sets to size of ppt slide
set(gcf, 'Color',[1 1 1])



%% Exporting figures
% may be best to export the figures using the "export settings" GUI since there seem to be
% other options such as minimum font sizes, etc.
set(gcf,'PaperPosition', 'auto') 
print(gcf, '-djpg', '-r300', 'figurename')

% options
% -djpeg
% -dpng
% -dtiff or dtiffn
% -depsc or depsc2
% -dbmp
% -demf (windows only)
