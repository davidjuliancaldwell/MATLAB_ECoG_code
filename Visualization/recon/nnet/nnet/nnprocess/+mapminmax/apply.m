function y = apply(x,settings)
%MAPMINMAX.APPLY

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  y = x;
  return;
end

y = bsxfun(@minus,x,settings.xoffset);
y = bsxfun(@times,y,settings.gain);
y = bsxfun(@plus,y,settings.ymin);
