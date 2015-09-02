function dy = forwardprop(dx,x,y,settings)
%REMOVECONSTANTROWS.BACKPROP_REVERSE

% Copyright 2012 The MathWorks, Inc.

sizes = size(dx);
sizes(1) = settings.yrows;
dy = reshape(dx(settings.keep_ind,:),sizes);
