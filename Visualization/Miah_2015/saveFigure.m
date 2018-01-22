function saveFigure(handle, filename, fullScreen)
    if(exist('fullScreen') && fullScreen == true)
        screen_size = get(0, 'ScreenSize');
        set(handle, 'Position', [0 0 screen_size(3) screen_size(4)]);
    end
    print(handle, '-zbuffer', '-dmeta', filename);
end