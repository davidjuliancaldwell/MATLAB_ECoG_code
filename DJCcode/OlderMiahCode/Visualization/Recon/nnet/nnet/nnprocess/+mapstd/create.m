function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.
  
xrows = size(x,1);
settings.xrows = xrows;
settings.yrows = xrows;
settings.xmean = zeros(settings.xrows,1);
settings.xstd = zeros(settings.xrows,1);
for i=1:settings.xrows
  xi = x(i,:);
  xi(isnan(xi)) = [];
  xi(~isfinite(xi)) = NaN;
  settings.xmean(i) = mean(xi);
  settings.xstd(i) = std(xi);
end
% Assert: xstd & xmean will be NaN for infinite or unknown ranges
settings.ymean = param.ymean;
settings.ystd = param.ystd;

% Convert from settings values to safe processing values
% and check whether safe values result in x<->y change.
xoffset = settings.xmean;
xstd = settings.xstd;
gain = settings.ystd ./ xstd;
fix = find(~isfinite(settings.xmean) |~isfinite(settings.xstd) | (settings.xstd == 0));
gain(fix) = 1;
xoffset(fix) = settings.ymean;
settings.no_change = (settings.xrows == 0) || ...
  all(gain == 1) && all(xoffset == settings.ymean);

settings.gain = gain;
settings.xoffset = xoffset;

y = mapstd.apply(x,settings);
