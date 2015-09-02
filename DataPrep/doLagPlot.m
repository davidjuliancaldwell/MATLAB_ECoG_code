function doLagPlot(lags)
    figure
    subplot(211);
    imagesc(lags); colorbar;
    subplot(212);
    imagesc(lags ~= 0); colorbar;
end