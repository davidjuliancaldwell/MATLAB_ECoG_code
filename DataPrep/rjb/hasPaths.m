function result = hasPaths(sta)
    result = isfield(sta, 'CursorPosX') || isfield(sta, 'CursorXPos');
end