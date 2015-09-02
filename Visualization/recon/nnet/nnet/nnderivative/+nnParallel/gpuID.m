function id = gpuID

% Copyright 2012 The MathWorks, Inc.

if nnGPU.isSupported
  gpuInfo = gpuDevice;
  id = [ nnParallel.hostID '_GPU_' num2str(gpuInfo.Index)];
else
  id = '';
end
