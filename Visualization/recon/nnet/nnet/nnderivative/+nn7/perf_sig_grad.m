function [perf,data,gB,gIW,gLW,gA,gradient] = perf_sig_grad(net,data,needGradient,fcns)
% Calculate perf,sig,grad from single data

% Copyright 2010-2012 The MathWorks, Inc.

% Performance
[perf,data] = nn7.perf_all(net,data,fcns);

% Gradient
if needGradient
  gE = cell(net.numLayers,data.TS);
  fcn = fcns.perform;
  gE(net.outputConnect,:) = nncalc.dperform(net,data.T,data.Y,data.EW,fcn.param);
  [gB,gIW,gLW,gA] = nn7.grad2(net,data.Pc,data.Pd,data.Zb,data.Zi,data.Zl,data.N,data.Ac,...
    gE,data.Q,data.TS,fcns);
  gWB = formwb(net,gB,gIW,gLW);
  reg = net.performParam.regularization;
  if (reg > 0)
    gWBreg = fcn.dperf_dwb(getwb(net),fcn.param);
    gWB = (1-reg)*gWB + reg*gWBreg;
    [gB,gIW,gLW] = separatewb(net,gWB);
  end
  gradient= sqrt(sum(sum(gWB.^2)));
else
  gB = cell(net.numLayers,1);
  gIW = cell(net.numLayers,net.numInputs);
  gLW = cell(net.numLayers,net.numLayers);
  gA = cell(net.numLayers,1);
  gradient = NaN;
end

% Error
data.E = gsubtract(data.T,data.Y);

