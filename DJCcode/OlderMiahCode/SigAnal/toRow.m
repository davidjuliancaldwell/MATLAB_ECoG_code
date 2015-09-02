function y = toRow(x)
    if (isrow(x))
        y = x;
    else
        y = x';
    end
end