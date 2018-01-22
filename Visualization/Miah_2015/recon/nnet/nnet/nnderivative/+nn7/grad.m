function [gWB,trainPerf,trainN] = grad(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% FROM NNTRAINING.PERFS_GRAD
[trainPerf,trainN,gWB] = calc_Y_trainPerfGrad(net,data,hints,hints.direction);

% FROM NNTRAINING.PERFS_GRAD
function [trainPerf,trainN,gWBy] = calc_Y_trainPerfGrad(net,data,hints,direction)
data = nn7.y_all(net,data,hints);
data.T = gmultiply(data.T,data.train.mask);
[trainPerf,trainN] = calc_perf_N(net,hints.perform,data.T,data.Y,data.train.mask,data.EW);
data.perf = trainPerf;
gWBy = calc_gradient(net,data,hints,direction);

% FROM BTTDERIV
function gWB = calc_gradient(net,data,fcns,direction)
if any([data.Q data.TS net.numOutputs net.numWeightElements] == 0)
  gWB = zeros(net.numWeightElements,1);
  return
end
gE = cell(net.numLayers,data.TS);
fcn = fcns.perform;
gE(net.outputConnect,:) = dperf_de(net,fcn,data.T,data.Y,data.EW);
Alstart = size(data.Ac,2)-data.TS+1;
Al = data.Ac(:,Alstart:end);
gE = nn7.dperf(net,Al,gE,data.Q,fcns);
switch direction
  case 'default'
    if (data.TS == 1) && (net.numLayerDelays == 0)
      [gB,gIW,gLW] = nn7.grad_static(net,data.Pc,data.Pd,data.Zb,data.Zi,...
        data.Zl,data.N,data.Ac,gE,data.Q,data.TS,fcns);
    else
      [gB,gIW,gLW] = nn7.grad_btt(net,data.Pc,data.Pd,data.Zb,data.Zi,...
        data.Zl,data.N,data.Ac,gE,data.Q,data.TS,fcns);
    end
  case 'backward'
    [gB,gIW,gLW] = nn7.grad_btt(net,data.Pc,data.Pd,data.Zb,data.Zi,...
      data.Zl,data.N,data.Ac,gE,data.Q,data.TS,fcns);
  case 'forward'
    [gB,gIW,gLW] = nn7.grad_fp(net,data.Pc,data.Pd,data.Zb,data.Zi,...
      data.Zl,data.N,data.Ac,gE,data.Q,data.TS,fcns);
end
gWB = formwb(net,gB,gIW,gLW);

% UPDATE PERFORMANCE CODE
function [perf,N] = calc_perf_N(net,fcn,T,Y,mask,EW)
T = gmultiply(T,mask);
E = gsubtract(T,Y);
E = nn_performance_fcn.normalize_error(net,E,fcn.param);
perfs = cell(size(T));
for i=1:numel(T)
  perfs{i} = fcn.apply(T{i},Y{i},E{i},fcn.param);
end
perfs = gmultiply(perfs,EW);
perf = 0;
N = 0;
for i=1:numel(T)
  perfsi = perfs{i};
  nanInd = find(isnan(perfsi));
  perfsi(nanInd) = 0;
  perf = perf + sum(perfsi(:));
  N = N + numel(perfsi) - numel(nanInd);
end

% UPDATE PERFORMANCE DERIVATIVE CODE
function gE = dperf_de(net,fcn,T,Y,EW)

E = gsubtract(T,Y);
E = nn_performance_fcn.normalize_error(net,E,fcn.param);
gE = cell(size(T));
for i=1:numel(T)
  gEi = -fcn.backprop(T{i},Y{i},E{i},fcn.param);
  gEi(isnan(gEi)) = 0;
  gE{i} = gEi;
end
gE = gmultiply(gE,EW);
gE = nn_performance_fcn.normalize_error(net,gE,fcn.param);

