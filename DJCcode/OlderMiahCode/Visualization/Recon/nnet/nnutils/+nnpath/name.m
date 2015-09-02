function names = name(file)
%NN_FILE_NAME Get the file name from one or more paths.

% Copyright 2010 The MathWorks, Inc.

% Multiple
if iscell(file)
  names = cell(length(file),1);
  for i=1:length(file)
    names{i} = nnpath.name(file{i});
  end
  return
end

% Single
i = find(file == filesep,1,'last');
if isempty(i)
  names = file;
else
  names = file((i+1):end);
end

