function dy = forwardprop(dx,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dx);
dx = reshape(dx,settings.xrows,Q*N);
dy = settings.transform * dx;
dy = reshape(dy,settings.yrows,Q,N);
