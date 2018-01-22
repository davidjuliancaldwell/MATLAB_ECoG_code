function dx = forwardpropReverse(dy,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dy);
dy = reshape(dy,settings.yrows,Q*N);
dx = settings.inverseTransform * dy;
dx = reshape(dx,settings.xrows,Q,N);
