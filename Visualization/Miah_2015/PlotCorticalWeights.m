function PlotCorticalWeights(patientID, Montage, weights, label)

load(['C:\Research\Data\Patients\' patientID '\trodes.mat']);
load(['C:\Research\Data\Patients\' patientID '\surf\' patientID '_cortex.mat']);

ctmr_gauss_plot(cortex,Montage,weights,'r');
colorbar;

% set(gcf,'units','normalized')
% set(gcf,'position',[0 0.25 0.75 0.75]);
% set(gcf,'units','pixels')
% set(gcf,'PaperPositionMode','auto')
% SaveFig([patientID '\ScreeningCorticalRSA'],[ patientID ' (R) 1D ' label]);
% close all;
% 
% 
% ctmr_gauss_plot(cortex,Montage,weights,'l');
% colorbar;
% 
% set(gcf,'units','normalized')
% set(gcf,'position',[0 0.25 0.75 0.75]);
% set(gcf,'units','pixels')
% set(gcf,'PaperPositionMode','auto')
% SaveFig([patientID '\ScreeningCorticalRSA'],[ patientID ' (l) 1D ' label]);
% close all;