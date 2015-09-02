function keepAxesPlotted = c_Epoch_Timeseries(AxesHandle, montageElectrodeNum, plotNum, loadedData, isBadChannel, arguments )
%c_ExampleCallback Callback function used during PlotCorticalDisplay
%   This file is called once for each subplot (i.e. once for each
%   electrode). 
%      
%   AxesHandle - handle to the currently plotted axes
%   montageElectrodeNum - the index into the current montage. In the
%      example montage in Example_1, the 32nd channel in the grid is the
%      32nd electrode recorded, hence montageElectrodeNum would be 32. The
%      fifth electrode of the OF grid would be the 69th electrode in the
%      montage, thus montageElectrodeNum would be 69.  This is only as
%      accurate as the passed in montage is, so make sure the montage
%      matches the data you intend to plot!
%   plotNum - the plotNum'th plot to be drawn
%   loadedData - a struct containing all the variables from the requested 
%      data filesthat was requested. Due to the quirks of matlab's memory
%      implementation, the variables from the sub-files are stored in
%      loadedData.variables - NOTE: Do not modify this variable in any way!
%      since it is shared among all the plots, any changes to
%      loadedData.variables will propagate to subsequent callbacks
%   isBadChannel - 1 if the current channel was marked bad in the montage,
%      0 otherwise
%   arguments - Cell array containing any optional arguments that were
%         passed into PlotCorticalDisplay
%
%   Return Value: 
%      keepAxesPlotted - boolean flag (0 or 1) to note whether the axes
%         labels should be turned back on after rotations/zooms

    colors = [...
        [1 0 0];...
        [0 1 0];...
        [0 0 1];...
        [1 0 1];...
        [0 1 1];...
        [1 0 1];...
        ];
    for i=1:size(loadedData.variables.scAverages,3)
        plot(AxesHandle, loadedData.variables.scAverages(:,montageElectrodeNum,i),'color',colors(i,:),'linewidth',2);
        hold on;
    end
    plot(AxesHandle, [arguments{2} arguments{2}], arguments{3}, 'k:');
    plot(AxesHandle, [0 size(loadedData.variables.scAverages,1)], [0 0], 'k-');
    
    axis(AxesHandle,'tight');
    
    set(AxesHandle,'xtick',[]);
    set(AxesHandle,'ytick',[]);
    set(AxesHandle,'ylim',arguments{3});
    
    keepAxesPlotted = 1;
end
