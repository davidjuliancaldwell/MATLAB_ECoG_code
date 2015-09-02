function y = toCol(x)
    if (iscol(x))
        y = x;
    else
        y = x';
    end
end