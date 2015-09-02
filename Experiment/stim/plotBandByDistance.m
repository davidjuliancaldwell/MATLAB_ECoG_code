function handles = plotBandByDistance(spectra, hz, bands, bandNames, distanceIndices, distanceValues, periods, sortedPeriods) 

    StimConstants;
    
    if length(sortedPeriods) > size(COLORS, 1)
        error('current color map currently only supports up to 5 periods');
    end

    handles = zeros(size(bands, 1), 1);

    for bandIdx = 1:size(bands, 1) % one plot for each band        
        handles(bandIdx) = figure;
        data = squeeze(mean(spectra(hz >= bands(bandIdx, 1) & hz <= bands(bandIdx, 2), :, :), 1));

        % determine mean power in chans x periods
        mvalues = zeros(size(data, 1), length(sortedPeriods));
        
        for periodIdx = 1:length(sortedPeriods)
            mvalues(:, periodIdx) = mean(data(:, periods == sortedPeriods(periodIdx)), 2); 
        end
        
        pctvalues = mvalues ./ repmat(mvalues(:, 1), [1 4]);
        
        mus = zeros(length(distanceValues), length(sortedPeriods));        
        sems = zeros(length(distanceValues), length(sortedPeriods));        
        
            
        for distanceIdx = 1:length(distanceValues)
            mus(distanceIdx, :) = mean(pctvalues(distanceIdx == distanceIndices, :));
            sems(distanceIdx, :) = sem(pctvalues(distanceIdx == distanceIndices, :));
        end

        ax = errorbar(mus, sems, 'linew', ERROR_LINEW);
        
        for c = 1:length(ax)
            set(ax(c), 'color', COLORS(c, :));
        end

        xlim([0 length(distanceValues)+1]);
        
        set(gca, 'xtick', 1:length(distanceValues));
        set(gca, 'xticklabel', distanceValues');

        set(gca, 'fontsize', AXTICK_FONTSIZE);
        title(bandNames{bandIdx}, 'fontsize', TITLE_FONTSIZE);
        xlabel('Distance (mm)', 'fontsize', AXLABEL_FONTSIZE);
        ylabel('Fractional change', 'fontsize', AXLABEL_FONTSIZE);
        
        for c = 1:length(sortedPeriods);
            legendCellArr{c} = num2str(sortedPeriods(c));
        end
        
        legend(legendCellArr, 'fontsize', LEGEND_FONTSIZE);
    end
end