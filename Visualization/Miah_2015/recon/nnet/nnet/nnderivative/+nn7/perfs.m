function [perfs,perfN] = perfs(net,data,masks,hints)
%NNCALC_MATLAB.PERFS

% Copyright 2012 The MathWorks, Inc.

fcn = hints.perform;
numMasks = length(masks);

perfs = zeros(1,numMasks);
perfN = zeros(1,numMasks);

% Disable unflattening of Y
data.TSu = data.TS;
data.Qu = data.Q;

Y = nn7.y(net,data,hints);
E = gsubtract(data.T,Y);
E = nn_performance_fcn.normalize_error(net,E,fcn.param);

PERF = cell(size(Y));
for i=1:numel(Y)
  PERF{i} = fcn.apply(data.T{i},Y{i},E{i},fcn.param);
end
PERF = gmultiply(PERF,data.EW);
for i=1:numel(Y)
  for m=1:numMasks
    pm = PERF{i} .* masks{m}{i};
    nanInd = find(isnan(pm));
    pm(nanInd) = 0;
    perfs(m) = perfs(m) + sum(pm(:));
    perfN(m) = perfN(m) + numel(pm) - numel(nanInd);
  end
end
