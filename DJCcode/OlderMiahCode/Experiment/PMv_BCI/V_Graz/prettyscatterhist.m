function handle = prettyscatterhist(x, y, class, classcolors)
    classes = unique(class);
    
    handle = figure;
    for cIdx = 1:length(classes)
        scatterhist(x(classes==cIdx), y(classes==cIdx));
        hold on;
    end    
end