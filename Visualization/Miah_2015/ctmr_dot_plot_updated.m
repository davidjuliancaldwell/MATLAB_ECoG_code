function ctmr_dot_plot_updated(unencodedSubjectID, electrodes, weights, viewSide, clims, markerSize, colorMapName)
if (~exist('clims','var'))
    clims = [-1 1];
end

if (~exist('markerSize','var'))
    markerSize = 15;
end
v = viewSide;

basedir = getSubjDir(subject);

PlotCortex(unencodedSubjectID, viewSide);

if (~exist('colorMapName','var') || isempty(colorMapName))
    load('loc_colormap');
else
    cm = colormap(colorMapName);
end


minWeight = clims(1);
maxWeight = clims(2);

minColor = cm(1,:);
maxColor = cm(end,:);

alphas = (weights - minWeight) / (maxWeight - minWeight);
idxs = alphas*length(cm);

for chan=1:size(electrodes,1)
    if (isnan(weights(chan)))
        plot3(electrodes(chan,1), electrodes(chan,2), electrodes(chan,3),'.','Color',[0 0 0], 'MarkerSize', round(markerSize/2));
    else
        idx = idxs(chan);

        startColor = cm(floor(idx),:);
        endColor   = cm(ceil(idx),:);

        off = idx-floor(idx);
        trueColor = (1 - off) * startColor + off * endColor;

    %     trueColor = (1 - alpha) * minColor + alpha * maxColor;
        plot3(electrodes(chan,1),electrodes(chan,2),electrodes(chan,3),'o','MarkerFaceColor',trueColor,'MarkerSize',markerSize,'MarkerEdgeColor','k')%i like red (white would be [1 1 1], etc) dots better
        txt = num2str(chan);
        t = text(electrodes(chan,1),electrodes(chan,2),electrodes(chan,3),txt,'FontSize',10,'HorizontalAlignment','center','VerticalAlignment','middle');
        set(t,'clipping','on');
    end
end
