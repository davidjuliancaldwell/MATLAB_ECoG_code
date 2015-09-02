function dy = backpropReverse(dx,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dx);
dx = reshape(dx,settings.xrows,Q*N);
dy = settings.inverseTransform' * dx;
dy = reshape(dy,settings.yrows,Q,N);
