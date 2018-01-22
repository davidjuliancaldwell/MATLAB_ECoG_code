function keepAxesPlotted = c_TutorialCallback(AxesHandle, montageElectrodeNum, plotNum, loadedData, isBadChannel, arguments )
    if (ismember(montageElectrodeNum, arguments{:}))
        plot(AxesHandle, loadedData.variables.somedata(:,montageElectrodeNum));
    end
%     axis tight;
    keepAxesPlotted = 0;
end