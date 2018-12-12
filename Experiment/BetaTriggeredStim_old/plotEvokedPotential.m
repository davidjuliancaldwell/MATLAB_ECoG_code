function handle = plotEvokedPotential(x, Y)
    handle = figure;
    
    plot(x, Y(:,1:10:end),'color', [.5 .5 .5]);
    hold on;
    plot(x, mean(Y, 2), 'r', 'linew', 2);
    ylim([-100e-6 100e-6]);
    xlim([min(x) max(x)]);
end