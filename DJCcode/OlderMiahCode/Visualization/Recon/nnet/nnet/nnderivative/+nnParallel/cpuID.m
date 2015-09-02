function id = gpuID

% Copyright 2012 The MathWorks, Inc.

if nnDependency.distCompAvailable
  id = [nnParallel.hostID '_CPU_' num2str(labindex)];
else
  id = [nnParallel.hostID '_CPU'];
end
