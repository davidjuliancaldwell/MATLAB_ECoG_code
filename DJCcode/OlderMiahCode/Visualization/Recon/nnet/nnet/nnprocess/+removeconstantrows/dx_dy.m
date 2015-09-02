function d = dx_dy(x,y,settings)

% Copyright 2012 The MathWorks, Inc.

d = removeconstantrows.dy_dx(x,y,settings);
for i=1:length(d), d{i} = d{i}'; end
