function xL = smoothAndDownsample(x, L, dim)
    if (dim ~= 1)
        error ('not implemented for dimensions other than 1');
    end
    
    y = ones(L, 1);
    fix = false;
    
    if mod(L, 2) == 1
        L = L + 1;
        y(end+1) = 0;
        fix = true;
    end
    
    for c = 1:size(x, 2)
        for d = 1:size(x, 3)
            temp = conv(x(:, c, d), y);
            xL(:, c, d) = temp((L/2):(end-(L/2)));
        end
    end

    if (fix)
        L = L - 1;
    end
    
    xL = xL(1:L:end, :, :);
end