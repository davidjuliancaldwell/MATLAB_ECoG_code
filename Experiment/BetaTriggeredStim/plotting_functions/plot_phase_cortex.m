function [] = plot_phase_cortex(rSquare,threshold,phaseAt0,signalType,desiredF,markerMin,markerMax,minData,maxData,sid,subjectNum,locs,chans,stims,betaChan,typePlot,metricToUse,testStatistic,f,fThresholdMin,fThresholdMax)
%% plot the distribution of phases on each cortical surface
% 8.30.2018 David.J.Caldwell

% define colormap

% anonymous functions to define the size of the markers based on desired
% values
marker_size_func= @(minNew,maxNew,minData,maxData,val) (maxNew-minNew)*(val-minData)/(maxData-minData)+minNew;

% threshold the data
rSquareThresh = (rSquare) > threshold & f>fThresholdMin & f<fThresholdMax;
phaseAt0screened = phaseAt0;
phaseAt0screened(~rSquareThresh) = nan;

[peakPhase,peakStd,peakLength,circularTest]= phase_circstats_calc(phaseAt0screened(:,chans),'testStatistic',testStatistic);

% calculate the peaks and widths of the kernel density estimates of the phases
%[peakPhase,peakStd] = phase_kernel_density(phaseAt0screened(:,chans),0);
peakStd = rad2deg(peakStd);

% calculate the weights based off of the desired frequency, as well as the
% direction in which the frequency was off

switch typePlot
    case 'value'
        weights = phasewrap(peakPhase);
        cmap = phasemap;
        
    case 'magDiff'
        peakPhase = rad2deg(peakPhase);
        weights = theta_min_func(desiredF,peakPhase);
        cmap = flipud(cbrewer('seq','PuRd',40));
        
    case 'direcDiff'
        peakPhase = rad2deg(peakPhase);
        weights = calculate_direction_shift(desiredF,peakPhase).*theta_min_func(desiredF,peakPhase);
        cmap = flipud(cbrewer('seq','PuRd',40));
        
end

switch metricToUse
    case 'std'
        markerUse = peakStd;
        % set defaults, if wanting to use the data to set things leave these as []
        % when calling the function
        if (~exist('minData','var') || isempty(minData))
            minData = max(peakStd);
        end
        
        if (~exist('maxData','var') || isempty(maxData))
            maxData = min(peakStd);
        end
        
        % make legend for size of circles
        [minChanVal,minChanIndex] = max(markerUse);
        [maxChanVal,maxChanIndex] = min(markerUse);
        
        
    case 'vecLength'
        markerUse = peakLength;
        
        if (~exist('minData','var') || isempty(minData))
            minData = min(markerUse);
        end
        
        if (~exist('maxData','var') || isempty(maxData))
            maxData = max(markerUse);
        end
        
        % make legend for size of circles
        [minChanVal,minChanIndex] = min(markerUse);
        [maxChanVal,maxChanIndex] = max(markerUse);
        
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
        
        [minChanVal,minChanIndex] = min(markerUse);
        [maxChanVal,maxChanIndex] = max(markerUse);
        
end

% set defaults, if wanting to use the data to set things leave these as []
% when calling the function


% define marker size
markerSize = marker_size_func(markerMin,markerMax,minData,maxData,markerUse);
markerSize(isnan(markerSize)) = markerMin;

% plot the dots

figure

switch typePlot
    case 'value'
        PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
            [-pi pi], markerSize,cmap,[],false,false)
        title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation phase delivery '],...
            ['for desired phase of ' num2str(desiredF(1)) char(176) ]})
        phasemap()
        phasebar('location','nw','deg')
        
    case 'magDiff'
        PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
            [0 180], markerSize,cmap,[],false,false)
        colormap(cmap);
        cbar = colorbar;
        cbar.Label.String = 'difference in degrees from desired phase';
        
        title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],...
            ['from desired phase of ' num2str(desiredF(1)) char(176) ]})
    case 'direcDiff'
        PlotDotsDirect(sid, locs(chans,:), weights, 'b',...
            [-max(abs(weights)) max(abs(weights))], markerSize,cmap,[],false,false)
        colormap(cmap);
        cbar = colorbar;
        cbar.Label.String = 'difference in degrees from desired phase';
        
        title({['Subject ' num2str(subjectNum) ' '  signalType ' signal stimulation delivery difference'],...
            ['from desired phase of ' num2str(desiredF(1)) char(176) ]})
