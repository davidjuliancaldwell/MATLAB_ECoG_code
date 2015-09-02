function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

[Y,trainPerf,trainN,JE,JJ] = calc_Y_trainPerfJeJJ(net,data,hints);

fcn = hints.perform;
if data.val.enabled
  [valPerf,valN] = calc_perf_N(net,fcn,data.T,Y,data.val.mask,data.EW);
else
  valPerf = NaN;
  valN = 0;
end
if data.test.enabled
  [testPerf,testN] = calc_perf_N(net,fcn,data.T,Y,data.test.mask,data.EW);
else
  testPerf = NaN;
  testN = 0;
end

% FROM NNTRAINING.PERFS_JEJJ
function [Y,trainPerf,trainN,JEy,JJy] = calc_Y_trainPerfJeJJ(net,data,hints)
% Encapsulate calculation to keep extra "signals" fields temporary.
data = nn7.y_all(net,data,hints);
Y = data.Y;
data.T = gmultiply(data.T,data.train.mask);
[trainPerf,trainN] = calc_perf_N(net,hints.perform,data.T,data.Y,data.train.mask,data.EW);
E = gsubtract(data.T,Y);
E = nn_performance_fcn.normalize_error(net,E,hints.perform.param);
E = gmultiply(E,gsqrt(data.EW));
E = cell2mat(E);
E = E(:);
E(~isfinite(E)) = 0;
Jwb_y = calc_jacobian(net,data,hints);
Jwb_y(isnan(Jwb_y)) = 0;
JEy = Jwb_y * E;
JJy = Jwb_y * Jwb_y';

% FROM STATICDERIV, BTTDERIV, FPDERIV
function jWB = calc_jacobian(net,data,hints)
switch hints.direction
  case 'default'
    if ((data.TS == 1) && (net.numLayerDelays == 0))
      jWB = nn7.jac_s(net,data.Pc,data.Pd,data.Zb,data.Zi,data.Zl,...
        data.N,data.Ac,data.T,data.EW,data.Q,data.TS,hints);
    else
      jWB = nn7.jac_fp(net,data.Pc,data.Pd,data.Zb,data.Zi,data.Zl,...
        data.N,data.Ac,data.T,data.EW,data.Q,data.TS,hints);
    end
  case 'forward'
    jWB = nn7.jac_fp(net,data.Pc,data.Pd,data.Zb,data.Zi,data.Zl,...
      data.N,data.Ac,data.T,data.EW,data.Q,data.TS,hints);
  case {'backward'}
    jWB = nn7.jac_btt(net,data.Pc,data.Pd,data.Zb,data.Zi,data.Zl,...
      data.N,data.Ac,data.T,data.EW,data.Q,data.TS,hints);
end

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


