function [boiler,heading] = get_boiler(malfunction)
%GET_BOILER Get boilerplate code from a function.

% Copyright 2010 The MathWorks, Inc.

text = nn_getmtext(mfunction);

[start,stop] = nn_findboiler(text);

if stop == 0
  boiler = {};
  heading = '';
else
  boiler = text(start:stop);
  heading = text{1};
end
