function folders = dirs(folder,option)
%NN_DIRS Directories immediately in a directory.

% Copyright 2010 The MathWorks, Inc.

if nargin < 2
  option = '';
end

% MULTIPLE
if iscell(folder)
  numFolders = size(folder);
  folders = cell(1,numFolders);
  for i=1:numFolders
    folders{i} = nndir.dirs(folder{i});
  end
  folders = [folders{:}];

%SINGLE
else
  x = dir(folder);
  numX = length(x);
  if numX == 0, folders = {}; return; end
  
  folders = {};
  for i=1:length(x)
    name = x(i).name;
    if x(i).isdir && ~strcmp(name,'.') && ~strcmp(name,'..')
      child = nnpath.rel2abs(x(i).name,folder);
      folders = [folders {child}];
      if strcmp(option,'all')
        folders = [folders nndir.dirs(child,'all')];
      end
    end
  end
end
