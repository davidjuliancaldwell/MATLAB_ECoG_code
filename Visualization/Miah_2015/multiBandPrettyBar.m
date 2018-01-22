function h = multiBandPrettyBar(data, class, dataNames, classNames, titleStr)
    % data is M x N where M is observations and N is the number of data
    % streams
    %
    % dataNames should be a cell array of length N and is used for plotting
    %
    % class should be of length M and corresponds to the different groups
    % that the data streams can be divided in to
    %
    % classNames should be of length(unique(class)) and is a cell array of
    % strings used for plotting
    
    classes = unique(class);
    
    mu = zeros(size(data, 2), length(classes));
    stdError = zeros(size(data, 2), length(classes));
    
    for cIdx = 1:length(classes)
        for dIdx = 1:size(data, 2)
            mu(dIdx, cIdx) = mean(data(class == classes(cIdx), dIdx));
            stdError(dIdx, cIdx) = std(data(class == classes(cIdx), dIdx)) / sum(class == classes(cIdx));
        end
    end    
    
    if (exist('classNames', 'var') && ~isempty(classNames))        
        h = barweb(mu, stdError, 1, dataNames, titleStr, [], 'z-score', 'gray', 'off', classNames);  
    else
        h = barweb(mu, stdError, 1, dataNames, titleStr, [], 'z-score', 'gray', 'off', classNames);  
    end        
end