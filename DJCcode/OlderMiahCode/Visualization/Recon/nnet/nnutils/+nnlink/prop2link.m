function str = prop2link(type,p,maxLen)

% Copyright 2010 The MathWorks, Inc.

if nargin < 3, maxLen = 12; end
rightAlign = 6 + maxLen;
spaces = ' ';

if nargin == 1
  spaces = repmat(spaces,1,rightAlign-length(type));
  str = [spaces type ': '];
else
  spaces = repmat(spaces,1,rightAlign-length(p));
  str = [spaces nnlink.str2link(p,['matlab:doc nnproperty.' type '_' p]) ': '];
end
