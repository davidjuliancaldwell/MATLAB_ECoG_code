function paths = remove_ext(paths)
%REMOVE_EXT Remove extension from paths or filenames.

% Copyright 2010 The MathWorks, Inc.

for i=1:length(paths)
  path = paths{i};
  j = find(path == '.',1,'last');
  if ~isempty(j)
    paths{i} = path(1:(j-1));
  end
end
