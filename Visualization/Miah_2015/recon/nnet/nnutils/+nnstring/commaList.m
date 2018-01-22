function str = commaList(strs)

% Copyright 2012 The MathWorks, Inc.

if isempty(strs)
  str = '';
else
  str = strs{1};
  for i=2:numel(strs)
    str = [str ',' strs{i}];
  end
end
