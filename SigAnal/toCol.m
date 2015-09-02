function y = toCol(x)
    if (~isrow(x))
        y = x;
    else
        y = x';
    end
end