function handles = plotAverageSpectra(spectra, sems, hz, sortedPeriods, figureTitles)
    StimConstants;
    
    if length(sortedPeriods) > size(COLORS, 1)
        error('current color map currently only supports up to 5 periods');
    end

    handles = zeros(size(spectra, 2), 1);
    
    for channelIdx = 1:size(spectra, 2) % one plot for each channel
        handles(channelIdx) = figure;
        
        for periodIdx = 1:length(sortedPeriods)
            ax = plot(hz, [spectra(:, channelIdx, periodIdx)+sems(:, channelIdx, periodIdx) spectra(:, channelIdx, periodIdx)-sems(:, channelIdx, periodIdx)]');
            set(ax, 'color', COLORS(periodIdx, :));
            set(ax, 'linestyle', SEM_LINESTYLE);
            set(ax, 'linew', SEM_LINEW);            
            legendOff(ax);
            
            if (~ishold) hold on; end
        end
        
        for periodIdx = 1:length(sortedPeriods)
            ax = plot(hz, spectra(:, channelIdx, periodIdx));
            set(ax, 'color', COLORS(periodIdx, :));
            set(ax, 'linestyle', MU_LINESTYLE);
            set(ax, 'linew', MU_LINEW);
        end
        
        title(figureTitles{channelIdx}, 'fontsize', TITLE_FONTSIZE);
        xlabel('frequency (hz)', 'fontsize', AXLABEL_FONTSIZE);
        ylabel('magnitude (dB)', 'fontsize', AXLABEL_FONTSIZE);
        set(gca, 'fontsize', AXTICK_FONTSIZE);
        
        legendCellArr = cell(length(sortedPeriods), 1);
        
        for c = 1:length(sortedPeriods);
            legendCellArr{c} = num2str(sortedPeriods(c));
        end
        
        legend(legendCellArr, 'fontsize', LEGEND_FONTSIZE);
    end
end