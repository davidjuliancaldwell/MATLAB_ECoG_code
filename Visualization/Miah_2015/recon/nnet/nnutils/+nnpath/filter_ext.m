function paths = filter_ext(paths,ext)
%FILTER_EXT Filter paths or filenames by extension

% Copyright 2010 The MathWorks, Inc.

if ~iscell(ext), ext = {ext}; end
numExt = length(ext);
for i=1:numExt
  ext{i} = ['.' ext{i}];
end

for i=length(paths):-1:1
  drop = true;
  for j=1:numExt
    if nnstring.ends(paths{i},ext{j})
      drop = false;
      break;
    end
  end
  if drop
    paths(i) = [];
  end
end
