function str = propname2linkstr(p)

% Copyright 2010 The MathWorks, Inc.

spaces = ' ';
spaces = repmat(spaces,1,18-length(p));

str = [spaces nnlink.str2link(p,...
  ['matlab:disp('' '');disp(''*** OPEN DOC TO PROPERTY ' p ' ***'')'])...
  ': '];
