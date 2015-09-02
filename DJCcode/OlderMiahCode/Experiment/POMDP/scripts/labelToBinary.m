function y = labelToBinary(x)

% if x = a categorical label (1xL) or (Lx1)
%    y becomes a binary version Lx(unique(L))
    
    if (isrow(x))
        x = x';
    end
    
    ulabels = sort(unique(x));
    temp = arrayfun(@(a) a==ulabels, x, 'UniformOutput', false);
    y = [temp{:}]';
end
