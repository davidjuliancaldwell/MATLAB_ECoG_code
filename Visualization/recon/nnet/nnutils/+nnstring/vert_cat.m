function str = vert_cat(varargin)

% Copyright 2011 The MathWorks, Inc.

v = varargin;
for i=length(v):-1:1
  if isempty(v{i}), v(i) = []; end
end
str = char(v{:});
