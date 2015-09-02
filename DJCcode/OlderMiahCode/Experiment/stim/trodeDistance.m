function distances = trodeDistance(nRows, nCols, srcTrodes, spacingInMillimeters)
    distances = zeros(nRows, nCols);
    
    for x = 1:nRows
        for y = 1:nCols
            distX = abs(srcTrodes(:, 1)-x);
            distY = abs(srcTrodes(:, 2)-y);
            
            distances(x, y) = min(sqrt(distX.^2 + distY.^2) * spacingInMillimeters);
        end
    end    
end