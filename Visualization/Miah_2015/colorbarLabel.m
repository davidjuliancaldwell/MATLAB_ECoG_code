function colorbarLabel(varargin)
    if (nargin == 1)
        cb = colorbar;
        str = varargin{1};
    else
        cb = varargin{1};
        str = varargin{2};
    end
    
    set(get(cb,'ylabel'), 'string', str);
end