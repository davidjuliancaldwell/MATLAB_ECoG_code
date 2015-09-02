function maximize(fig)
    if(nargin < 1)
        fig = gcf;
    end
    
    fullscreen = get(0,'ScreenSize');
    set(fig,'Position',[0 0 fullscreen(3) fullscreen(4)-80])   
end