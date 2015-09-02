function activeLabs = gpuLabs

% Copyright 2012 The MathWorks, Inc.

numLabs = matlabpool('size');

% Get Host and GPU information from each lab
spmd
  hosts = nnParallel.hostID;
  labIndices = labindex;
  
  gpuCounts = gpuDeviceCount();
  if (gpuCounts == 0)
    gpuIndices = 0;
  else
    try
      gpuInfo = gpuDevice;
      if gpuInfo.DeviceSupported
        gpuIndices = gpuInfo.Index;
      else
        gpuIndices = 0;
      end
    catch
      gpuIndices = 0;
    end
  end
end

hosts = nnParallel.composite2Cell(hosts);
labIndices = nnParallel.composite2Array(labIndices);
gpuCounts = nnParallel.composite2Array(gpuCounts);
gpuIndices = nnParallel.composite2Array(gpuIndices);

% Find unique hosts
[~,uniqueHostIndices,hostIndices] = unique(hosts);
uniqueGPUCounts = gpuCounts(uniqueHostIndices);

% Mark first lab for each host/gpuIndex combination as active
activeLabs = false(1,numLabs);
for i=1:numel(uniqueHostIndices)
  for j=1:uniqueGPUCounts(i)
    hits = find((hostIndices==i) & (gpuIndices==j));
    if ~isempty(hits)
      activeLabs(labIndices(hits(1))) = true;
    end
  end
end
