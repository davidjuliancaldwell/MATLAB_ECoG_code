function [y,settings] = create(x,param)

% Copyright 2012 The MathWorks, Inc.

rows = size(x,1);
for i=1:rows
  finiteInd = find(full(~isnan(x(i,:))),1);
  if isempty(finiteInd)
    xfinite = 0;
  else
    xfinite = x(finiteInd);
  end
  nanInd = isnan(x(i,:));
  x(i,nanInd) = xfinite;
end

settings.max_range = param.max_range;
settings.keep = 1:size(x,1);
maxx = max(x,[],2); if isempty(maxx), maxx=zeros(0,1); end
minx = min(x,[],2); if isempty(minx), minx=zeros(0,1); end
midx = (maxx + minx) / 2;
settings.remove = find((maxx-minx) <= settings.max_range)';
settings.keep(settings.remove) = [];
settings.value = midx(settings.remove,:);
settings.xrows = size(x,1);
settings.yrows = settings.xrows - length(settings.remove);
settings.constants = mean(x(settings.remove,:),2);
settings.no_change = isempty(settings.remove);

y = removeconstantrows.apply(x,settings);
