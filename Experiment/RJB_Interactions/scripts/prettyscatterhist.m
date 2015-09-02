function handle = prettyscatterhist(x, y, class, classcolors)
    classes = unique(class);
    
    handle = figure;
    for cIdx = 1:length(classes)
        scatterhist(x(class==classes(cIdx)), y(class==classes(cIdx)));
        hold on;
    end    
end