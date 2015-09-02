function handles = plotBandBar(spectra, hz, bands, bandNames, periods, sortedPeriods, figureTitles)
    StimConstants;
    
    if length(sortedPeriods) > size(COLORS, 1)
        error('current color map currently only supports up to 5 periods');
    end

    handles = zeros(size(spectra, 2), 1);

    data = zeros(size(bands, 1), size(spectra, 2), size(spectra, 3));
    for bandIdx = 1:size(bands, 1)
        data(bandIdx, :, :) = mean(spectra(hz >= bands(bandIdx, 1) & hz <= bands(bandIdx, 2), :, :), 1);
    end
    
    for channelIdx = 1:size(spectra, 2) % one plot for each channel
        handles(channelIdx) = figure;

        ax = prettybar(squeeze(data(:, channelIdx, :)), periods);
        
        for c = 1:length(ax.bars)
            set(ax.bars(c), 'facecolor', COLORS(c, :));
        end
        
        set(ax.ax, 'xticklabel', bandNames);
        xlabel('band', 'fontsize', AXLABEL_FONTSIZE);
        ylabel('magnitude (dB)', 'fontsize', AXLABEL_FONTSIZE);
        set(gca, 'fontsize', AXTICK_FONTSIZE);
        
        title(figureTitles{channelIdx}, 'fontsize', TITLE_FONTSIZE);
        
        for c = 1:length(sortedPeriods);
            legendCellArr{c} = num2str(sortedPeriods(c));
        end
        
        legend(legendCellArr, 'fontsize', LEGEND_FONTSIZE);
    end
end