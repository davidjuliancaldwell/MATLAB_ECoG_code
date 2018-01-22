function gE = dperform(net,T,Y,EW,param)

% Copyright 2012 The MathWorks, Inc.

% Performance Function
info = feval(net.performFcn,'info');
if nargin < 5
  param = net.performParam;
end

E = gsubtract(T,Y);
E = nn_performance_fcn.normalize_error(net,E,param);
gE = cell(size(T));
N = 0;
for i=1:numel(T)
  gEi = -info.backprop(T{i},Y{i},E{i},param);
  nanInd = find(isnan(gEi));
  gEi(nanInd) = 0;
  gE{i} = gEi;
  N = N + numel(gEi) - numel(nanInd);
end
gE = gmultiply(gE,EW);
gE = nn_performance_fcn.normalize_error(net,gE,param);
if info.normalize
  for i=1:numel(T)
    gE{i} = gE{i} / N;
  end
end
