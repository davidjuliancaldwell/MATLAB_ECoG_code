function i = first_match(str,strs)

% Copyright 2011 The MathWorks, Inc.

if ischar(strs)
  [n,m] = size(strs);
  strs = mat2cell(strs,ones(1,n),m);
end
i = find(strcmp(str,strs),1);
