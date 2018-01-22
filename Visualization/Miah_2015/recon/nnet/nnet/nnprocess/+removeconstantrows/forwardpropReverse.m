function dx = forwardpropReverse(dy,x,y,settings)
%REMOVECONSTANTROWS.BACKPROP

% Copyright 2012 The MathWorks, Inc.

sizes = size(dy);
sizes(1) = settings.xrows;
dx = zeros(sizes);
dx(settings.keep,:) = dy(:,:);
