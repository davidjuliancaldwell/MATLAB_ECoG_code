function x = reverse(y,settings)
%REMOVECONSTANTROWS.REVERSE

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  x = y;
  return;
end

Q = size(y,2);
x = nan(settings.xrows,Q);
x(settings.keep_ind,:) = y;
