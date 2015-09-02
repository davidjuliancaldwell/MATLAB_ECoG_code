function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.
  
unknown_rows = ~isfinite(sum(x,2))';
settings.xrows = size(x,1);
settings.yrows = settings.xrows + sum(unknown_rows);
settings.unknown = find(unknown_rows);
settings.known = find(~unknown_rows);
settings.shift = [0 cumsum(unknown_rows(1:(end-1)))];
settings.xmeans = zeros(settings.xrows,1);
for i=1:settings.xrows
  finite_unknowns = isfinite(x(i,:));
  if any(finite_unknowns)
    settings.xmeans(i) = mean(x(i,finite_unknowns));
  else
    settings.xmeans(i) = 0;
  end
end
settings.no_change = isempty(settings.unknown);

% New
settings.xknown = settings.known;
settings.xunknown = settings.unknown;
settings.yknown = settings.known + settings.shift(settings.known);
settings.yunknown = settings.unknown + settings.shift(settings.unknown);
settings.yflags = settings.yunknown+1;

y = fixunknowns.apply(x,settings);
