function a = gnegate(a)
%GNEGATE Generalized negation.
%
% <a href="matlab:doc gnegate">gnegate</a>(x) returns -x, supporting built in data behavior, as well as
% generalized behavior such as element-by-element and recursive negation
% of cell arrays.
%
% Here is an examples of negating a cell array:
%
%   x = {[1 2; 3 4],[1 3; 5 2]}
%   y = <a href="matlab:doc gnegate">gnegate</a>(x)
%   y{1}, y{2}
%
%  See also GADD, GSUBTRACT, GMULTIPLY, GDIVIDE.

% Copyright 2010 The MathWorks, Inc.

if iscell(a)
  for i=1:numel(a)
    a{i} = gnegate(a{i});
  end
else
  a = -a;
end
