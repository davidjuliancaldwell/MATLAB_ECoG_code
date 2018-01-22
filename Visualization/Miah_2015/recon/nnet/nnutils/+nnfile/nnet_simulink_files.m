function paths = nnet_simulink_files(root,paths)

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, root = nnpath.nnet_root; end
if nargin < 2, paths = {}; end

subroot = fullfile(root,'toolbox','simulink','simulink','private', ...
  'sl_library_browser_repos','toolbox','nnet');
paths = subfunction(subroot,paths);
paths = sort(paths);

function paths = subfunction(root,paths)

files = dir(root);
for i=3:length(files)
  name = files(i).name;
  if files(i).isdir
    if strcmpi(name,'cvs'), continue, end
    paths = subfunction([root filesep name],paths);
  else
    if nn_str_ends_with(name,'.asv'), continue, end
    if nn_str_starts_with(name,'.'), continue, end
    paths = [paths; {[root filesep name]}];
  end
end
