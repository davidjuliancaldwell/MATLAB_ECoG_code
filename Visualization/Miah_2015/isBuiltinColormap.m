function retVal = isBuiltinColormap(name)
    name = lower(name);

    switch(name)
        case 'jet'
            retVal = true;
        case 'hsv'
            retVal = true;
        case 'hot'
            retVal = true;
        case 'cool'
            retVal = true;
        case 'spring'
            retVal = true;
        case 'summer'
            retVal = true;
        case 'autumn'
            retVal = true;
        case 'winter'
            retVal = true;
        case 'gray'
            retVal = true;
        case 'bone'
            retVal = true;
        case 'copper'
            retVal = true;
        case 'pink'
            retVal = true;
        case 'lines'
            retVal = true;
        otherwise
            retVal = false;
    end
end