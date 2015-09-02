function ax = D_PlotTimeSeries_SubPlot(t, mdata, a, b, names)
    ax = plot(t, mdata(a, :), 'color', [1 .5 .5]);
    legendOff(ax);
    hold on;
    ax = plot(t, mdata(b, :), 'color', [.5 1 .5]);
    legendOff(ax);
    plot(t, nanmean(mdata(a, :), 1), 'r', 'linewidth', 3);
    plot(t, nanmean(mdata(b, :), 1), 'b', 'linewidth', 3);
    
    legend(names);
    
    vline([1 2 4])
end