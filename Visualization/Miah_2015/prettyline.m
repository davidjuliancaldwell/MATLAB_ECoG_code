% does automated bar plotting, where data is time (or something else
% interesting) by obsevations, and class is a 1-d vector of observation
% types.
function h = prettyline(varargin)    
    if (nargin == 4)
        t = varargin{1};
        data = varargin{2};
        class = varargin{3};
        colors = varargin{4};
    else
        data = varargin{1};
        class = varargin{2};
        colors = varargin{3};
        t = 1:size(data,1);
    end
    
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
    
    if (any(any(isnan(data))))
        warning('NaNs in data. using nanmean and nanstd');
        mMean = @nanmean;
        mStd = @nanstd;
    else
%         warning('using median');
        mMean = @median;
%         mMean = @mean;
        mStd = @std;
    end
    
    leg = cell(size(classes));

%     colors = 'rgbcmykrgbcmykrgbcmykrgbcmyk';
%     colors = [0 0 .5; .5 0 0; .3 .3 1; 1 .3 .3];
    
    for cIdx = 1:length(classes)
        if (isstr(colors))
            color = colors(cIdx);
        else
            color = colors(cIdx, :);
        end
        
        mu = mMean(data(:, class == classes(cIdx)), 2);
        stdError = mStd(data(:, class == classes(cIdx)), 0, 2) / sqrt(sum(class == classes(cIdx)));
        
%         legendOff(plot(t, mu+stdError, ':', 'color', colors(cIdx,:)));
        legendOff(plot(t, mu+stdError, ':', 'color', color));
        hold on;
        legendOff(plot(t, mu-stdError, ':', 'color', color));
%         legendOff(plot(t, mu-stdError, ':', 'color', colors(cIdx,:)));
%         plot(t, mu, 'color', colors(cIdx,:), 'linew', 2);
        plot(t, mu, 'color', color, 'linew', 2);

        leg{cIdx} = num2str(classes(cIdx));
    end
%     legend(leg);
    axis tight; 
    hold off;
end