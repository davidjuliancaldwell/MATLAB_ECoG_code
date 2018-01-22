% does automated bar plotting, where data is channels (or something else
% interesting) by obsevations, and class is a 1-d vector of observation
% types.
function h = prettybar2(data, class)
    if (ndims(data) > 2)
        error('prettybar does not support multi-d arrays for data');
    end
    if (~isrow(class) && ~iscolumn(class))
        error('class must be a 1-d vector');
    end
    
    if (size(data, 2) ~= length(class))
        error('number of observations in data (dim-2) does not equal length of class vector');
    end
        
    classes = unique(class);
    
    mu = zeros(size(data, 1), length(classes));
    stdError = zeros(size(data, 1), length(classes));
    
    if (any(isnan(data)))
        warning('NaNs in data. using nanmean and nanstd');
        mMean = @nanmean;
        mStd = @nanstd;
    else
        mMean = @mean;
        mStd = @std;
    end
    
    for cIdx = 1:length(classes)
        mu(:, cIdx) = mMean(data(:, class == classes(cIdx)), 2);
        stdError(:, cIdx) = mStd(data(:, class == classes(cIdx)), 0, 2) / sqrt(sum(class == classes(cIdx)));
    end
    
    h = barweb(mu, stdError, 1);
    
    ymin = min(min(mu-2*stdError));
    ymax = max(max(mu+2*stdError));
    ylim([ymin ymax]);
    
% %     h(1) = bar(mu);
%     hold on;
%     h(2) = errorbar(mu, stdError);
end