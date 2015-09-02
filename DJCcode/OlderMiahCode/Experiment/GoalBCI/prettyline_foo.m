function [handles, classes] = prettyline(x, data, class)
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
    
    colors = 'rgbcmyk';
    
    if (any(any(isnan(data))))
        mMean = @nanmean;
        mSem = @nansem;
    else
        mMean = @mean;
        mSem = @sem;
    end
    
    for cIdx = 1:length(classes)
        cData = data(:, class==classes(cIdx));
        mu{cIdx} = mMean(cData,2);
        se = mSem(cData,2);
        
        handles.sems(cIdx, 1) = plot(x, mu{cIdx}+se, ':', 'color', colors(cIdx));
        legendOff(handles.sems(cIdx, 1));
        hold on;
        handles.sems(cIdx, 1) = plot(x, mu{cIdx}-se, ':', 'color', colors(cIdx));
        legendOff(handles.sems(cIdx, 1));
    end
    
    for cIdx = 1:length(classes)
        handles.means(cIdx) = plot(x, mu{cIdx}, 'color', colors(cIdx));
    end
    
    hold off;
end