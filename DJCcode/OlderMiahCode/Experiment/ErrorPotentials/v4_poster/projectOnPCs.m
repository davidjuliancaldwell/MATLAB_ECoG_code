function [projections, pcs] = projectOnPCs(data, numPCs)

    C = cov(data);
    [V, D] = eig(C);

    [~, is] = sort(abs(diag(D)));

    pcIdxs = is(end:-1:(end-numPCs+1));
    
    dD = diag(D);
    pcs = V(:, pcIdxs) .* repmat(dD(pcIdxs)', size(C, 1), 1);
    
    projections = data * pcs;
end