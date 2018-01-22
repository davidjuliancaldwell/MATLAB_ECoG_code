function str = fieldvalue2str(v)

% Copyright 2010-2011 The MathWorks, Inc.

if islogical(v)
  str = nnstring.bool2str(v);
elseif isnumeric(v)
  str = nnstring.num2str(v);
elseif ischar(v)
  str = ['''' v ''''];
elseif iscell(v)
  [r,c] = size(v);
  str = ['{' num2str(r) 'x' num2str(c) ' cell array}'];
else
  error(message('nnet:nnstring_fieldvalue2str:CannotPrint'))
end
