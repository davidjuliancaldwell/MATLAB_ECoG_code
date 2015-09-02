function files = xmlfiles(folder,depth)
%MFILES M-extenstion files nested within a directory.

% Copyright 2010-2011 The MathWorks, Inc.

if nargin < 2, depth = ''; end

files = nnfile.files(folder,depth);
files = nnpath.filter_ext(files,'xml');
for i=length(files):-1:1
  [~,name] = fileparts(files{i});
  if isempty(name) || (name(1) == '.')
    files(i) = [];
  end
end
