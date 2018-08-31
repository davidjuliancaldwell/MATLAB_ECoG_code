function [] = plot_phase_cortex(r_square,threshold,phase_at_0,signalType,desiredF,markerMin,markerMax,minData,maxData,sid,subjectNum,locs,chans,stims,betaChan)
%% plot the distribution of phases on each cortical surface
% 8.30.2018 David.J.Caldwell

% anonymous functions to define the size of the markers based on desired
% values
marker_size_func= @(minNew,maxNew,minData,maxData,val) (maxNew-minNew)*(val-minData)/(maxData-minData)+minNew;

figure
% threshold the data
rSquareThresh = (r_square) > threshold;
phase_at_0_screened = phase_at_0;
phase_at_0_screened(~rSquareThresh) = nan;

% calculate the peaks and widths of the kernel density estimates of the phases
[peakPhase,peakStd] = phase_kernel_density(phase_at_0_screened(:,chans),0);

% calculate the weights based off of the desired frequency, as well as the
% direction in which the frequency was off
weights = calculate_direction_shift(desiredF,peakPhase).*theta_min_func(desiredF,peakPhase);

% set defaults, if wanting to use the data to set things leave these as []
% when calling the function
if (~exist('minData','var') || isempty(minData))
    minData = max(peakStd);
end

if (~exist('maxData','var') || isempty(maxData))
    maxData = min(peakStd);
end

% define marker size
markerSize = marker_size_func(markerMin,markerMax,minData,maxData,peakStd);
markerSize(isnan(markerSize)) = markerMin;

% plot the dots
PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
    [-max(abs(weights)) max(abs(weights))], markerSize,'america',[],false,false)
% needs to be the same as what was used in the function call above
load('america'); 
colormap(cm);
cbar = colorbar;
cbar.Label.String = 'difference in degrees from desired frequency';

title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],...
    ['from desired frequency of ' num2str(desiredF(1)) char(176) ]})

% make legend for size of circles
[minChanVal,minChanIndex] = max(peakStd);
[maxChanVal,maxChanIndex] = min(peakStd);

PlotDotsDirect(sid, locs(chans(minChanIndex),:), weights(minChanIndex), 'b',...
    [-max(abs(weights)) max(abs(weights))], markerSize(minChanIndex),'america',[],false,true)
PlotDotsDirect(sid, locs(chans(maxChanIndex),:), weights(maxChanIndex), 'b',...
    [-max(abs(weights)) max(abs(weights))], markerSize(maxChanIndex),'america',[],false,true)

% plot stimulation channels
stimulationPlot = PlotBrainJustDots(sid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);

% plot beta channel overlaid
betaChanPlot = PlotBrainJustDots(sid,{betaChan},[106,61,154]/255,true,50);

plotObj = gcf;
objhl = findobj(plotObj, 'type', 'line'); % objects of legend of type patch
%leg = legend([objhl(minChanIndex) objhl(maxChanIndex)],{['distribution width = ' num2str(minChanVal)],['distribution width = ' num2str(maxChanVal)]});
leg = legend([objhl(1),objhl(2),stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
    {['distribution width = ' num2str(maxChanVal)],...
    ['distribution width = ' num2str(minChanVal)],...
    ['stimulation channel'],['stimulation channel'],...
    ['beta recording channel = ' num2str(betaChan)]});

set(gca,'fontsize',14)

end