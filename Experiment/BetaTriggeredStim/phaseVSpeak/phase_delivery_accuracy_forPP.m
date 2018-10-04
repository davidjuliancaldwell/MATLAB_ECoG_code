function [peakPhase,peakStd,markerSize] = phase_delivery_accuracy_forPP(r_square,threshold,phase_at_0,chans,desiredF,markerMin,markerMax,minData,maxData)
%% extract accuracy of delivery and r_square
% 8.30.2018 David.J.Caldwell

% anonymous functions to define the size of the markers based on desired
% values
marker_size_func= @(minNew,maxNew,minData,maxData,val) (maxNew-minNew)*(val-minData)/(maxData-minData)+minNew;
% threshold the data
rSquareThresh = (r_square) > threshold;
phase_at_0_screened = phase_at_0;
phase_at_0_screened(~rSquareThresh) = nan;

% calculate the peaks and widths of the kernel density estimates of the phases
[peakPhase,peakStd] = phase_kernel_density(phase_at_0_screened(:,chans),0);

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


end