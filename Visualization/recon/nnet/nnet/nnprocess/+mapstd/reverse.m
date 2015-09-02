function x = reverse(y,settings)
%MAPMINMAX.REVERSE

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  x = y;
  return;
end

x = bsxfun(@minus,y,settings.ymean);
x = bsxfun(@rdivide,x,settings.gain);
x = bsxfun(@plus,x,settings.xoffset);
