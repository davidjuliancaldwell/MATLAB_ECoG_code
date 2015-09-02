function flag = isSupported

% Copyright 2012 The MathWorks, Inc.

if ~nnDependency.distCompAvailable
  flag = false;
else
  try
    gpuInfo = gpuDevice;
    flag = gpuInfo.DeviceSupported;
  catch
    flag = false;
  end
end
