function [perf,vperf,tperf,trainData,gB,gIW,gLW,gA,gradient] = ...
  perfs_sig_grad(net,trainData,valData,testData,needGradient,fcns)

% Copyright 2009-2012 The MathWorks, Inc.

% Performances
[perf,trainData] = nn7.perf_all(net,trainData,fcns);
if ~isempty(valData)
  vperf = nn7.perf_only(net,valData,fcns);
else
  vperf = NaN;
end
if ~isempty(testData)
  tperf = nn7.perf_only(net,testData,fcns);
else
  tperf = NaN;
end

% Gradient
if needGradient
  gE = cell(net.numLayers,trainData.TS);
  fcn = fcns.perform;
  gE(net.outputConnect,:) = nncalc.dperform(net,trainData.T,trainData.Y,trainData.EW,fcn.param);
  [gB,gIW,gLW,gA] = nn7.grad2(net,trainData.Pc,trainData.Pd,...
    trainData.Zb,trainData.Zi,trainData.Zl,trainData.N,trainData.Ac,...
    gE,trainData.Q,trainData.TS,fcns);
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
trainData.E = gsubtract(trainData.T,trainData.Y);

% TODO - Remove need for these
trainData.Tl = cell(net.numLayers,trainData.TS);
trainData.Tl(net.outputConnect,:) = trainData.T;
trainData.El = cell(net.numLayers,trainData.TS);
trainData.El(net.outputConnect,:) = trainData.E;

