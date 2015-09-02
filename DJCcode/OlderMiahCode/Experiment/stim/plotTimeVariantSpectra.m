function handles = plotTimeVariantSpectra(spectra, hz, periods, normPeriod, figureTitles)
    StimConstants;
    
    handles = zeros(size(spectra, 2), 1);
    
    for channelIdx = 1:size(spectra, 2) % one plot for each channel
        handles(channelIdx) = figure;
        
        channelSpectra = squeeze(spectra(:,channelIdx,:));
        nSpectra = normalize_plv(channelSpectra, channelSpectra(:, periods == normPeriod));
        
        imagesc(1:size(nSpectra,2), hz, nSpectra);
        axis xy;
        
        title(figureTitles{channelIdx}, 'fontsize', TITLE_FONTSIZE);
        xlabel('epochs', 'fontsize', AXLABEL_FONTSIZE);
        ylabel('frequency (hz)', 'fontsize', AXLABEL_FONTSIZE);
        set(gca, 'fontsize', AXTICK_FONTSIZE);
        
        colorbar('fontsize', AXTICK_FONTSIZE);
        
        vline(find([0; diff(periods')])+0.5, 'k');
        
    end
end