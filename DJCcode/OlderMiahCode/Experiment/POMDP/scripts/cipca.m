function [projections, filters] = cipca(data, class)
error 'doesnt work'
    data = proj(:,[3 4]);
    
    mudata = mean(data, 1);
    sigdata = std(data, 1);

    zdata = (data-repmat(mudata, [size(data, 1), 1]))./repmat(sigdata, [size(data, 1), 1]);
    
    [proj, filt] = mpca(cat(2, zdata, zscore(labels)));
end
