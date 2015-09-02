function paths = nn_nnet_test_files(root,paths)

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, root = nnpath.nnet_root; end
if nargin < 2, paths = {}; end

paths = subfunction(fullfile(root,'test','toolbox','nnet'),paths);
paths = subfunction(fullfile(root,'test','smoke','Neural_Network_Toolbox'),paths);
paths = sort(paths);

function paths = subfunction(root,paths)

files = dir(root);
for i=3:length(files)
  name = files(i).name;
  if files(i).isdir
    if strcmpi(name,'cvs'), continue, end
    paths = subfunction([root filesep name],paths);
  else
    if nnstring.ends(name,'.asv'), continue, end
    if nnstring.starts(name,'.'), continue, end
    paths = [paths; {[root filesep name]}];
  end
end
