function files = files(folder,option)
%NNFILE.FILES Files immediately in a directory.

% Copyright 2010 The MathWorks, Inc.

if nargin < 2, option = ''; end
doAll = strcmp(option,'all');

% MULTIPLE
if iscell(folder)
  numFolders = numel(folder);
  files = cell(1,numFolders);
  for i=1:numFolders
    files{i} = nnfile.files(folder{i},option);
  end
  files = [files{:}]';

%SINGLE
else
  x = dir(folder);
  files = {};
  for i=1:length(x)
    name = x(i).name;
    if ~x(i).isdir
      files = [files; {nnpath.rel2abs(x(i).name,folder)}];
    elseif doAll && ~strcmp(name,'.') && ~strcmp(name,'..') && ~strcmp(name,'CVS')
      files = [files; nnfile.files(fullfile(folder,name),'all')];
    end
  end
end
