function [Y,Af] = y(net,data,hints)

% Copyright 2012 The MathWorks, Inc.

% CALL KERNAL
[data.Y,data.Ac] = feval(hints.yKernel,...
  data.Y,data.Ac,... % Output
  net,...
  data.X, data.Xi, data.Pc, data.Pd, ...
  int64(data.Q),int64(data.QAligned),int64(data.TS),...
  hints.long,int64(hints.sizeL),hints.double,int64(hints.sizeD));

if hints.isGPUArray
  % GPU data
  Y = data.Y;
  if nargout > 1
    Nl = sum(hints.layer_sizes);
    NLD = hints.numLayerDelays;
    Af = data.Ac(:,(Nl*TS)+(1:(Nl*NLD)));
  end
else
  % Gather data
  Y = nnGPU.mat2cell(gather(data.Y),hints.output_sizes,data.Q,data.TS);
  if nargout > 1
    Af = nnGPU.mat2cell(data.Ac,hints.layer_sizes,data.Q,hints.numLayerDelays,hints.numLayerDelays+data.TS);
  end
end
