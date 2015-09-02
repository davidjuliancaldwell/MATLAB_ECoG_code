function [weight, tcenter, lcenter] = findBestLag(interaction, t, lags, threshold, doPlots)
%     % focus only on the time period of interest
%     tkeep = t >= -.5 & t <= .5;
%     interaction = interaction(:, tkeep);
%     t = t(tkeep);

    if (~exist('threshold', 'var') || isempty(threshold))
        threshold = -Inf;        
    end
    
    % max value approach
    [lidx, tidx] = find(interaction == max(max(interaction)), 1, 'first');
    weight = max(max(interaction));

    tcenter = t(tidx);
    lcenter = lags(lidx);

    % center of mass approach
    
    if (doPlots)
        % draw an image
        figure
        imagesc(t, lags, interaction);

        vline(0,'k:');
        hline(0,'k:');

        vline(tcenter);
        hline(lcenter);

        title(sprintf('lag=%f, time=%f', lcenter,tcenter));
    end
end