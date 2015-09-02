function nn_copy_file(original,copy)
%NN_COPY_FILE Copy one or more files.

% Copyright 2010 The MathWorks, Inc.

% Multiple
if iscell(original)
  if length(original) ~= length(copy)
    error(message('nnet:nnfile_copy:DiffNumFiles'));
  end
  for i=1:length(original)
    nn_copy_file(original{i},copy{i});
  end
  return
end

% Single
parent = nn_parent_path(copy);
if ~exist(parent,'dir')
  mkdir(parent);
end
copyfile(original,copy,'f');

function y = nn_parent_path(x)
ind = find(x==filesep,1,'last');
if isempty(ind)
  y = '';
else
  y = x(1:(ind-1));
end
