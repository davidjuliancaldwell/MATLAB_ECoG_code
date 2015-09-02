function paths = installed_nnet(nnet_root)

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, nnet_root = nnpath.nnet_root; end

nnet_toolbox = fullfile(nnet_root,'toolbox','nnet');
paths = sort(subfunction(nnet_toolbox,{}));


function paths = subfunction(root,paths)

paths = [paths; {root}];
files = dir(root);
for i=1:length(files)
  if (files(i).isdir) && (files(i).name(1) ~= '.')
    name = files(i).name;
    if name(1) == '@', continue, end
    if name(1) == '+', continue, end
    if strcmpi(name,'nnresource'), continue, end
    if strcmpi(name,'private'), continue, end
    if strcmpi(name,'demosearch'), continue, end
    if strcmpi(name,'html'),continue,  end
    if strcmpi(name,'ja'), continue, end
    if strcmpi(name,'cvs'), continue, end
    paths = subfunction([root filesep name],paths);
  end
end
