function str = prop2link2(p)

% Copyright 2010 The MathWorks, Inc.

str = nnlink.str2link(p,...
  ['matlab:disp('' '');disp(''*** OPEN DOC TO PROPERTY ' p ' ***'')']);
