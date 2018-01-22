function dx = forwardpropReverse(dy,x,y,settings)

% Copyright 2012 The MathWorks, Inc.

finiteX = ~isnan(x);
dx = bsxfun(@times,dy((1:settings.xrows)+settings.shift,:,:),finiteX);
