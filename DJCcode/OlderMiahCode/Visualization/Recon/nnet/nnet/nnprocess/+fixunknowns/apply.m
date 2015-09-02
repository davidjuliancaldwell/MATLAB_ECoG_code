function y = apply(x,settings)

% Copyright 2012 The MathWorks, Inc.

if settings.no_change
  y = x;
  return;
end

Q = size(x,2);
y = ones(settings.yrows,Q);

isNaNX = isnan(x);
meanX = repmat(settings.xmeans,Q);
x(isNaNX) = meanX(isNaNX);

y((1:settings.xrows) + settings.shift,:) = x;

expandInd = settings.unknown;
y(expandInd + settings.shift(expandInd) + 1,:) = ~isNaNX(settings.unknown,:);
