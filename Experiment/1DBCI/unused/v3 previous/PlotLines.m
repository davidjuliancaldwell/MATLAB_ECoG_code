function PlotLines(subject, electrodeSubset, color, linewidth)

    if ~exist('linewidth', 'var')
        linewidth = 1;
    end
    
    if ~exist('color','var')
        color = [1 0 0];
    end

    basedir = getSubjDir(subject);
    
    load(fullfile(basedir, 'trodes.mat'));

    Montage.MontageTokenized = electrodeSubset;
    locs = trodeLocsFromMontage(subject, Montage);
    
    links = nchoosek(1:size(locs,1),2);
    
    for c = 1:size(links,1)
        is = links(c, :);
        line(locs(is,1), locs(is,2), locs(is,3), 'color', color, 'LineWidth', linewidth);
    end
end