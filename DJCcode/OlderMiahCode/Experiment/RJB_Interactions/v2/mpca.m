function [projections, filters, varfrac] = mpca(data)

    C = cov(data);
    [vectors, values] = eig(C);
    
    values = diag(values);
    [values, sortindex] = sort(values, 'descend');
    filters = vectors(:, sortindex);
    
    projections = zeros(size(data));
    
    for index = 1:size(values, 1)
        projections(:, index) = data * filters(:, index); 
%         projections(:, index) = data * vectors(:, index) / values(index); 
    end
    
    varfrac = values / sum(values);
end