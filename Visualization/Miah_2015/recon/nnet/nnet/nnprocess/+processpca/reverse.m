function x = reverse(y,settings)
%MAPMINMAX.REVERSE

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  x = y;
  return;
end

x = settings.inverseTransform * y;
