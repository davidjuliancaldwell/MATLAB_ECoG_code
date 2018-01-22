function str = paramname2linkstr(param)

% Copyright 2010 The MathWorks, Inc.

str = nnlink.str2link(param,...
  ['matlab:doc nnparam.' param]);
