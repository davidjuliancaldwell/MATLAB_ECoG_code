function cstr = capitolize(str)
    if (~ischar(str) || isempty(str))
        error('dummy');
    else
        cstr = [upper(str(1)) str(2:end)];
    end
end