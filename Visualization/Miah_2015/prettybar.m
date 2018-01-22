% does automated bar plotting, where data is channels (or something else
% interesting) by obsevations, and class is a 1-d vector of observation
% types.
function h = prettybar(data, class, colors, fig)
    if (ndims(data) > 2)
        error('prettybar does not support multi-d arrays for data');
    end
    if (~isrow(class) && ~iscolumn(class))
        error('class must be a 1-d vector');
    end
    
    classes = unique(class);
    
    mu = zeros(length(classes), 1);
    stdError = zeros(length(classes), 1);
    
    if (any(isnan(data)))
        warning('NaNs in data. using nanmean and nanstd');
        mMean = @nanmean;
        mStd = @nanstd;
    else
        mMean = @mean;
        mStd = @std;
    end
    
    if (~exist('colors', 'var'))
        cm = colormap('jet');
        ci = round(linspace(1, size(cm, 1), length(classes)));
        colors = cm(ci, :);
    end
    
    if (~exist('fig', 'var'))
        h.figure = figure;
    else
        h.figure = fig;
    end
    
    h.bax = [];
    h.eax = [];
    
    for cIdx = 1:length(classes)
        mu(cIdx) = mMean(data(class == classes(cIdx)));
        stdError(cIdx) = mStd(data(class == classes(cIdx))) / sqrt(sum(class == classes(cIdx)));
       
        if (ischar(colors))
            color = colors(cIdx);
        else
            color = colors(cIdx, :);
        end
        
        h.bax(cIdx) = bar(cIdx, mu(cIdx), 'facecolor',color,'linew',2,'edgecolor','k');
        hold on;
    end

    h.eax = errorbar(1:length(classes), mu, stdError, 'linestyle', 'none', 'linew', 2, 'color', 'k');
    
    ymin = min(mu-2*stdError);
    ymax = max(mu+2*stdError);
    ylim([ymin ymax]);
    
% %     h(1) = bar(mu);
%     hold on;
%     h(2) = errorbar(mu, stdError);
end