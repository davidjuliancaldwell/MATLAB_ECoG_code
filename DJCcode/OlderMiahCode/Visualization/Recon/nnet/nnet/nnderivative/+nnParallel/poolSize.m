function s = poolSize

% Copyright 2012 The MathWorks, Inc.

if ~nnDependency.distCompAvailable
  s = 0;
else
  try
    s = matlabpool('size');
  catch
    % MATLABPOOL may fail if Java is not available (-nojvm, etc)
    s = 0;
  end
end
