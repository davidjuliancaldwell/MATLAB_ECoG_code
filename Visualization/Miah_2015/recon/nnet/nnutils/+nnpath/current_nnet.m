function paths = current_nnet

% Copyright 2010 The MathWorks, Inc.

nnet_toolbox = nnpath.nnet_toolbox;

p = path;
separators = [0 find(p == pathsep) (length(p)+1)];
numPaths = length(separators)-1;
paths = {};
for i=1:numPaths
  pi = p((separators(i)+1):(separators(i+1)-1));
  if nnstring.starts(pi,nnet_toolbox)
    paths = [paths; {pi}];
  end
end

paths = sort(paths);
