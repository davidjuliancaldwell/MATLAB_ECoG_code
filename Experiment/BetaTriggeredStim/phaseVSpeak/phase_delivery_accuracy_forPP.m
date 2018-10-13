function [peakPhase,peakStd,markerSize,peakRayleightTest] = phase_delivery_accuracy_forPP(rSquare,threshold,phase_at_0,chans,desiredF,markerMin,markerMax,minData,maxData)
%% extract accuracy of delivery and r_square
% 8.30.2018 David.J.Caldwell

% anonymous functions to define the size of the markers based on desired
% values
marker_size_func= @(minNew,maxNew,minData,maxData,val) (maxNew-minNew)*(val-minData)/(maxData-minData)+minNew;
% threshold the data
rSquareThresh = (rSquare) > threshold;
phaseAt0Screened = phase_at_0;
phaseAt0Screened(~rSquareThresh) = nan;

% calculate the peaks and widths of the kernel density estimates of the phases
%[peakPhase,peakStd] =
%phase_kernel_density(phase_at_0_screened(:,chans),0); % change 10.12.2018
%to circular median and circular standard

[peakPhase,peakStd,peakRayleighTest]= phase_circstats_calc(phaseAt0screened(:,chans));

% Rayleigh test
p_alpha = circ_rtest(alpha_rad);
p_beta = circ_rtest(beta_rad);
fprintf('Rayleigh Test, \t\t P = %.2f \t%.2f\n',[p_alpha p_beta])


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