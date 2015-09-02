function targetCounts = extractTargetCountFromFilename(filenames)
    targetCounts = zeros(size(filenames));
    
    for c = 1:length(filenames)
        targetCounts(c) = subExtract(filenames{c});
    end
end

function targetCount = subExtract(filename)

    res = regexpi(filename, '(\d)targ', 'tokens');
    
    if (isempty(res))
        targetCount = 2;
    else
        res = res{1};
        targetCount = str2double(res);
    end
end