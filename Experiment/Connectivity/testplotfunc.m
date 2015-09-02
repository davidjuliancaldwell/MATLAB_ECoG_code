function keepAxesPlotted = testplotfunc(AxesHandle, GridName, montageElectrodeNum, plotNum, isBadChannel)

    if isBadChannel
        plot(AxesHandle, 1,1,'color',[1 0 0],'MarkerSize',40);
    else
        plot(AxesHandle, rand(6,2), 'color',rand(3,1));
    end
    keepAxesPlotted = mod(montageElectrodeNum,2);
end