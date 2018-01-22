function x = reverse(y,settings)
%REMOVECONSTANTROWS.REVERSE

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  x = y;
  return;
end

x = y((1:settings.xrows) + settings.shift,:);
isKnown = double(y(settings.unknown + settings.shift(settings.unknown) + 1,:) >= 0.5);
isKnown(~isKnown) = NaN;
x(settings.unknown,:) = x(settings.unknown,:) .* isKnown;
