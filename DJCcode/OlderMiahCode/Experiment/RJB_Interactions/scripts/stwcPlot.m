function handle = interactionPlot(xvals, yvals, Cs)

    if(any(isnan(Cs(:))))
        res = squeeze(nanmean(Cs, 1));
%         res = res / nanstd(res(:));
        sig = nanstd(res(:));
    else
        res = squeeze(mean(Cs, 1));
%         res = res / std(res(:));
        sig = std(res(:));
    end
    
    imagesc(xvals, yvals, res);
    colorbar
    set_colormap_threshold(gcf, [-1 1]*sig, [-5 5]*sig, [1 1 1]);
    
end