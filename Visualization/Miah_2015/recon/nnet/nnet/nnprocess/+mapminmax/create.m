function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.

xrows = size(x,1);
if isempty(x), x = nan(xrows,1); end
xmin = min(x,[],2);
xmax = max(x,[],2);
xmin(isnan(xmin)) = -inf;
xmax(isnan(xmax)) = inf;

% Assert: xmin and xmax will be [-inf inf] for unknown ranges
settings.name = 'mapminmax';
settings.xrows = xrows;
settings.xmax = xmax;
settings.xmin = xmin;
settings.xrange = xmax - xmin;
settings.yrows = settings.xrows;
settings.ymax = param.ymax;
settings.ymin = param.ymin;
settings.yrange = settings.ymax - settings.ymin;

% Convert from settings values to safe processing values
% and check whether safe values result in x<->y change.
xoffset = settings.xmin;
gain = settings.yrange ./ settings.xrange;
fix = find(~isfinite(settings.xrange) | (settings.xrange == 0));
gain(fix) = 1;
xoffset(fix) = settings.ymin;
settings.no_change = (settings.xrows == 0) || ...
  (all(gain == 1) && all(xmin == 0));

settings.gain = gain;
settings.xoffset = xoffset;

y = mapminmax.apply(x,settings);
