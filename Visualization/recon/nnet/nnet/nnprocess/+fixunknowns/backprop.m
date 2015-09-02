function dx = backprop(dy,x,y,settings)
%REMOVECONSTANTROWS.BACKPROP

% Copyright 2012 The MathWorks, Inc.

finiteX = ~isnan(x);
dx = bsxfun(@times,dy((1:settings.xrows)+settings.shift,:,:),finiteX);
