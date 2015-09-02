function path = rel2abs(path,root)
% NN_REL2ABS Convert relative paths to absolute paths.
%
%  path = nn_rel2abs(path)
%  path = nn_rel2abs(path,root)
%  {..paths..} = nn_rel2path({..paths..})
%  {..paths..} = nn_rel2path({..paths..},root)
%
%  Default ROOT is NNETROOT.

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, root = matlabroot; end

% MULTIPLE
if iscell(path)
  for i=1:length(path)
    path{i} = nnpath.rel2abs(path{i},root);
  end
  return
  
% SINGLE
else
  path = [root filesep path];
end
