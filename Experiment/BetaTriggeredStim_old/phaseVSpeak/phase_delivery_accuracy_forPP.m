function [peakPhase,peakStd,peakLength,circularTest,markerSize] = phase_delivery_accuracy_forPP(rSquare,threshold,phaseAt0,chans,desiredF,markerMin,markerMax,minData,maxData,metricToUse,testStatistic,f,fThresholdMin,fThresholdMax)
%% extract accuracy of delivery and r_square
% 8.30.2018 David.J.Caldwell

% anonymous functions to define the size of the markers based on desired
% values
marker_size_func= @(minNew,maxNew,minData,maxData,val) (maxNew-minNew)*(val-minData)/(maxData-minData)+minNew;
% threshold the data
rSquareThresh = (rSquare) > threshold & f<fThresholdMax & f>fThresholdMin;
phaseAt0Screened = phaseAt0;
phaseAt0Screened(~rSquareThresh) = nan;

% calculate the peaks and widths of the kernel density estimates of the phases
%[peakPhase,peakStd] =
%phase_kernel_density(phase_at_0_screened(:,chans),0); % change 10.12.2018
%to circular median and circular standard

[peakPhase,peakStd,peakLength,circularTest]= phase_circstats_calc(phaseAt0Screened(:,chans),'testStatistic',testStatistic);

peakPhase = rad2deg(peakPhase);
peakStd = rad2deg(peakStd);

switch metricToUse
    case 'std'
        markerUse = peakStd;
        
        % set defaults, if wanting to use the data to set things leave these as []
        % when calling the function
        if (~exist('minData','var') || isempty(minData))
            minData = max(markerUse);
        end
        
        if (~exist('maxData','var') || isempty(maxData))
            maxData = min(markerUse);
            
        end
    case 'vecLength'
        markerUse = peakLength;
        
        % set defaults, if wanting to use the data to set things leave these as []
        % when calling the function
        if (~exist('minData','var') || isempty(minData))
            minData = min(markerUse);
        end
        
        if (~exist('maxData','var') || isempty(maxData))
            maxData = max(markerUse);
        end
        
    otherwise
        markerUse = peakLength;
        
        % set defaults, if wanting to use the data to set things leave these as []
        % when calling the function
        if (~exist('minData','var') || isempty(minData))
            minData = min(markerUse);
        end
        
        if (~exist('maxData','var') || isempty(maxData))
            maxData = max(markerUse);
        end
end

% define marker size
markerSize = marker_size_func(markerMin,markerMax,minData,maxData,markerUse);
markerSize(isnan(markerSize)) = markerMin;


end