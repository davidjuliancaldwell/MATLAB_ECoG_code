function update(nnet_root)
% Updates MATLAB path for NNET directory changes.

% Copyright 2010 The MathWorks, Inc.

% New NNET Toolbox Path
if nargin < 1
  nnet_root = nnpath.nnet_root;
elseif ~any((nnet_root == '/') | (nnet_root == '\'))
  nnet_root = fullfile(fileparts(nnpath.nnet_root),nnet_root);
end

% Calculate Current
old_paths = nnpath.current_nnet;
new_paths = nnpath.installed_nnet(nnet_root);

% Report Current
disp('EXISTING PATH STATUS')
disp('--------------------')
disp(' ')
if isempty(old_paths)
  disp('No Current Paths.')
else
  disp([num2str(length(old_paths)) ' Current Paths:'])
  disp(' ')
  for i=1:length(old_paths)
    disp(old_paths{i});
  end
end
disp(' ')
if isempty(new_paths)
  disp('No Installed Paths.')
else
  disp([num2str(length(new_paths)) ' Installed Paths:'])
  disp(' ')
  for i=1:length(new_paths)
    disp(new_paths{i});
  end
end

% Calculate Changes
keep_paths = {};
for i=length(old_paths):-1:1
  old_path = old_paths{i};
  for j=1:length(new_paths)
    new_path = new_paths{j};
    if strcmp(old_path,new_path)
      old_paths(i) = [];
      new_paths(j) = [];
      keep_paths = [{old_path}; keep_paths];
      break;
    end
  end
end

% Make Changes
if ~isempty(old_paths)
  rmpath(old_paths{:});
end
if ~isempty(new_paths)
  addpath(new_paths{:},'-BEGIN');
end
savepath

% Display Changes
disp(' ')
disp('PATH CHANGES')
disp('------------')
disp(' ')
if isempty(keep_paths)
  disp('No Paths Kept.')
else
  disp([num2str(length(keep_paths)) ' Paths Kept:'])
  disp(' ')
  for i=1:length(keep_paths)
    disp(keep_paths{i});
  end
end
disp(' ')
if isempty(old_paths)
  disp('No Paths Removed.')
else
  disp([num2str(length(old_paths)) ' Paths Removed:'])
  disp(' ')
  for i=1:length(old_paths)
    disp(old_paths{i});
  end
end
disp(' ')
if isempty(new_paths)
  disp('No Paths Added.')
else
  disp([num2str(length(new_paths)) ' Paths Added:'])
  disp(' ')
  for i=1:length(new_paths)
    disp(new_paths{i});
  end
end
disp(' ')

disp('Reloading Java')
nnpath.add_jar(true)
disp(' ')

rehash toolboxcache

