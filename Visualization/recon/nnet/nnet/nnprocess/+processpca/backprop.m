function dx = backprop(dy,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

[~,Q,N] = size(dy);
dy = reshape(dy,settings.yrows,Q*N);
dx = settings.transform' * dy;
dx = reshape(dx,settings.xrows,Q,N);
