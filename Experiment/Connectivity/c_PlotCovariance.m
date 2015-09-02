function keepAxesPlotted = c_PlotCovariance(AxesHandle, montageElectrodeNum, plotNum, loadedData, isBadChannel, arguments )
    
    if montageElectrodeNum > arguments{1}
        imagesc(loadedData.variables.allPlots(:,:,montageElectrodeNum-1));
    else
        imagesc(loadedData.variables.allPlots(:,:,montageElectrodeNum));
    end
    
    set_colormap_threshold(AxesHandle, arguments{2}*.2, arguments{2}, [1 1 1]);
    
    keepAxesPlotted = 0;
end

