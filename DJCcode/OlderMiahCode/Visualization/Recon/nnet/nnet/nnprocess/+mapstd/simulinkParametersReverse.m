function params = simulinkParametersReverse(settings)

% Copyright 2012 The MathWorks, Inc.

xmean = settings.xmean;
xstd = settings.xstd;
fix = find(~isfinite(xmean) |~isfinite(xstd) | (xstd == 0));
xmean(fix) = settings.ymean;
xstd(fix) = settings.ystd;

params = ...
  { ...
  'xmean',mat2str(xmean,30);
  'xstd',mat2str(xstd,30);
  'ymean',mat2str(settings.ymean,30);
  'ystd',mat2str(settings.ystd,30);
  };
