%% cortical plots
% do the cortical plots

function corticalPlots (Montage, aggregate, subjid, HGRSAs, BetaRSAs, hemisphere, activities, legendEntries, filename)

filename = filenameForString(filename);

if (isfield(Montage, 'Default') == false || Montage.Default == false) % actually have a montage, do the cortical plots
    if (aggregate == true)
        figure;
%        colorLimits = [-max(abs(HGRSAs(1, :))) max(abs(HGRSAs(1,:)))];
        lim = nanmax(1, max(abs(HGRSAs(1,:))));
        
        PlotDots(subjid, Montage.MontageTokenized, HGRSAs(1, :), hemisphere, [-lim lim], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        title(strcat('HG Response to aggregated stimuli for...', filename));
        colorbar;

        figure;
        PlotDots(subjid, Montage.MontageTokenized, BetaRSAs(1, :), hemisphere, [-lim lim], 20, 'recon_colormap');
        load('recon_colormap');
        colormap(cm);
        title(strcat('Beta Response to aggregated stimuli for...', filename));
        colorbar;
    else    
        for activityIdx = 1:length(activities)
            lim = nanmax(1, max(abs(HGRSAs(1,:))));
            figure;
            PlotDots(subjid, Montage.MontageTokenized, HGRSAs(activityIdx, :), hemisphere, [-lim lim], 20, 'recon_colormap');
            load('recon_colormap');
            colormap(cm);
            try title(sprintf(' HG Response %s', legendEntries{activityIdx})); %try catch end added in case activity not listed as in glove data
            catch title(strcat(' HG Response for...', filename))
                fprintf('no value for par.Stimuli.Value- may be using data glove epochs...\n')
            end
            colorbar;

            figure;
            PlotDots(subjid, Montage.MontageTokenized, BetaRSAs(activityIdx, :), hemisphere, [-lim lim], 20, 'recon_colormap');
            load('recon_colormap');
            colormap(cm);
            try title(sprintf(' Beta Response %s', legendEntries{activityIdx})); %try catch end added in case activity not listed as in glove data
            catch title(strcat(' Beta Response for...', filename))
                fprintf('no value for par.Stimuli.Value- may be using data glove epochs...\n')
            end
            colorbar;
        end 
    end
end