end




switch typePlot
    case 'value'
        PlotDotsDirect(sid, locs(chans(minChanIndex),:), weights(minChanIndex), 'b',...
            [-pi pi], markerSize(minChanIndex),cmap,[],false,true)
        
        PlotDotsDirect(sid, locs(chans(maxChanIndex),:), weights(maxChanIndex), 'b',...
            [-pi pi], markerSize(maxChanIndex),cmap,[],false,true)
        % plot stimulation channels
        stimulationPlot = PlotBrainJustDots(sid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);
        
        % plot beta channel overlaid
        betaChanPlot = PlotBrainJustDots(sid,{betaChan},[1 1 0],true,50);
        plotObj = gcf;
        objhl = findobj(plotObj, 'type', 'line'); % objects of legend of type patch
        %leg = legend([objhl(minChanIndex) objhl(maxChanIndex)],{['distribution width = ' num2str(minChanVal)],['distribution width = ' num2str(maxChanVal)]});
        leg = legend([objhl(3),objhl(4),stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
            {['best fit' ],...
            ['worst fit '],...
            ['stimulation channel'],['stimulation channel'],...
            ['trigger channel = ' num2str(betaChan)]});
        
    case 'magDiff'
        PlotDotsDirect(sid, locs(chans(minChanIndex),:), weights(minChanIndex), 'b',...
            [0 180], markerSize(minChanIndex),cmap,[],false,true)
        PlotDotsDirect(sid, locs(chans(maxChanIndex),:), weights(maxChanIndex), 'b',...
            [0 180], markerSize(maxChanIndex),cmap,[],false,true)
        % plot stimulation channels
        stimulationPlot = PlotBrainJustDots(sid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);
        
        % plot beta channel overlaid
        betaChanPlot = PlotBrainJustDots(sid,{betaChan},[1 1 0],true,50);
        plotObj = gcf;
        objhl = findobj(plotObj, 'type', 'line'); % objects of legend of type patch
        %leg = legend([objhl(minChanIndex) objhl(maxChanIndex)],{['distribution width = ' num2str(minChanVal)],['distribution width = ' num2str(maxChanVal)]});
        leg = legend([objhl(1),objhl(2),stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
            {['best fit' ],...
            ['worst fit '],...
            ['stimulation channel'],['stimulation channel'],...
            ['trigger channel = ' num2str(betaChan)]});
        
        %             {['best fit = ' num2str(maxChanVal)],...
        %             ['worst fit = ' num2str(minChanVal)],...
        %             ['stimulation channel'],['stimulation channel'],...
        %             ['beta recording channel = ' num2str(betaChan)]});
    case 'direcDiff'
        PlotDotsDirect(sid, locs(chans(minChanIndex),:), weights(minChanIndex), 'b',...
            [-max(abs(weights)) max(abs(weights))], markerSize(minChanIndex),cmap,[],false,true)
        PlotDotsDirect(sid, locs(chans(maxChanIndex),:), weights(maxChanIndex), 'b',...
            [-max(abs(weights)) max(abs(weights))], markerSize(maxChanIndex),cmap,[],false,true)
        % plot stimulation channels
        stimulationPlot = PlotBrainJustDots(sid,{stims(1),stims(2)},[0 0 0; 0 0 0],true);
        
        % plot beta channel overlaid
        betaChanPlot = PlotBrainJustDots(sid,{betaChan},[1 1 1],true,50);
        plotObj = gcf;
        objhl = findobj(plotObj, 'type', 'line'); % objects of legend of type patch
        %leg = legend([objhl(minChanIndex) objhl(maxChanIndex)],{['distribution width = ' num2str(minChanVal)],['distribution width = ' num2str(maxChanVal)]});
        leg = legend([objhl(1),objhl(2),stimulationPlot(1),stimulationPlot(2),betaChanPlot],...
            {['best fit' ],...
            ['worst fit '],...
            ['stimulation channel'],['stimulation channel'],...
            ['trigger channel = ' num2str(betaChan)]});
end

set(gca,'fontsize',14)

end