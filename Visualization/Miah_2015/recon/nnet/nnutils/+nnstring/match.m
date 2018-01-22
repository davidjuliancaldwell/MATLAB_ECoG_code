function i = match(str,strs)

% Copyright 2012 The MathWorks, Inc.

for i=1:length(strs)
  if strcmp(str,strs{i})
    return
  end
end
i = [];
