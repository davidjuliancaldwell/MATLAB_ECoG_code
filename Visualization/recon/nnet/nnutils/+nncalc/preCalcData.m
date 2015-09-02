function data = preCalcData(calcMode,calcHints,net,data,doPc,doPd,doFlattenTime)

% Copyright 2012 The MathWorks, Inc.

isGPU = isa(data.X,'parallel.gpu.GPUArray');
if isGPU && (doPc || doPd)
  precision = class(gather(data.X(1)));
  gpuMode = nnGPU('precision',precision);
  gpuHints = gpuMode.hints;
  gpuHints = nnGPU.netHints(net,gpuHints);
end

% Process Inputs
if doPc
  if isGPU
    data.Pc = gpuMode.pc(net,data.X,data.Xi,data.Q,data.TS,gpuHints);
    data.X = nndata2gpu([],precision);
    data.Xi = nndata2gpu([],precision);
  else
    data.Pc = calcMode.pc(net,data.X,data.Xi,data.Q,data.TS,calcHints);
    data.X = {};
    data.Xi = {};
  end
else
  if isGPU
    data.Pc = nndata2gpu([],precision);
  else
    data.Pc = {};
  end
end

% Delay Inputs
if doPd
  if isGPU
    % Not implemented
  else
    data.Pd = calcMode.pd(net,data.Pc,data.Q,data.TS,calcHints);
    data.Pc = {};
  end
else
  if isGPU
    data.Pd = nndata2gpu([],precision);
  else
    data.Pd = {};
  end
end

% Flatten Time
if doFlattenTime
  data = nncalc.flattenTime(data);
end
