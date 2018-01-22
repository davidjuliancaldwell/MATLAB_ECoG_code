function dy = forwardprop(dx,x,y,settings)
%REMOVECONSTANTROWS.BACKPROP_REVERSE

% Copyright 2012 The MathWorks, Inc.

sizes = size(dx);
sizes(1) = settings.yrows;
dy = zeros(sizes);

finiteX = ~isnan(x);
dy((1:settings.xrows)+settings.shift,:,:) = bsxfun(@times,dx,finiteX);
