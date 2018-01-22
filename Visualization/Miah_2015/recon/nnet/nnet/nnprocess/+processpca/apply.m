function y = apply(x,settings)
%MAPMINMAX.APPLY

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  y = x;
  return;
end

y = settings.transform * x;
