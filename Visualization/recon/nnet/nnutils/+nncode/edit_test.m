function nn_edit_test(name,path)

% Copyright 2010 The MathWorks, Inc.

% Multiple tests
if iscell(name)
  for i=1:length(name)
    nn_edit_test(name{i})
  end
  return
end

% Find and edit test
if nargin < 2, path = []; end
file = nn_find_test(name,path);
if ~isempty(file)
  edit(file);
else
  disp(['Cannot find test: ' name])
end
