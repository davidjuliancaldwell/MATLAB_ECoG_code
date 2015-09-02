function d = dx_dy(x,y,settings)

% Copyright 2012 The MathWorks, Inc.

Q = size(x,2);
d = cell(1,Q);
d(:) = {eye(settings.xrows)};
