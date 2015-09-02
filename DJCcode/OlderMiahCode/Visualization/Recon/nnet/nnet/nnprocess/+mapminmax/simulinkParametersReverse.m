function params = simulinkParametersReverse(settings)

% Copyright 2012 The MathWorks, Inc.

xmin = settings.xmin;
xmax = settings.xmax;
xrange = settings.xrange;
fix = find(~isfinite(xrange) | (xrange == 0));
xmin(fix) = settings.ymin;
xmax(fix) = settings.ymax;

params = ...
  { ...
  'xmin',mat2str(xmin,30);
  'xmax',mat2str(xmax,30);
  'ymin',mat2str(settings.ymin,30);
  'ymax',mat2str(settings.ymax,30);
  };
