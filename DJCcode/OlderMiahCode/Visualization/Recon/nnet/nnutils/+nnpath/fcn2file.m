function file = fcn2file(fcn,root)

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, root = ''; end

% MULTIPLE
if iscell(fcn)
  numFcns = length(fcn);
  file = cell(1,numFcns);
  for i=1:numFcns
    file{i} = nnpath.fcn2file(fcn{i},root);
  end
  return
end

% SINGLE
file = which(fcn);
